import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/services/me_service.dart';
import '../features/activity/activity_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/blood_request/blood_request_screen.dart';
import '../features/donor/donor_list_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../models/user_profile_model.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  List<Widget> _screens({required bool isAdmin}) {
    return [
      HomeScreen(onTabChange: changeTab),
      const DonorListScreen(),
      const BloodRequestScreen(),
      const ActivityScreen(),
      _MoreScreen(
        isAdmin: isAdmin,
        onTabChange: changeTab,
        onLogout: () => _logout(context),
      ),
      const ProfileScreen(),
      SettingsScreen(onTabChange: changeTab),
      if (isAdmin) const AdminDashboardScreen(),
    ];
  }

  int _selectedBottomIndex(int screenIndex) {
    if (screenIndex <= 3) return screenIndex;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return StreamBuilder<UserProfileModel?>(
      stream: MeService().watchMe(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return _LoadingProfileScreen(user: user);
        }

        if (profile.isBlocked) {
          return _BlockedAccountScreen(
            email: profile.email.isEmpty ? user.email ?? '' : profile.email,
            onLogout: () => _logout(context),
          );
        }

        final isAdmin = profile.role.toLowerCase().trim() == 'admin';
        final screens = _screens(isAdmin: isAdmin);

        if (_currentIndex >= screens.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: false,
          resizeToAvoidBottomInset: true,
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: AppColors.white,
                  indicatorColor: AppColors.lightTeal,
                  height: 68,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);

                    return TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: selected
                          ? AppColors.primaryTeal
                          : AppColors.textSecondary,
                    );
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);

                    return IconThemeData(
                      color: selected
                          ? AppColors.primaryTeal
                          : AppColors.textSecondary,
                      size: selected ? 25 : 23,
                    );
                  }),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedBottomIndex(_currentIndex),
                  onDestinationSelected: (index) {
                    if (index == 4) {
                      changeTab(4);
                    } else {
                      changeTab(index);
                    }
                  },
                  animationDuration: const Duration(milliseconds: 280),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people_rounded),
                      label: 'Donors',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bloodtype_outlined),
                      selectedIcon: Icon(Icons.bloodtype_rounded),
                      label: 'Request',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.notifications_none_rounded),
                      selectedIcon: Icon(Icons.notifications_rounded),
                      label: 'Activity',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: 'More',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MoreScreen extends StatelessWidget {
  const _MoreScreen({
    required this.isAdmin,
    required this.onTabChange,
    required this.onLogout,
  });

  final bool isAdmin;
  final void Function(int index) onTabChange;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryTeal, AppColors.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.softShadow,
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.dashboard_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'More',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Profile, settings and admin tools',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            _MoreTile(
              title: 'Profile',
              subtitle: 'View and update your profile',
              icon: Icons.person_outline_rounded,
              color: AppColors.primaryTeal,
              onTap: () => onTabChange(5),
            ),

            const SizedBox(height: 12),

            _MoreTile(
              title: 'Settings',
              subtitle: 'Account settings and logout',
              icon: Icons.settings_outlined,
              color: AppColors.textSecondary,
              onTap: () => onTabChange(6),
            ),

            if (isAdmin) ...[
              const SizedBox(height: 12),
              _MoreTile(
                title: 'Admin Panel',
                subtitle: 'Manage users, donors and requests',
                icon: Icons.admin_panel_settings_outlined,
                color: AppColors.primaryGreen,
                onTap: () => onTabChange(7),
              ),
            ],

            const SizedBox(height: 12),

            _MoreTile(
              title: 'Logout',
              subtitle: 'Sign out from Life Drop',
              icon: Icons.logout_rounded,
              color: AppColors.danger,
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingProfileScreen extends StatelessWidget {
  const _LoadingProfileScreen({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileModel.empty(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      photo: user.photoURL ?? '',
    );

    MeService().createMeIfNotExists(profile);

    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}

class _BlockedAccountScreen extends StatelessWidget {
  const _BlockedAccountScreen({required this.email, required this.onLogout});

  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 86,
                    width: 86,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block_rounded,
                      color: AppColors.danger,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your account has been blocked.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email.isEmpty
                        ? 'Please contact support or an administrator for help.'
                        : '$email cannot access Life Drop right now. Please contact support or an administrator for help.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
