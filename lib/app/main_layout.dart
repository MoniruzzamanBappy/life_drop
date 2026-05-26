import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../features/blood_request/blood_request_screen.dart';
import '../features/donor/donor_list_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void changeTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  late final List<Widget> _screens = [
    HomeScreen(onTabChange: changeTab),
    const DonorListScreen(),
    const BloodRequestScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  final List<_NavItem> _items = const [
    _NavItem(Icons.home_outlined, Icons.home, 'Home'),
    _NavItem(Icons.people_outline, Icons.people, 'Donors'),
    _NavItem(Icons.bloodtype_outlined, Icons.bloodtype, 'Request'),
    _NavItem(Icons.person_outline, Icons.person, 'Profile'),
    _NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final selected = _currentIndex == index;

                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => changeTab(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.lightTeal : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: selected ? 1.12 : 1,
                              duration: const Duration(milliseconds: 220),
                              child: Icon(
                                selected ? item.selectedIcon : item.icon,
                                color: selected
                                    ? AppColors.primaryTeal
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: TextStyle(
                                fontSize: selected ? 12 : 11,
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                color: selected
                                    ? AppColors.primaryTeal
                                    : AppColors.textSecondary,
                              ),
                              child: Text(item.label, maxLines: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}
