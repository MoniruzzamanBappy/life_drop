import 'package:flutter/material.dart';
import 'package:lifedrop/core/services/call_service.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/donor_service.dart';
import '../../models/donor_model.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/custom_text_field.dart';

class FindDonorsScreen extends StatefulWidget {
  const FindDonorsScreen({super.key});

  @override
  State<FindDonorsScreen> createState() => _FindDonorsScreenState();
}

class _FindDonorsScreenState extends State<FindDonorsScreen> {
  final _districtController = TextEditingController();

  String? _bloodGroup;
  String _district = '';

  final List<String> _bloodGroups = const [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not added';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  @override
  void dispose() {
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Find Donors')),
      body: Column(
        children: [
          _filterSection(),
          Expanded(
            child: StreamBuilder<List<DonorModel>>(
              stream: DonorService().watchAvailableDonors(
                bloodGroup: _bloodGroup,
                district: _district,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final donors = snapshot.data ?? [];

                if (donors.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No available donors found',
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
                    return _donorCard(donors[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        children: [
          CustomDropdownField(
            label: 'Blood Group',
            value: _bloodGroup,
            prefixIcon: Icons.bloodtype,
            items: _bloodGroups,
            onChanged: (value) {
              setState(() {
                _bloodGroup = value;
              });
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _districtController,
            label: 'District',
            prefixIcon: Icons.map_outlined,
            onChanged: (value) {
              setState(() {
                _district = value.trim();
              });
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _bloodGroup = null;
                  _district = '';
                  _districtController.clear();
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filter'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _donorCard(DonorModel donor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.lightTeal,
            child: Text(
              donor.bloodGroup,
              style: const TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${donor.district} • ${donor.phone}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 5),
                Text(
                  'Last donate: ${_formatDate(donor.lastDonateDate)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final success = await CallService.callPhone(donor.phone);

              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open phone dialer'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            icon: const Icon(Icons.phone, color: AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }
}
