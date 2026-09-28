// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../controllers/home/home_controller.dart';
import '../search/search_screen.dart';
import 'tabs/discovery_tab/discover_tab_widget.dart';
import 'tabs/home_tab/home_tab_widget_phone.dart';
import 'tabs/universities_tab/universities_tab_widget.dart';
import 'widgets/unitv_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Artık tablet ve telefon aynı layout'u kullanıyor:
    // bottom navigation + IndexedStack.
    return const PhoneHomeLayout();
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
