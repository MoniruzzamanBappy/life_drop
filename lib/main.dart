import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lifedrop/core/constants/app_colors.dart';
import 'package:lifedrop/features/auth/auth_provider.dart';
import 'package:provider/provider.dart';

import 'app/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LifeDropApp());
}

class LifeDropApp extends StatelessWidget {
  const LifeDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LifeDropAuthProvider()),
      ],
      child: MaterialApp(
        title: 'Life Drop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryTeal),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryTeal,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
