import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifedrop/app/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/login_screen.dart';
import '../features/splash/splash_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _hasSeenSplash = false;

  @override
  void initState() {
    super.initState();
    _checkSplashStatus();
  }

  Future<void> _checkSplashStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenSplash = prefs.getBool('hasSeenSplash') ?? false;

    if (!mounted) return;

    setState(() {
      _hasSeenSplash = hasSeenSplash;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          return const MainLayout();
        }

        if (_hasSeenSplash) {
          return const LoginScreen();
        }

        return const SplashScreen();
      },
    );
  }
}
