import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../features/auth/login_screen.dart';
import 'routes.dart';

class LifeDropApp extends StatelessWidget {
  const LifeDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Drop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryTeal,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: {AppRoutes.login: (_) => const LoginScreen()},
    );
  }
}
