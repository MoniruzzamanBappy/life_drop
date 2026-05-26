import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<SplashItem> _items = const [
    SplashItem(
      title: 'Welcome to Life Drop',
      subtitle: 'Donate a drop, save a life.',
      description: 'Life Drop connects blood donors with people who urgently need blood.',
      icon: Icons.bloodtype,
    ),
    SplashItem(
      title: 'Find Blood Donors',
      subtitle: 'Search donors near you',
      description: 'Quickly find available donors by blood group, city, and area.',
      icon: Icons.search,
    ),
    SplashItem(
      title: 'Request Blood Easily',
      subtitle: 'Create emergency requests',
      description: 'Post blood requests and reach nearby donors faster during emergencies.',
      icon: Icons.volunteer_activism,
    ),
  ];

  Future<void> _finishSplash() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenSplash', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishSplash();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 30 : 9,
      height: 9,
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.bloodGradient : null,
        color: isActive ? null : AppColors.border,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishSplash,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final selected = _currentPage == index;

                  return AnimatedScale(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    scale: selected ? 1 : 0.95,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'life-drop-logo',
                            child: Image.asset(
                              'assets/logo.png',
                              height: 126,
                              width: 126,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            height: 96,
                            width: 96,
                            decoration: BoxDecoration(
                              gradient: AppColors.bloodGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppColors.softShadow,
                            ),
                            child: Icon(item.icon, size: 50, color: Colors.white),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppColors.deepRed,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_items.length, _buildIndicator),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.bloodGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppColors.softShadow,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      isLastPage ? 'Get Started' : 'Next',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class SplashItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const SplashItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}
