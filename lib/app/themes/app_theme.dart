import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ÜniTV — Uygulama Teması
/// ---------------------------------------------------------------------------
/// Bu dosya, `stitch_nitv_mobile_platform` tasarım paketindeki TÜM ekranlarda
/// (ana_sayfa, arama, ayarlar, giriş, kayıt, profil, üniversite detay, video
/// oynatıcı, onboarding vb. — 30+ ekran) birebir aynı şekilde kullanılan
/// Tailwind `tailwind.config` renk paletinden ve tipografi/köşe yuvarlama
/// (border-radius) ölçeğinden doğrudan alınmıştır. Aşağıdaki DARK renkler
/// tasarım dosyalarındaki hex kodların tamamen aynısıdır, uydurma veya
/// yorum içermez.
///
/// LIGHT tema hakkında dürüst not: Tasarım paketindeki tüm ekranlar
/// `<html class="dark">` olarak işaretli — yani Stitch tasarımında AYRI bir
/// light tema ekranı / hex paleti verilmemiş (sadece "onboarding_tema_se_imi"
/// ekranında bir light/dark seçim anahtarı var, ama karşılık gelen açık renk
/// değerleri yok). Bu nedenle light temayı, dark temanın kaynağı olan aynı
/// marka tohum (seed) rengi kullanılarak Google'ın resmi Material 3 HCT tonal
/// palet algoritmasıyla (ColorScheme.fromSeed) üretiyorum. Bunu seçmemin
/// sebebi: dark şemadaki `primary-container` (#10B981) değeri, standart bir
/// "emerald" tohum rengiyle birebir örtüşüyor ve M3 Theme Builder'ın ürettiği
/// tonlarla (primary/surface-tint = #4EDEA3 vb.) tam uyumlu — yani dark tema
/// da muhtemelen bu tohumdan türetilmiş. Böylece light tema, tasarımcının
/// kullandığı marka rengiyle tutarlı ve keyfi olmayan, M3 standardına uygun
/// şekilde üretilmiş olur.
abstract class AppTheme {
  // ─── Marka / Tohum Renk (tasarımdaki primary-container) ──────────────────
  static const _seedColor = Color(0xFF10B981);

  // ─── Geriye dönük uyumluluk için kısayollar (kod tabanında 150+ yerde
  // kullanılıyor: AppTheme.primaryColor, AppTheme.secondaryColor ...) ───────
  static const primaryColor = Color(0xFF4EDEA3); // dark.primary / surface-tint
  static const secondaryColor = Color(0xFF45DFA4); // dark.secondary

  // ═══════════════════════════════════════════════════════════════════════
  // DARK TEMA RENKLERİ — tasarımdaki tailwind.config.colors ile BİREBİR
  // (ana_sayfa, arama, ayarlar, profil, giriş, üniversite_detay, video
  // oynatıcı vb. tüm ekranlarda aynı değerler doğrulandı)
  // ═══════════════════════════════════════════════════════════════════════
  static const darkPrimary = Color(0xFF4EDEA3);
  static const darkOnPrimary = Color(0xFF003824);
  static const darkPrimaryContainer = Color(0xFF10B981);
  static const darkOnPrimaryContainer = Color(0xFF00422B);
  static const darkPrimaryFixed = Color(0xFF6FFBBE);
  static const darkPrimaryFixedDim = Color(0xFF4EDEA3);
  static const darkOnPrimaryFixed = Color(0xFF002113);
  static const darkOnPrimaryFixedVariant = Color(0xFF005236);
  static const darkInversePrimary = Color(0xFF006C49);
  static const darkSurfaceTint = Color(0xFF4EDEA3);

  static const darkSecondary = Color(0xFF45DFA4);
  static const darkOnSecondary = Color(0xFF003825);
  static const darkSecondaryContainer = Color(0xFF00BD85);
  static const darkOnSecondaryContainer = Color(0xFF00452E);
  static const darkSecondaryFixed = Color(0xFF68FCBF);
  static const darkSecondaryFixedDim = Color(0xFF45DFA4);
  static const darkOnSecondaryFixed = Color(0xFF002114);
  static const darkOnSecondaryFixedVariant = Color(0xFF005137);

  static const darkTertiary = Color(0xFFFFB3AD);
  static const darkOnTertiary = Color(0xFF68000A);
  static const darkTertiaryContainer = Color(0xFFFF7A73);
  static const darkOnTertiaryContainer = Color(0xFF79000E);
  static const darkTertiaryFixed = Color(0xFFFFDAD7);
  static const darkTertiaryFixedDim = Color(0xFFFFB3AD);
  static const darkOnTertiaryFixed = Color(0xFF410004);
  static const darkOnTertiaryFixedVariant = Color(0xFF930013);

  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);

  static const darkSurface = Color(0xFF0B1322);
  static const darkOnSurface = Color(0xFFDBE2F7);
  static const darkSurfaceDim = Color(0xFF0B1322);
  static const darkSurfaceBright = Color(0xFF31394A);
  static const darkSurfaceContainerLowest = Color(0xFF060E1D);
  static const darkSurfaceContainerLow = Color(0xFF141C2B);
  static const darkSurfaceContainer = Color(0xFF18202F);
  static const darkSurfaceContainerHigh = Color(0xFF222A3A);
  static const darkSurfaceContainerHighest = Color(0xFF2D3545);
  static const darkOnSurfaceVariant = Color(0xFFBBCABF);
  static const darkSurfaceVariant = Color(0xFF2D3545);

  static const darkOutline = Color(0xFF86948A);
  static const darkOutlineVariant = Color(0xFF3C4A42);
  static const darkInverseSurface = Color(0xFFDBE2F7);
  static const darkOnInverseSurface = Color(0xFF293040);
  static const darkBackground = Color(0xFF0B1322);
  static const darkOnBackground = Color(0xFFDBE2F7);

  // Eski API ile uyum (kart/yüzey renkleri okunurken kullanılan takma adlar)
  static const darkCard = darkSurfaceContainerLow;
  static const darkTextPrimary = darkOnSurface;
  static const darkTextSecondary = darkOnSurfaceVariant;

  // ═══════════════════════════════════════════════════════════════════════
  // LIGHT TEMA RENKLERİ — aynı tohum renkten (#10B981) M3 algoritmasıyla
  // üretilen ColorScheme'in en sık kullanılan tonlarının statik önizlemesi.
  // (Gerçek ThemeData, aşağıda `ColorScheme.fromSeed` ile üretilir; bu
  // sabitler yalnızca eski context'siz kullanım noktaları için kolaylık
  // amaçlıdır ve fromSeed çıktısıyla senkron tutulmuştur.)
  // ═══════════════════════════════════════════════════════════════════════
  static const lightPrimary = Color(0xFF006C49);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFF7CF8C5);
  static const lightOnPrimaryContainer = Color(0xFF00210F);

  static const lightSecondary = Color(0xFF00694A);
  static const lightOnSecondary = Color(0xFFFFFFFF);

  static const lightBackground = Color(0xFFF6FBF6);
  static const lightSurface = Color(0xFFF6FBF6);
  static const lightSurfaceContainerLow = Color(0xFFF0F5EF);
  static const lightSurfaceContainerHigh = Color(0xFFE4EAE3);
  static const lightOnSurface = Color(0xFF181D18);
  static const lightOnSurfaceVariant = Color(0xFF404943);

  static const lightCard = lightSurfaceContainerLow;
  static const lightTextPrimary = lightOnSurface;
  static const lightTextSecondary = lightOnSurfaceVariant;

  // ─── Tasarımdaki köşe yuvarlama (borderRadius) ölçeği ─────────────────────
  // rounded (DEFAULT) 0.25rem, lg 0.5rem, xl 0.75rem, full 9999px
  static const radiusSm = 4.0; // rounded
  static const radiusMd = 8.0; // rounded-lg  → butonlar, input alanları
  static const radiusLg = 12.0; // rounded-xl → kartlar, modal/sheet
  static const radiusFull = 999.0; // rounded-full → chip/pill, avatar

  // ─── Context-aware renk yardımcıları (mevcut API korunuyor) ──────────────
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
      Theme.of(context).colorScheme.onSurfaceVariant;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ─── Font Eşleştirmesi ─────────────────────────────────────────────────
  // Tasarımdaki `fontFamily` tablosunda TÜM roller (headline-*, body-*,
  // label-*) tek bir aileye bağlı: "Plus Jakarta Sans". O yüzden burada
  // başlık/gövde/etiket ayrımı yapılmadan tek font kullanılıyor
  // (önceki sürümdeki Poppins/Inter karışımı, tasarımla eşleşmediği için
  // kaldırıldı).
  static TextTheme _buildTextTheme(TextTheme base) {
    final font = GoogleFonts.plusJakartaSansTextTheme(base);
    final onColor = base.bodyMedium?.color;

    // Tasarımdaki fontSize tablosu (px/line-height/letter-spacing/weight):
    // headline-xl 32/40/-0.03em/800   headline-lg 24/32/-0.02em/700
    // headline-md 20/28/-0.015em/700  headline-sm 18/24/-0.01em/600
    // body-lg 16/24/0/400             body-md 14/20/0/400   body-sm 12/16/0.01em/400
    // label-lg 14/20/0.01em/600       label-md 12/16/0.02em/600  label-sm 10/12/0.04em/700
    return font.copyWith(
      displayLarge: font.displayLarge?.copyWith(
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.03 * 32,
        fontWeight: FontWeight.w800,
        color: onColor,
      ),
      displayMedium: font.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: onColor,
      ),
      displaySmall: font.displaySmall?.copyWith(
        fontSize: 26,
        height: 34 / 26,
        letterSpacing: -0.025 * 26,
        fontWeight: FontWeight.w800,
        color: onColor,
      ),
      headlineLarge: font.headlineLarge?.copyWith(
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: -0.02 * 24,
        fontWeight: FontWeight.w700,
        color: onColor,
      ),
      headlineMedium: font.headlineMedium?.copyWith(
        fontSize: 20,
        height: 28 / 20,
        letterSpacing: -0.015 * 20,
        fontWeight: FontWeight.w700,
        color: onColor,
      ),
      headlineSmall: font.headlineSmall?.copyWith(
        fontSize: 18,
        height: 24 / 18,
        letterSpacing: -0.01 * 18,
        fontWeight: FontWeight.w600,
        color: onColor,
      ),
      titleLarge: font.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onColor,
      ),
      titleMedium: font.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onColor,
      ),
      titleSmall: font.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onColor,
      ),
      bodyLarge: font.bodyLarge?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: onColor,
      ),
      bodyMedium: font.bodyMedium?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: onColor,
      ),
      bodySmall: font.bodySmall?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.01 * 12,
        fontWeight: FontWeight.w400,
        color: onColor,
      ),
      labelLarge: font.labelLarge?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.01 * 14,
        fontWeight: FontWeight.w600,
        color: onColor,
      ),
      labelMedium: font.labelMedium?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
        fontWeight: FontWeight.w600,
        color: onColor,
      ),
      labelSmall: font.labelSmall?.copyWith(
        fontSize: 10,
        height: 12 / 10,
        letterSpacing: 0.04 * 10,
        fontWeight: FontWeight.w700,
        color: onColor,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DARK ColorScheme — tasarımdaki tüm M3 rollerinin BİREBİR karşılığı
  // ═══════════════════════════════════════════════════════════════════════
  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    primaryFixed: darkPrimaryFixed,
    primaryFixedDim: darkPrimaryFixedDim,
    onPrimaryFixed: darkOnPrimaryFixed,
    onPrimaryFixedVariant: darkOnPrimaryFixedVariant,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    secondaryFixed: darkSecondaryFixed,
    secondaryFixedDim: darkSecondaryFixedDim,
    onSecondaryFixed: darkOnSecondaryFixed,
    onSecondaryFixedVariant: darkOnSecondaryFixedVariant,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    tertiaryFixed: darkTertiaryFixed,
    tertiaryFixedDim: darkTertiaryFixedDim,
    onTertiaryFixed: darkOnTertiaryFixed,
    onTertiaryFixedVariant: darkOnTertiaryFixedVariant,
    error: darkError,
    onError: darkOnError,
    errorContainer: darkErrorContainer,
    onErrorContainer: darkOnErrorContainer,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceDim: darkSurfaceDim,
    surfaceBright: darkSurfaceBright,
    surfaceContainerLowest: darkSurfaceContainerLowest,
    surfaceContainerLow: darkSurfaceContainerLow,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHigh: darkSurfaceContainerHigh,
    surfaceContainerHighest: darkSurfaceContainerHighest,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    inverseSurface: darkInverseSurface,
    onInverseSurface: darkOnInverseSurface,
    inversePrimary: darkInversePrimary,
    surfaceTint: darkSurfaceTint,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  // ─── Dark ThemeData ────────────────────────────────────────────────────
  static final darkTheme = _buildThemeData(_darkScheme);

  // ─── Light ThemeData ───────────────────────────────────────────────────
  // Tasarımda ayrı bir light paleti verilmediği için, dark temanın da
  // kaynaklandığı marka tohum rengiyle (#10B981) resmi M3 algoritması
  // kullanılarak üretiliyor. Bu; keyfi/rastgele renk seçmek yerine,
  // Google'ın Material 3 spesifikasyonuna göre matematiksel olarak
  // tanımlı, tutarlı ve tasarım diliyle uyumlu tek doğru yöntemdir.
  static final _lightScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  );

  static final lightTheme = _buildThemeData(_lightScheme);

  // ─── Ortak ThemeData üretici (dark & light aynı bileşen kurallarını
  // paylaşır; sadece ColorScheme değişir — tasarımdaki gibi) ───────────────
  static ThemeData _buildThemeData(ColorScheme scheme) {
    final isDarkTheme = scheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      primaryColor: scheme.primary,
      canvasColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      splashColor: scheme.primary.withValues(alpha: 0.10),
      highlightColor: scheme.primary.withValues(alpha: 0.05),
      textTheme: _buildTextTheme(
        ThemeData(brightness: scheme.brightness, useMaterial3: true).textTheme,
      ),
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

      // AppBar — tasarımda: bg-surface/85 (blur), elevation yok, ikonlar on-surface
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onSurface),
        actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.01 * 18,
          color: scheme.onSurface,
        ),
      ),

      // Bottom Navigation — tasarımda: bg-surface-container-lowest/85 (blur),
      // seçili: primary, seçili değil: on-surface-variant
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkTheme
            ? darkSurfaceContainerLowest
            : scheme.surfaceContainerLowest,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.04 * 10,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.04 * 10,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDarkTheme
            ? darkSurfaceContainerLowest
            : scheme.surfaceContainerLowest,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.04 * 10,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),

      // Kartlar — tasarımda: bg-surface-container(-low), rounded-xl (12px)
      cardTheme: CardThemeData(
        color: isDarkTheme ? darkSurfaceContainerLow : scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      // Ana buton — tasarımda: bg-primary, text on-primary, rounded-lg (8px), h-12
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          elevation: 0,
          minimumSize: Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.01 * 14,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      // İkincil buton — tasarımda: text-primary
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          highlightColor: scheme.primary.withValues(alpha: 0.12),
        ),
      ),

      // Input alanları — tasarımda: bg-surface-container-high, rounded-lg (8px),
      // placeholder: outline, focus: bg-surface-bright
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkTheme
            ? darkSurfaceContainerHigh
            : scheme.surfaceContainerHigh,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: scheme.outline,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Chip / etiket kapsülleri — tasarımda: rounded-full (pill)
      chipTheme: ChipThemeData(
        backgroundColor:
            isDarkTheme ? darkSurfaceContainer : scheme.surfaceContainer,
        selectedColor: scheme.primary.withValues(alpha: 0.20),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: scheme.primary,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return scheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.outline;
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDarkTheme ? darkSurfaceContainerLow : scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor:
            isDarkTheme ? darkSurfaceContainerHigh : scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: scheme.onSurfaceVariant,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDarkTheme ? darkSurfaceContainerHighest : scheme.inverseSurface,
        contentTextStyle: GoogleFonts.plusJakartaSans(
          color: isDarkTheme ? scheme.onSurface : scheme.onInverseSurface,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
    );
  }
}

// ─── Responsive Text Styles Extension (ScreenUtil için) ─────────────────────
// Not: Bu extension, doğrudan TextTheme üzerinden erişim isteyen eski çağrı
// noktalarını (Theme.of(context).textTheme.headlineLarge gibi ekstra
// yardımcı erişim) desteklemek için korundu; artık tek yazı ailesi olan
// Plus Jakarta Sans kullanıyor (öncesindeki Poppins/Inter karışımı yerine).
extension ResponsiveTextStyle on TextTheme {
  TextStyle get displayLarge =>
      GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800);
  TextStyle get displayMedium =>
      GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800);
  TextStyle get displaySmall =>
      GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800);

  TextStyle get headlineLarge =>
      GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700);
  TextStyle get headlineMedium =>
      GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700);
  TextStyle get headlineSmall =>
      GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600);

  TextStyle get titleLarge =>
      GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600);
  TextStyle get titleMedium =>
      GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600);
  TextStyle get titleSmall =>
      GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600);

  TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(fontSize: 16);
  TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(fontSize: 14);
  TextStyle get bodySmall => GoogleFonts.plusJakartaSans(fontSize: 12);

  TextStyle get labelLarge =>
      GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600);
  TextStyle get labelMedium =>
      GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600);
  TextStyle get labelSmall =>
      GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700);
}

// ─── AppBar Title için Responsive Helper ────────────────────────────────────
extension ResponsiveAppBar on AppBarTheme {
  static TextStyle get titleStyle => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      );
}
