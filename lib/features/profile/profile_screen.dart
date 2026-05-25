import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/me_service.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/common_header.dart';
import 'update_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not added';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day-$month-$year';
  }

  String _yesNo(bool? value) {
    if (value == null) return 'Not added';
    return value ? 'Yes' : 'No';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<UserProfileModel?>(
        stream: MeService().watchMe(user.uid),
        builder: (context, snapshot) {
          final profile =
              snapshot.data ??
              UserProfileModel.empty(
                uid: user.uid,
                name: user.displayName ?? '',
                email: user.email ?? '',
                phone: user.phoneNumber ?? '',
                photo: user.photoURL ?? '',
              );

          return Column(
            children: [
              CommonHeader(
                title: 'My Profile',
                subtitle: profile.isProfileComplete
                    ? 'Your donor profile is complete'
                    : 'Complete your donor profile',
                imageUrl: profile.photo,
                actions: [
                  IconButton(
                    tooltip: 'Edit Profile',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UpdateProfileScreen(profile: profile),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildProfileTopCard(context, profile),
                    const SizedBox(height: 16),
                    _buildBasicInfoCard(profile),
                    const SizedBox(height: 16),
                    _buildDonationInfoCard(profile),
                    const SizedBox(height: 16),
                    _buildHealthInfoCard(profile),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileTopCard(BuildContext context, UserProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.lightTeal,
            backgroundImage: profile.photo.isNotEmpty
                ? NetworkImage(profile.photo)
                : null,
            child: profile.photo.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.primaryTeal,
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            profile.name.isEmpty ? 'No name added' : profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            profile.email.isEmpty ? 'No email added' : profile.email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: profile.isProfileComplete
                  ? AppColors.lightGreen
                  : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              profile.isProfileComplete
                  ? 'Profile Complete'
                  : 'Profile Incomplete',
              style: TextStyle(
                color: profile.isProfileComplete
                    ? AppColors.primaryGreen
                    : const Color(0xFFF57F17),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UpdateProfileScreen(profile: profile),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(UserProfileModel profile) {
    return _sectionCard(
      title: 'Basic Information',
      icon: Icons.person_outline,
      children: [
        _infoRow('Name', profile.name),
        _infoRow('Address', profile.address),
        _infoRow('Phone', profile.phone),
        _infoRow('Email', profile.email),
        _infoRow('Blood Group', profile.bloodGroup),
      ],
    );
  }

  Widget _buildDonationInfoCard(UserProfileModel profile) {
    return _sectionCard(
      title: 'Donation Information',
      icon: Icons.volunteer_activism_outlined,
      children: [
        _infoRow('Last Donate Date', _formatDate(profile.lastDonateDate)),
      ],
    );
  }

  Widget _buildHealthInfoCard(UserProfileModel profile) {
    return _sectionCard(
      title: 'Health Screening',
      icon: Icons.health_and_safety_outlined,
      children: [
        _statusRow(
          'Current Illness Status',
          _yesNo(profile.currentIllnessStatus),
        ),
        _statusRow(
          'Current Medication Status',
          _yesNo(profile.currentMedicationStatus),
        ),
        _statusRow(
          'Recent Surgery / Major Illness',
          _yesNo(profile.recentSurgeryOrMajorIllness),
        ),
        _statusRow('HIV Test Result', profile.hivTestResult),
        _statusRow('Hepatitis B Test Result', profile.hepatitisBTestResult),
        _statusRow('Hepatitis C Test Result', profile.hepatitisCTestResult),
        _statusRow('Syphilis Test Result', profile.syphilisTestResult),
      ],
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    final displayValue = value.isEmpty ? 'Not added' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _statusRow(String title, String value) {
    final displayValue = value.isEmpty ? 'Not added' : value;
    final lower = displayValue.toLowerCase();

    Color bgColor = AppColors.lightTeal;
    Color textColor = AppColors.primaryTeal;

    if (lower == 'yes' || lower == 'positive') {
      bgColor = const Color(0xFFFFEBEE);
      textColor = AppColors.danger;
    } else if (lower == 'no' || lower == 'negative') {
      bgColor = AppColors.lightGreen;
      textColor = AppColors.primaryGreen;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              displayValue,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
