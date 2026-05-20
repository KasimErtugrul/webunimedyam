import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTheme {
  // ─── Renkler (sabit) ────────────────────────────────────────────────────────
  static const primaryColor = Color(0xFF1DB954);
  static const secondaryColor = Color(0xFF1ED760);

  // Dark tema renkleri
  static const darkBackground = Color(0xFF0A0A0A);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF242424);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFB3B3B3);

  // Light tema renkleri
  static const lightBackground = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF0D0D0D);
  static const lightTextSecondary = Color(0xFF6B6B6B);

  // ─── Context-aware renk yardımcıları ──────────────────────────────────────
  static Color bg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color card(BuildContext context) {
    final theme = Theme.of(context);
    return theme.cardTheme.color ??
        (theme.brightness == Brightness.dark ? darkCard : lightCard);
  }

  static Color textPri(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSec(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextSecondary
      : lightTextSecondary;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ─── Dark ThemeData ────────────────────────────────────────────────────────
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSurface: darkTextPrimary,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: darkTextSecondary),
      labelStyle: const TextStyle(color: darkTextSecondary),
    ),
  );

  // ─── Light ThemeData ────────────────────────────────────────────────────────
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSurface: lightTextPrimary,
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: lightTextPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: lightTextSecondary),
      labelStyle: const TextStyle(color: lightTextSecondary),
    ),
  );
}

// ─── Responsive Text Styles Extension (ScreenUtil için) ─────────────────────
extension ResponsiveTextStyle on TextTheme {
  TextStyle get displayLarge =>
      TextStyle(fontSize: 57.sp, fontWeight: FontWeight.bold);
  TextStyle get displayMedium =>
      TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold);
  TextStyle get displaySmall =>
      TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold);

  TextStyle get headlineLarge =>
      TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold);
  TextStyle get headlineMedium =>
      TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w600);
  TextStyle get headlineSmall =>
      TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600);

  TextStyle get titleLarge =>
      TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600);
  TextStyle get titleMedium =>
      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500);
  TextStyle get titleSmall =>
      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500);

  TextStyle get bodyLarge => TextStyle(fontSize: 16.sp);
  TextStyle get bodyMedium => TextStyle(fontSize: 14.sp);
  TextStyle get bodySmall => TextStyle(fontSize: 12.sp);

  TextStyle get labelLarge =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600);
  TextStyle get labelMedium =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500);
  TextStyle get labelSmall =>
      TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500);
}

// ─── AppBar Title için Responsive Helper ────────────────────────────────────
extension ResponsiveAppBar on AppBarTheme {
  static TextStyle get titleStyle =>
      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold);
}
