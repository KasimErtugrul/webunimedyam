// lib/presentation/screens/home/widgets/unitv_app_bar.dart
//
// "ÜniTV / KAMPÜS YAYINI" logosunu içeren üst bar.
//
// Önceden bu bar, yalnızca HomeTabWidget'ın (Ana Sayfa sekmesi) içindeki
// CustomScrollView'a bir SliverAppBar olarak ekleniyordu. Bu yüzden
// kullanıcı Keşfet / Üniversiteler / Ara / Profil sekmelerine geçtiğinde
// bar tamamen kayboluyordu.
//
// Çözüm: bar, normal bir AppBar (PreferredSizeWidget) haline getirilip
// HomeScreen'in Scaffold.appBar'ına taşındı. HomeScreen, bottomNavigationBar
// ile birlikte IndexedStack'i sarmalıyor; Scaffold.appBar tüm sekmelerde
// (IndexedStack'in index'i ne olursa olsun) SABİT kalır, çünkü artık
// sekmelere özel scroll view'ların bir parçası değil, en dıştaki Scaffold'a
// ait.
//
// TABLET EKLERİ ("Desktop & Tablet homepage" tasarımından):
//   - Logo yanında geniş ARAMA ÇUBUĞU (tıklayınca Ara sekmesine geçer;
//     gerçek yazma alanı o sekmedeki arama ekranıdır)
//   - "Radyo Yayını" pill butonu (Radyo sayfasına gider)
//   - Tema (koyu/açık) geçiş düğmesi
// Telefon düzeni birebir korundu — bu üç parça yalnızca tablette görünür.
// Tasarımdaki "Kampüs Yayın > Canlı Yayınlar" breadcrumb'ı, logonun altında
// zaten duran "KAMPÜS YAYINI" etiketiyle aynı işi gördüğü için ayrıca
// eklenmedi (kodda olan öğe kaldırılmadı, breadcrumb onunla örtüştü).
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../controllers/home/home_controller.dart';
import '../../../controllers/settings_controller.dart';

class _PhoneSizes {
  static const double titleIconSize = 30;
  static const double titleIconBorderRadius = 8;
  static const double titleIconInnerSize = 18;
  static const double titleSpacing = 8;
  static const double titleSpacingLarge = 16;
}

class _TabletSizes {
  static const double titleIconSize = 36;
  static const double titleIconBorderRadius = 10;
  static const double titleIconInnerSize = 22;
  static const double titleSpacing = 10;
  static const double titleSpacingLarge = 20;

  // Arama çubuğu (tasarım: h-10, rounded-lg, bg-surface-container-high)
  static const double searchHeight = 40;
  static const double searchBorderRadius = 8;
  static const double searchGapFromLogo = 24;
  static const double searchIconSize = 20;
  static const double searchFontSize = 12;
  static const double searchHintToShortcutGap = 8;
  static const double shortcutBadgePadH = 6;
  static const double shortcutBadgePadV = 2;

  // "Radyo Yayını" butonu (tasarım: px-3 py-1.5, rounded-lg)
  static const double radioPadH = 12;
  static const double radioPadV = 7;
  static const double radioIconSize = 18;
  static const double radioFontSize = 12;
  static const double radioGap = 6;
}

/// Tüm bottom navigation sekmelerinde sabit kalan üst bar.
class UniTvAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UniTvAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isTablet = Responsive.isTablet(context);
    final sizes = isTablet
        ? _TabletSizes.titleIconSize
        : _PhoneSizes.titleIconSize;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppTheme.bg(context),
      automaticallyImplyLeading: false,
      titleSpacing: isTablet
          ? _TabletSizes.titleSpacingLarge
          : _PhoneSizes.titleSpacingLarge,
      toolbarHeight: kToolbarHeight,
      actions: [
        // Tasarımdaki "Radyo Yayını" pill butonu — yalnızca tablet.
        if (isTablet) const _RadioLiveButton(sizes: _TabletSizes.radioFontSize),
        IconButton(
          tooltip: 'Canlı Yayınlar',
          icon: const Icon(Icons.sensors_rounded),
          color: scheme.onSurfaceVariant,
          onPressed: () => Get.toNamed(AppRoutes.radio),
        ),
        IconButton(
          tooltip: 'Bildirimler',
          icon: const Icon(Icons.notifications_outlined),
          color: scheme.onSurfaceVariant,
          onPressed: () => Get.toNamed(AppRoutes.notifications), //ProfileScreen
        ),
        // Tasarımdaki koyu/açık tema düğmesi — yalnızca tablet.
        if (isTablet) const _ThemeToggleButton(),
        IconButton(
          tooltip: 'Bildirimler',
          icon: const Icon(Icons.person_rounded),
          color: scheme.onSurfaceVariant,
          onPressed: () => Get.toNamed(AppRoutes.profile), //ProfileScreen
        ),
      ],
      title: Row(
        children: [
          Container(
            width: sizes,
            height: sizes,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(
                isTablet
                    ? _TabletSizes.titleIconBorderRadius
                    : _PhoneSizes.titleIconBorderRadius,
              ),
            ),
            child: Icon(
              Icons.play_circle_rounded,
              color: scheme.primary,
              size: isTablet
                  ? _TabletSizes.titleIconInnerSize
                  : _PhoneSizes.titleIconInnerSize,
            ),
          ),
          SizedBox(
            width: isTablet
                ? _TabletSizes.titleSpacing
                : _PhoneSizes.titleSpacing,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style:
                        (isTablet
                                ? Theme.of(context).textTheme.headlineMedium
                                : Theme.of(context).textTheme.headlineSmall)
                            ?.copyWith(color: scheme.onSurface),
                    children: [
                      const TextSpan(text: 'Üni'),
                      TextSpan(
                        text: 'TV',
                        style: TextStyle(color: scheme.primary),
                      ),
                    ],
                  ),
                ),
                Text(
                  'KAMPÜS YAYINI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // Tasarımdaki geniş arama çubuğu — yalnızca tablet; tıklayınca
          // Ara sekmesine (index 3) geçirir.
          if (isTablet) ...[
            const SizedBox(width: _TabletSizes.searchGapFromLogo),
            const Expanded(child: _TabletSearchField()),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ═══════════════════════════════════════════════════════════
// TABLET: arama çubuğu (salt okunur; dokunmak Ara sekmesine götürür)
// ═══════════════════════════════════════════════════════════

class _TabletSearchField extends StatelessWidget {
  const _TabletSearchField();

  static const String _hint = 'Video, ders, üniversite veya seminer ara...';

  void _openSearchTab() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTab(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(_TabletSizes.searchBorderRadius),
      onTap: _openSearchTab,
      child: Container(
        height: _TabletSizes.searchHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(_TabletSizes.searchBorderRadius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: _TabletSizes.searchIconSize,
              color: scheme.outline,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.outline,
                  fontSize: _TabletSizes.searchFontSize,
                ),
              ),
            ),
            const SizedBox(width: _TabletSizes.searchHintToShortcutGap),
            // Tasarımdaki ⌘K kısayol rozeti.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _TabletSizes.shortcutBadgePadH,
                vertical: _TabletSizes.shortcutBadgePadV,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '⌘K',
                style: TextStyle(
                  color: scheme.outline,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TABLET: "Radyo Yayını" pill butonu (Radyo sayfasına gider)
// ═══════════════════════════════════════════════════════════

class _RadioLiveButton extends StatelessWidget {
  const _RadioLiveButton({required this.sizes});

  final double sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: () => Get.toNamed(AppRoutes.radio),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _TabletSizes.radioPadH,
            vertical: _TabletSizes.radioPadV,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.podcasts_rounded,
                size: _TabletSizes.radioIconSize,
                color: scheme.primary,
              ),
              const SizedBox(width: _TabletSizes.radioGap),
              Text(
                'Radyo Yayını',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: _TabletSizes.radioFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TABLET: koyu/açık tema geçiş düğmesi
// ───────────────────────────────────────────────────────────
// SettingsController kayıtlıysa tercih hesaba + lokale kaydedilir;
// değilse yalnızca oturumluk değişir (kalıcı tercih Ayarlar > Görünüm'den).
// ═══════════════════════════════════════════════════════════

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? 'Açık Tema' : 'Koyu Tema',
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      onPressed: () {
        final next = isDark ? 'light' : 'dark';
        if (Get.isRegistered<SettingsController>()) {
          Get.find<SettingsController>().changeTheme(next);
        } else {
          Get.changeThemeMode(
            isDark ? ThemeMode.light : ThemeMode.dark,
          );
        }
      },
    );
  }
}
