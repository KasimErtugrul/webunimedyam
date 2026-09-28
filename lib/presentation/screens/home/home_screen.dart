// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/home/home_controller.dart';
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
    // Tablet ve telefon aynı kabuğu (bottom navigation + IndexedStack)
    // kullanıyor; yalnızca Ana Sayfa sekmesinin içeriği cihaz sınıfına
    // göre ayrışıyor. Telefon tarafı HomeTabWidgetPhone — hiç değişmedi.
    final homeTab = Responsive.isTablet(context)
        ? const HomeTabWidgetTablet()
        : const HomeTabWidgetPhone();
    return PhoneHomeLayout(homeTab: homeTab);
  }
}

class PhoneHomeLayout extends StatefulWidget {
  const PhoneHomeLayout({super.key, required this.homeTab});

  /// Ana Sayfa sekmesinin içeriği (telefon/tablet ayrımı HomeScreen'de
  /// yapılır); kabuk ve diğer sekmeler iki cihazda da aynıdır.
  final Widget homeTab;

  @override
  State<PhoneHomeLayout> createState() => _PhoneHomeLayoutState();
}

class _PhoneHomeLayoutState extends State<PhoneHomeLayout> {
  final Set<int> _builtIndices = {0};

  List<Widget> _buildTabs() {
    return [
      widget.homeTab,
      const DiscoverTabWidget(),
      const UniversitiesTabWidget(),
      const SearchScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: const UniTvAppBar(),
      body: Obx(() {
        final index = controller.selectedIndex.value;
        _builtIndices.add(index);
        final tabs = _buildTabs();

        return IndexedStack(
          index: index,
          children: List.generate(tabs.length, (i) {
            if (!_builtIndices.contains(i)) {
              return const SizedBox.shrink();
            }
            return tabs[i];
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
