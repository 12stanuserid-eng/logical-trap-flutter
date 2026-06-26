import 'package:flutter/material.dart';

/// Brain Test-style theme constants
class AppTheme {
  // Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52E0);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFFFFD93D);
  static const Color success = Color(0xFF6BCB77);
  static const Color background = Color(0xFFF0F0FF);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);
  static const Color danger = Color(0xFFFF4757);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient playGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
  );

  static const LinearGradient sceneGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FF), Color(0xFFE8ECFF)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6BCB77), Color(0xFF4CAF50)],
  );

  // Shadows
  static BoxShadow softShadow = const BoxShadow(
    color: Color(0x14000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static BoxShadow strongShadow = const BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // Border radius
  static const double cardRadius = 20;
  static const double buttonRadius = 30;
  static const double smallRadius = 12;

  // Theme data
  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
      );
}
