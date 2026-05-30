import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color deepRed = Color(0xFFB42318);

  static const Color lightTeal = Color(0xFFE6FFFB);
  static const Color lightGreen = Color(0xFFEFFDF4);
  static const Color lightRed = Color(0xFFFFF1F1);

  static const Color white = Colors.white;
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF0FDFA);

  static const Color textPrimary = Color(0xFF102A27);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color muted = Color(0xFF94A3B8);

  static const Color border = Color(0xFFE2E8F0);
  static const Color danger = Color(0xFFE53935);
  static const Color warning = Color(0xFFF59E0B);
  static const Color lightWarning = Color(0xFFFFF8E1);
  static const Color warningBorder = Color(0xFFFFECB3);
  static const Color success = Color(0xFF16A34A);
  static const Color info = Color(0xFF0284C7);
  static const Color cardShadow = Color(0x1A0F172A);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryTeal, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bloodGradient = LinearGradient(
    colors: [primaryRed, deepRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get softShadow => const [
    BoxShadow(color: cardShadow, blurRadius: 24, offset: Offset(0, 12)),
  ];
}
