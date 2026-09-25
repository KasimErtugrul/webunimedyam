// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/home/home_controller.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'tabs/discovery_tab/discover_tab_widget.dart';
import 'tabs/home_tab/home_tab_widget_phone.dart';
import 'tabs/home_tab/home_tab_widget_tablet.dart';
import 'tabs/universities_tab/universities_tab_widget.dart';
import 'widgets/unitv_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Responsive.isTablet(context)
        ? const TabletHomeLayout()
        : const PhoneHomeLayout();
  }
}

class PhoneHomeLayout extends StatefulWidget {
  const PhoneHomeLayout({super.key});

  @override
  State<PhoneHomeLayout> createState() => _PhoneHomeLayoutState();
}

class _PhoneHomeLayoutState extends State<PhoneHomeLayout> {
  final Set<int> _builtIndices = {0};

  static const List<Widget> _tabs = [
    HomeTabWidgetPhone(),
    DiscoverTabWidget(),
    UniversitiesTabWidget(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: const UniTvAppBar(),
      body: Obx(() {
        final index = controller.selectedIndex.value;
        _builtIndices.add(index);

        return IndexedStack(
          index: index,
          children: List.generate(_tabs.length, (i) {
            if (!_builtIndices.contains(i)) {
              return const SizedBox.shrink();
            }
            return _tabs[i];
          }),
        );
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Keşfet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Üniversiteler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Ara',
            ),
          ],
        ),
      ),
    );
  }
}

// Yükseklik/padding gibi değerler sabit dp kalıyor — tablet-tablet arası
// dokunma hedefi farkı ihmal edilebilir. Taşma riski olan tek boyut
// GENİŞLİK, o da artık burada sabit değil; build() içinde MediaQuery'den
// gelen gerçek ekran genişliğine göre hesaplanıyor (bkz. TabletHomeLayout).
class _TabletSidebarSizes {
  // Sadece bu ikisi (+ fraction) veriliyor — gerçek hesaplama
  // Responsive.clampedFraction() içinde, tek yerde yapılıyor.
  static const double minWidth = 200;
  static const double maxWidth = 250;
  static const double widthFraction = 0.22;
  static const double logoBoxSize = 36;
  static const double logoBorderRadius = 10;
  static const double logoIconSize = 22;
  static const double itemHeight = 52;
  static const double itemHorizontalPadding = 16;
  static const double itemIconSpacing = 14;
  static const double itemIconSize = 22;
  static const double itemBorderRadius = 12;
  static const double headerLogoSpacing = 10;
  static const double headerBottomSpacing = 8;
  static const double hairlineThickness = 1;
  static const double itemFontSize = 15;
}

class TabletHomeLayout extends StatefulWidget {
  const TabletHomeLayout({super.key});

  @override
  State<TabletHomeLayout> createState() => _TabletHomeLayoutState();
}

class _TabletHomeLayoutState extends State<TabletHomeLayout> {
  final Set<int> _builtIndices = {0};

  static const List<Widget> _tabs = [
    HomeTabWidgetTablet(),
    DiscoverTabWidget(),
    UniversitiesTabWidget(),
    SearchScreen(),
    ProfileScreen(), // Profile tab is included for tablet layout
  ];

  static const List<_SideNavItemData> _items = [
    _SideNavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Ana Sayfa',
    ),
    _SideNavItemData(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Keşfet',
    ),
    _SideNavItemData(
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'Üniversiteler',
    ),
    _SideNavItemData(
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      label: 'Ara',
    ),
    _SideNavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // Drawer kaldırıldı. Sidebar artık Row içinde sabit bir sütun,
    // içerik ise sağ tarafta Expanded ile genişliyor. Sidebar genişliği
    // hâlâ MediaQuery'den hesaplanıyor (tablet-tablet arası fark).
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sidebarWidth = Responsive.clampedFraction(
      screenWidth,
      fraction: _TabletSidebarSizes.widthFraction,
      min: _TabletSidebarSizes.minWidth,
      max: _TabletSidebarSizes.maxWidth,
    );

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: sidebarWidth,
              child: _TabletSidebar(controller: controller, items: _items),
            ),
            const VerticalDivider(
              width: _TabletSidebarSizes.hairlineThickness,
              thickness: _TabletSidebarSizes.hairlineThickness,
            ),
            Expanded(
              child: Scaffold(
                backgroundColor: AppTheme.bg(context),
                appBar: AppBar(
                  backgroundColor: AppTheme.bg(context),
                  elevation: 0,
                  title: const Text('ÜniTV'),
                ),
                body: Obx(() {
                  final index = controller.selectedIndex.value;
                  _builtIndices.add(index);

                  return IndexedStack(
                    index: index,
                    children: List.generate(_tabs.length, (i) {
                      if (!_builtIndices.contains(i)) {
                        return const SizedBox.shrink();
                      }
                      return _tabs[i];
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletSidebar extends StatelessWidget {
  final HomeController controller;
  final List<_SideNavItemData> items;

  const _TabletSidebar({required this.controller, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SidebarHeader(),
        const Divider(height: _TabletSidebarSizes.hairlineThickness),
        const SizedBox(height: _TabletSidebarSizes.headerBottomSpacing),
        // SingleChildScrollView: ileride menüye daha fazla item
        // eklenirse (ör. Profil geri gelirse) kısa boylu bir
        // tablette dikey taşma yerine kayar.
        Expanded(
          child: SingleChildScrollView(
            child: Obx(() {
              final selected = controller.selectedIndex.value;
              return Column(
                children: List.generate(items.length, (i) {
                  return _SideNavItem(
                    data: items[i],
                    selected: selected == i,
                    onTap: () => controller.changeTab(i),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Container(
            width: _TabletSidebarSizes.logoBoxSize,
            height: _TabletSidebarSizes.logoBoxSize,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(
                _TabletSidebarSizes.logoBorderRadius,
              ),
            ),
            child: Icon(
              Icons.play_circle_rounded,
              color: scheme.primary,
              size: _TabletSidebarSizes.logoIconSize,
            ),
          ),
          const SizedBox(width: _TabletSidebarSizes.headerLogoSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _SideNavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _SideNavItem extends StatelessWidget {
  final _SideNavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          _TabletSidebarSizes.itemBorderRadius,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            _TabletSidebarSizes.itemBorderRadius,
          ),
          child: Container(
            height: _TabletSidebarSizes.itemHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: _TabletSidebarSizes.itemHorizontalPadding,
            ),
            child: Row(
              children: [
                Icon(
                  selected ? data.activeIcon : data.icon,
                  color: color,
                  size: _TabletSidebarSizes.itemIconSize,
                ),
                const SizedBox(width: _TabletSidebarSizes.itemIconSpacing),
                Text(
                  data.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontSize: _TabletSidebarSizes.itemFontSize,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
