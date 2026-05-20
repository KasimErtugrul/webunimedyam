import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../controllers/home_controller.dart';

//import '../favorites/favorites_screen.dart';
import 'widgets/tabs/home_tab/home_tab_widget.dart';
import 'widgets/tabs/universities_tab/universities_tab_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: const [
            HomeTabWidget(),
            UniversitiesTabWidget(),
            //FavoritesScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Üniversiteler',
            ),
            /* BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Favoriler',
            ), */
          ],
        ),
      ),
    );
  }
}
