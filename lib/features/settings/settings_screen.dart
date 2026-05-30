import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/me_service.dart';
import '../../models/user_profile_model.dart';
import '../../widgets/common_header.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.onTabChange,
    this.adminTabIndex,
  });

  final void Function(int index) onTabChange;
  final int? adminTabIndex;

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  bool _isAdmin(UserProfileModel? profile) {
    return profile?.role.toLowerCase().trim() == 'admin';
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
          final profile = snapshot.data;
          final isAdmin = _isAdmin(profile);

          return Column(
            children: [
              CommonHeader(
                title: 'Settings',
                subtitle: user.email ?? 'Account settings',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (isAdmin && adminTabIndex != null) ...[
                      _settingsTile(
                        title: 'Admin Panel',
                        subtitle: 'Manage users, donors and requests',
                        icon: Icons.admin_panel_settings_outlined,
                        iconColor: AppColors.primaryTeal,
                        onTap: () {
                          onTabChange(adminTabIndex!);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    _settingsTile(
                      title: 'Activity',
                      subtitle: 'Notifications and updates',
                      icon: Icons.notifications_none_rounded,
                      iconColor: AppColors.primaryTeal,
                      onTap: () {
                        onTabChange(3);
                      },
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(
                      title: 'Account',
                      subtitle: user.email ?? 'No email found',
                      icon: Icons.person_outline,
                      iconColor: AppColors.primaryGreen,
                      onTap: () {
                        onTabChange(4);
                      },
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(
                      title: 'Logout',
                      subtitle: 'Sign out from Life Drop',
                      icon: Icons.logout,
                      iconColor: AppColors.danger,
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _settingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
