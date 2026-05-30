import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/call_service.dart';
import '../../models/donor_model.dart';

class DonorProfileScreen extends StatelessWidget {
  const DonorProfileScreen({super.key, required this.donor});

  final DonorModel donor;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not added';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  Future<void> _callDonor(BuildContext context) async {
    final success = await CallService.callPhone(donor.phone);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone dialer'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = donor.isAvailable;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Donor Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 22 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: _heroCard(context),
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Blood Information',
              icon: Icons.bloodtype_outlined,
              children: [
                _infoTile(
                  icon: Icons.water_drop,
                  title: 'Blood Group',
                  value: donor.bloodGroup.isEmpty
                      ? 'Not added'
                      : donor.bloodGroup,
                  valueColor: AppColors.danger,
                ),
                _infoTile(
                  icon: Icons.history,
                  title: 'Last Donation Date',
                  value: _formatDate(donor.lastDonateDate),
                ),
                _infoTile(
                  icon: isAvailable ? Icons.check_circle : Icons.cancel,
                  title: 'Availability',
                  value: isAvailable
                      ? 'Available for donation'
                      : 'Currently unavailable',
                  valueColor: isAvailable
                      ? AppColors.primaryGreen
                      : AppColors.danger,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Location',
              icon: Icons.location_on_outlined,
              children: [
                _infoTile(
                  icon: Icons.map_outlined,
                  title: 'District',
                  value: donor.district.isEmpty ? 'Not added' : donor.district,
                ),
                _infoTile(
                  icon: Icons.home_outlined,
                  title: 'Address',
                  value: donor.address.isEmpty ? 'Not added' : donor.address,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionCard(
              title: 'Contact',
              icon: Icons.phone_outlined,
              children: [
                _infoTile(
                  icon: Icons.person_outline,
                  title: 'Name',
                  value: donor.name.isEmpty ? 'Not added' : donor.name,
                ),
                _infoTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: donor.phone.isEmpty ? 'Not added' : donor.phone,
                ),
                _infoTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: donor.email.isEmpty ? 'Not added' : donor.email,
                ),
              ],
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: donor.phone.trim().isEmpty
                  ? null
                  : () => _callDonor(context),
              icon: const Icon(Icons.call),
              label: const Text('Call Donor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.textSecondary.withValues(
                  alpha: 0.25,
                ),
                disabledForegroundColor: AppColors.textSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.lightTeal,
                child: Text(
                  donor.bloodGroup.isEmpty ? '?' : donor.bloodGroup,
                  style: const TextStyle(
                    color: AppColors.primaryTeal,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (donor.isVerified)
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  donor.name.isEmpty ? 'Unknown Donor' : donor.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (donor.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.verified,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: donor.isAvailable
                  ? AppColors.primaryGreen.withValues(alpha: 0.10)
                  : AppColors.danger.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  donor.isAvailable ? Icons.check_circle : Icons.cancel,
                  size: 17,
                  color: donor.isAvailable
                      ? AppColors.primaryGreen
                      : AppColors.danger,
                ),
                const SizedBox(width: 6),
                Text(
                  donor.isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: donor.isAvailable
                        ? AppColors.primaryGreen
                        : AppColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  donor.district.isEmpty
                      ? 'District not added'
                      : donor.district,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (donor.isVerified) _verifiedBadge() else _notVerifiedBadge(),
        ],
      ),
    );
  }

  Widget _verifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.primaryGreen,
          ),
          SizedBox(width: 6),
          Text(
            'Verified Donor',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.warning),
          SizedBox(width: 6),
          Text(
            'Not Verified Yet',
            style: TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.primaryTeal, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
