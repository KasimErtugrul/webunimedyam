// lib/presentation/screens/home/widgets/unitv_web_app_bar.dart
//
// WEB (masaüstü tarayıcı) düzeninin üst barı — bottom navigation'ın
// yerine geçen yatay menü. Bileşenleri:
//
//   [Logo ÜniTV]  [Ana Sayfa · Keşfet · Üniversiteler · Ara]
//   [arama çubuğu]  [Tema | Profil]
//
// - Sekme geçişleri HomeController.changeTab üzerinden yapılır; aktif
//   sekme pill stiliyle vurgulanır (IndexedStack + selectedIndex ile
//   aynı kaynak, yani bottom nav ile birebir aynı davranış).
// - Arama çubuğu tıklanınca Ara sekmesine geçirir (UniTvAppBar'daki
//   tablet davranışının aynısı). Ctrl+K / ⌘K kısayolu main.dart'ta
//   global olarak bağlıdır.
// - Bar Scaffold.appBar olarak sabit kalır; tüm sekmelerde görünür.
// - Radyo/Bildirim düğmeleri kaldırıldı: ilgili sayfalar projeden
//   çıkarıldı (radio_page.dart / notifications rotası kayıtlı değil);
//   ölü '/radio' ve '/notifications' rotalarına gidiyorlardı.

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../controllers/home/home_controller.dart';
import '../../../controllers/settings_controller.dart';

class _WebSizes {
  // Bar
  static const double barHeight = 64;
  static const double contentMaxWidth = 1600;
  static const double horizontalPadding = 24;

  // Logo
  static const double logoIconSize = 36;
  static const double logoIconBorderRadius = 10;
  static const double logoIconInnerSize = 22;
  static const double logoGap = 10;

  // Navigasyon linkleri
  static const double navGap = 4;
  static const double navItemPadH = 14;
  static const double navItemPadV = 8;
  static const double navIconSize = 18;
  static const double navFontSize = 13.5;
  static const double navRadius = 10;
  static const double gapAfterNav = 12;

  // Arama çubuğu
  static const double searchHeight = 40;
  static const double searchBorderRadius = 10;
  static const double searchMaxWidth = 420;
  static const double searchIconSize = 20;
  static const double searchFontSize = 12;
}

class _WebNavItem {
  final int index;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _WebNavItem(this.index, this.label, this.icon, this.activeIcon);
}

const List<_WebNavItem> _kWebNavItems = [
  _WebNavItem(0, 'Ana Sayfa', Icons.home_outlined, Icons.home_rounded),
  _WebNavItem(1, 'Keşfet', Icons.explore_outlined, Icons.explore_rounded),
  _WebNavItem(2, 'Üniversiteler', Icons.school_outlined, Icons.school_rounded),
  _WebNavItem(3, 'Ara', Icons.search_outlined, Icons.search_rounded),
];

/// Web düzeninde bottom navigation'ın yerine geçen üst bar.
class UniTvWebAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UniTvWebAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppTheme.bg(context),
      automaticallyImplyLeading: false,
      toolbarHeight: _WebSizes.barHeight,
      titleSpacing: 0,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _WebSizes.contentMaxWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _WebSizes.horizontalPadding,
            ),
            child: Row(
              children: [
                const _WebLogo(),
                const SizedBox(width: 20),
                const _WebNavLinks(),
                const SizedBox(width: _WebSizes.gapAfterNav),
                const Flexible(child: _WebSearchField()),
                const SizedBox(width: 8),
                const _ThemeToggleButton(),
                IconButton(
                  tooltip: 'Profil',
                  icon: const Icon(Icons.person_rounded),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  onPressed: () => Get.toNamed(AppRoutes.profile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_WebSizes.barHeight);
}

// ═══════════════════════════════════════════════════════════
// Logo (UniTvAppBar ile aynı görsel dil)
// ═══════════════════════════════════════════════════════════

class _WebLogo extends StatelessWidget {
  const _WebLogo();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _WebSizes.logoIconSize,
          height: _WebSizes.logoIconSize,
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(_WebSizes.logoIconBorderRadius),
          ),
          child: Icon(
            Icons.play_circle_rounded,
            color: scheme.primary,
            size: _WebSizes.logoIconInnerSize,
          ),
        ),
        const SizedBox(width: _WebSizes.logoGap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
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
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Yatay sekme linkleri — bottom nav'ın web karşılığı
// ═══════════════════════════════════════════════════════════

class _WebNavLinks extends StatelessWidget {
  const _WebNavLinks();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in _kWebNavItems) ...[
          if (item.index > 0) const SizedBox(width: _WebSizes.navGap),
          _WebNavLink(item: item),
        ],
      ],
    );
  }
}

class _WebNavLink extends StatefulWidget {
  const _WebNavLink({required this.item});

  final _WebNavItem item;

  @override
  State<_WebNavLink> createState() => _WebNavLinkState();
}

class _WebNavLinkState extends State<_WebNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // NOT: Obx, selectedIndex.value'yu KENDİ builder kapanışının içinde
    // okumak zorunda; değer bir alt widget'ın build'inde okunursa GetX
    // "improper use of Obx" hatası fırlatır (release'de gri kutu).
    return Obx(() {
      final controller = Get.find<HomeController>();
      final selected = controller.selectedIndex.value == widget.item.index;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: _WebSizes.navItemPadH,
            vertical: _WebSizes.navItemPadV,
          ),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.12)
                : _hovered
                ? scheme.surfaceContainerHigh.withValues(alpha: 0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(_WebSizes.navRadius),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(_WebSizes.navRadius),
            onTap: () => controller.changeTab(widget.item.index),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? widget.item.activeIcon : widget.item.icon,
                  size: _WebSizes.navIconSize,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: _WebSizes.navFontSize,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════
// Arama çubuğu (tıklayınca Ara sekmesine geçirir)
// ═══════════════════════════════════════════════════════════

class _WebSearchField extends StatelessWidget {
  const _WebSearchField();

  static const String _hint = 'Video, ders, üniversite veya seminer ara...';

  /// Rozet etiketi: macOS/iOS'ta ⌘K, diğer platformlarda Ctrl K.
  static String get _shortcutLabel =>
      defaultTargetPlatform == TargetPlatform.macOS ? '⌘K' : 'Ctrl K';

  void _openSearchTab() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTab(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _WebSizes.searchMaxWidth),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            borderRadius: BorderRadius.circular(_WebSizes.searchBorderRadius),
            onTap: _openSearchTab,
            child: Container(
              height: _WebSizes.searchHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(
                  _WebSizes.searchBorderRadius,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: _WebSizes.searchIconSize,
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
                        fontSize: _WebSizes.searchFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _shortcutLabel,
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
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Koyu/açık tema düğmesi (UniTvAppBar'dakiyle aynı davranış)
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
          Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
        }
      },
    );
  }
}
