import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A4731);
  static const Color primaryDark = Color(0xFF0F2D1E);
  static const Color primaryLight = Color(0xFF2D6A4F);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F9F6);
  static const Color surfaceElevated = Color(0xFFEBF3EE);
  static const Color surfaceCard = Color(0xFFF0F7F2);

  static const Color textPrimary = Color(0xFF0F2D1E);
  static const Color textSecondary = Color(0xFF2D6A4F);
  static const Color textMuted = Color(0xFF5C9070);

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color divider = Color(0xFFD4E8DC);
  static const Color border = Color(0xFFB8D9C4);

  // Gradient stops
  static const List<Color> primaryGradient = [
    Color(0xFF1A4731),
    Color(0xFF0F2D1E),
  ];
  static const List<Color> backgroundGradient = [
    Color(0xFFF5F9F6),
    Color(0xFFFFFFFF),
  ];

  // Plan tier colors
  static const Color planFree = Color(0xFF6B7280);
  static const Color planBasic = Color(0xFF1565C0);
  static const Color planPro = Color(0xFF1A4731);
}
