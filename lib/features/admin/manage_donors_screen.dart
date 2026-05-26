import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/donor_service.dart';
import '../../models/donor_model.dart';
import '../../widgets/common_header.dart';

class ManageDonorsScreen extends StatefulWidget {
  const ManageDonorsScreen({super.key});

  @override
  State<ManageDonorsScreen> createState() => _ManageDonorsScreenState();
}

class _ManageDonorsScreenState extends State<ManageDonorsScreen> {
  final _searchController = TextEditingController();

  String _searchText = '';
  String _filter = 'all';

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not added';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  List<DonorModel> _applyFilter(List<DonorModel> donors) {
    List<DonorModel> filtered = donors;

    if (_filter == 'verified') {
      filtered = filtered.where((donor) => donor.isVerified).toList();
    } else if (_filter == 'pending') {
      filtered = filtered.where((donor) => !donor.isVerified).toList();
    } else if (_filter == 'available') {
      filtered = filtered.where((donor) => donor.isAvailable).toList();
    } else if (_filter == 'unavailable') {
      filtered = filtered.where((donor) => !donor.isAvailable).toList();
    }

    if (_searchText.trim().isNotEmpty) {
      final query = _searchText.trim().toLowerCase();

      filtered = filtered.where((donor) {
        return donor.name.toLowerCase().contains(query) ||
            donor.phone.toLowerCase().contains(query) ||
            donor.email.toLowerCase().contains(query) ||
            donor.district.toLowerCase().contains(query) ||
            donor.bloodGroup.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _updateVerification({
    required BuildContext context,
    required DonorModel donor,
    required bool isVerified,
  }) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;

    if (adminUid == null) {
      _showMessage(context, 'Admin user not found', isError: true);
      return;
    }

    try {
      await DonorService().updateVerification(
        donorUid: donor.uid,
        isVerified: isVerified,
        adminUid: adminUid,
      );

      if (!context.mounted) return;

      _showMessage(
        context,
        isVerified ? 'Donor verified successfully' : 'Donor unverified',
      );
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(context, e.toString(), isError: true);
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.primaryGreen,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CommonHeader(
            title: 'Manage Donors',
            subtitle: 'Verify and review donor profiles',
          ),
          _filters(),
          Expanded(
            child: StreamBuilder<List<DonorModel>>(
              stream: DonorService().watchAllDonors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final donors = _applyFilter(snapshot.data ?? []);

                if (donors.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No donors found',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: donors.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _donorCard(context, donors[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name, phone, district, blood group',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primaryTeal,
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', 'all'),
                _filterChip('Verified', 'verified'),
                _filterChip('Pending', 'pending'),
                _filterChip('Available', 'available'),
                _filterChip('Unavailable', 'unavailable'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.lightTeal,
        labelStyle: TextStyle(
          color: selected ? AppColors.primaryTeal : AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
        side: const BorderSide(color: AppColors.border),
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }

  Widget _donorCard(BuildContext context, DonorModel donor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.lightTeal,
                child: Text(
                  donor.bloodGroup.isEmpty ? '?' : donor.bloodGroup,
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  donor.name.isEmpty ? 'No name added' : donor.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _statusBadge(
                donor.isVerified ? 'VERIFIED' : 'PENDING',
                donor.isVerified ? AppColors.primaryGreen : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow('Phone', donor.phone),
          _infoRow('Email', donor.email),
          _infoRow('District', donor.district),
          _infoRow('Address', donor.address),
          _infoRow('Last Donate Date', _formatDate(donor.lastDonateDate)),
          _infoRow(
            'Availability',
            donor.isAvailable ? 'Available' : 'Unavailable',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: donor.isVerified
                      ? null
                      : () => _updateVerification(
                          context: context,
                          donor: donor,
                          isVerified: true,
                        ),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Verify'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: donor.isVerified
                      ? () => _updateVerification(
                          context: context,
                          donor: donor,
                          isVerified: false,
                        )
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Unverify'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    final displayValue = value.isEmpty ? 'Not added' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
