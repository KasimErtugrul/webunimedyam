// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../core/utils/external_navigation.dart';
import '../../controllers/home/home_controller.dart';
import '../search/search_screen.dart';
import 'tabs/discovery_tab/discover_tab_widget.dart';
import 'tabs/home_tab/home_tab_widget_phone.dart';
import 'tabs/home_tab/home_tab_widget_tablet.dart';
import 'tabs/universities_tab/universities_tab_widget.dart';
import 'widgets/unitv_app_bar.dart';
import 'widgets/unitv_web_app_bar.dart';

/// Web düzeninde ana içeriğin taşmayıp ortalanacağı maksimum genişlik.
/// Web barındaki hizayla aynıdır; çok geniş ekranlarda sitenin kenarlara
/// yayılmak yerine (klasik web sitesi gibi) ortalanmış bir sütun oluşturur.
const double _kWebContentMaxWidth = 1600;

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

    // WEB (masaüstü tarayıcı): bottom navigation yerine üst navigasyon
    // barı; bottom nav yalnızca telefon/tablet düzeninde durur.
    if (Responsive.isWeb(context)) {
      return HomeShell(homeTab: homeTab, web: true);
    }
    return HomeShell(homeTab: homeTab, web: false);
  }
}

/// Telefon/tablet ve web'in paylaştığı tek kabuk: AppBar + IndexedStack.
/// Sekmelerin tembel kurulumu (_builtIndices) ve HomeScreenPresence
/// takibi iki düzende de aynıdır; yalnızca appBar/bottomNav seçimi
/// ve (web'de) içeriğin ortalanmış genişlik kapsayıcısı farklıdır.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.homeTab, required this.web});

  /// Ana Sayfa sekmesinin içeriği (telefon/tablet ayrımı HomeScreen'de
  /// yapılır); kabuk ve diğer sekmeler iki cihazda da aynıdır.
  final Widget homeTab;

  /// true: web düzeni (üst bar + ortalanmış içerik, bottom nav YOK).
  final bool web;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final Set<int> _builtIndices = {0};

  @override
  void initState() {
    super.initState();
    HomeScreenPresence.attach();
  }

  @override
  void dispose() {
    HomeScreenPresence.detach();
    super.dispose();
  }

  List<Widget> _buildTabs() {
    return [
      widget.homeTab,
      const DiscoverTabWidget(),
      const UniversitiesTabWidget(),
      const SearchScreen(),
    ];
  }

  Widget _buildIndexedStack() {
    return Obx(() {
      final index = Get.find<HomeController>().selectedIndex.value;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: widget.web ? const UniTvWebAppBar() : const UniTvAppBar(),
      body: widget.web
          // Çok geniş ekranlarda içerik kenarlara yayılmasın: klasik web
          // sitesi düzeni gibi sabit maksimum genişlikte ortalanır. Arka
          // plan tüm genişlikte devam eder.
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: _kWebContentMaxWidth,
                ),
                child: _buildIndexedStack(),
              ),
            )
          : _buildIndexedStack(),
      bottomNavigationBar: widget.web
          ? null
          : Obx(
              () => BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: Get.find<HomeController>().selectedIndex.value,
                onTap: Get.find<HomeController>().changeTab,
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
