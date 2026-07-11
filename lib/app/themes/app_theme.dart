import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // ─── Font Eşleştirmesi (Google Fonts) ──────────────────────────────────────
  // Başlıklar (display/headline/title → AppBar başlıkları, dialog başlıkları,
  // Theme.of(context).textTheme.titleX gibi kullanımlar) için Poppins;
  // gövde metni ve buton yazıları (body/label) için Inter kullanılıyor.
  //
  // NOT: Uygulamadaki metinlerin büyük çoğunluğu doğrudan `TextStyle(...)`
  // ile yazılıyor (fontFamily belirtmeden). Flutter, bir Text widget'ına
  // verilen style'da fontFamily boşsa bunu en yakın DefaultTextStyle'dan
  // (nihayetinde buradaki textTheme'den) miras alır. Yani bu tek değişiklik,
  // tek tek dosyalara dokunmadan uygulamanın geneline yayılıyor.
  static TextTheme _buildTextTheme(TextTheme base) {
    final headingFont = GoogleFonts.poppinsTextTheme(base);
    final bodyFont = GoogleFonts.interTextTheme(base);

    return bodyFont.copyWith(
      displayLarge: headingFont.displayLarge,
      displayMedium: headingFont.displayMedium,
      displaySmall: headingFont.displaySmall,
      headlineLarge: headingFont.headlineLarge,
      headlineMedium: headingFont.headlineMedium,
      headlineSmall: headingFont.headlineSmall,
      titleLarge: headingFont.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: headingFont.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: headingFont.titleSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  // ─── Dark ThemeData ────────────────────────────────────────────────────────
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primaryColor,
    textTheme: _buildTextTheme(
      ThemeData(brightness: Brightness.dark, useMaterial3: true).textTheme,
    ),
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
    textTheme: _buildTextTheme(
      ThemeData(brightness: Brightness.light, useMaterial3: true).textTheme,
    ),
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
      GoogleFonts.poppins(fontSize: 57.sp, fontWeight: FontWeight.bold);
  TextStyle get displayMedium =>
      GoogleFonts.poppins(fontSize: 45.sp, fontWeight: FontWeight.bold);
  TextStyle get displaySmall =>
      GoogleFonts.poppins(fontSize: 36.sp, fontWeight: FontWeight.bold);

  TextStyle get headlineLarge =>
      GoogleFonts.poppins(fontSize: 32.sp, fontWeight: FontWeight.bold);
  TextStyle get headlineMedium =>
      GoogleFonts.poppins(fontSize: 28.sp, fontWeight: FontWeight.w600);
  TextStyle get headlineSmall =>
      GoogleFonts.poppins(fontSize: 24.sp, fontWeight: FontWeight.w600);

  TextStyle get titleLarge =>
      GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.w600);
  TextStyle get titleMedium =>
      GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w500);
  TextStyle get titleSmall =>
      GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500);

  TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 16.sp);
  TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 14.sp);
  TextStyle get bodySmall => GoogleFonts.inter(fontSize: 12.sp);

  TextStyle get labelLarge =>
      GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600);
  TextStyle get labelMedium =>
      GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500);
  TextStyle get labelSmall =>
      GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w500);
}

// ─── AppBar Title için Responsive Helper ────────────────────────────────────
extension ResponsiveAppBar on AppBarTheme {
  static TextStyle get titleStyle =>
      GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold);
}
