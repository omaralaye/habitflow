import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF006D77);
  static const Color primaryLight = Color(0xFF83C5BE);
  static const Color primaryLighter = Color(0xFFEDF6F9);

  // Secondary Palette
  static const Color secondary = Color(0xFFE29578);
  static const Color secondaryLight = Color(0xFFFFDDD2);

  // Pastel Backgrounds
  static const Color bgLavender = Color(0xFFF3E5F5);
  static const Color bgMint = Color(0xFFE0F2F1);
  static const Color bgRose = Color(0xFFFCE4EC);
  static const Color bgSky = Color(0xFFE3F2FD);
  static const Color bgPeach = Color(0xFFFFF3E0);

  // Text Colors
  static const Color textDark = Color(0xFF1B4332);
  static const Color textGrey = Color(0xFF6B705C);
  static const Color textWhite = Colors.white;

  // Accents
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFE53935);
}

class AppStyles {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFB),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.textDark,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.textDark,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.textGrey,
        fontSize: 14,
      ),
    ),
  );
}
