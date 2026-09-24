// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
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
    HomeTabWidget(),
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
// GENİŞLİK, o da artık burada sabit değil; build() içinde LayoutBuilder'dan
// gelen gerçek ekran genişliğine göre hesaplanıyor (bkz. TabletHomeLayout).
class _TabletSidebarSizes {
  // Sadece bu ikisi (+ fraction) veriliyor — gerçek hesaplama
  // Responsive.clampedFraction() içinde, tek yerde yapılıyor.
  static const double minWidth = 220;
  static const double maxWidth = 300;
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
    HomeTabWidget(),
    DiscoverTabWidget(),
    UniversitiesTabWidget(),
    SearchScreen(),
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
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // Drawer artık gerçek bir overlay: Scaffold.drawer'a bağlı, kayarak
    // açılıp kapanıyor. Scaffold, appBar VE drawer aynı anda verildiğinde
    // hamburger ikonunu appBar'ın leading'ine KENDİSİ otomatik ekler —
    // elle bir IconButton yazmaya gerek yok.
    //
    // sidebarWidth artık bir LayoutBuilder'a değil MediaQuery'ye bağlı,
    // çünkü Drawer artık Row'un kısıtlı bir çocuğu değil, tüm ekranı
    // kaplayan bir overlay — yani "gerçekten ayrılan alan" burada zaten
    // ekranın tamamı.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sidebarWidth = Responsive.clampedFraction(
      screenWidth,
      fraction: _TabletSidebarSizes.widthFraction,
      min: _TabletSidebarSizes.minWidth,
      max: _TabletSidebarSizes.maxWidth,
    );

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        title: const Text('ÜniTV'),
      ),
      drawer: Drawer(
        width: sidebarWidth,
        child: Column(
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
                    children: List.generate(_items.length, (i) {
                      return _SideNavItem(
                        data: _items[i],
                        selected: selected == i,
                        onTap: () {
                          controller.changeTab(i);
                          // Bir item seçilince drawer otomatik kapanır —
                          // gerçek drawer davranışının beklenen kısmı.
                          Navigator.of(context).pop();
                        },
                      );
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
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

/* // lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../controllers/home/home_controller.dart';
/* import '../profile/profile_screen.dart';
 */
import '../search/search_screen.dart';
import 'tabs/discovery_tab/discover_tab_widget.dart';
import 'tabs/home_tab/home_tab_widget.dart';
import 'tabs/universities_tab/universities_tab_widget.dart';
import 'widgets/unitv_app_bar.dart';

// FIX: StatelessWidget -> StatefulWidget.
//
// Önceki kodda IndexedStack'in `children` listesi TÜM 5 sekme widget'ını
// (HomeTabWidget, DiscoverTabWidget, UniversitiesTabWidget, SearchScreen,
// ProfileScreen) HomeScreen ilk build edildiği anda inşa ediyordu. IndexedStack
// sadece görünürlüğü index'e göre gizler, ama seçili olmayan child'ları da
// widget ağacından ÇIKARMAZ — hepsi anında mount olur, initState()'leri
// (dolayısıyla GetX controller'larının onInit()'leri) hemen tetiklenir.
//
// Sonuç: kullanıcı hâlâ "Ana Sayfa" sekmesindeyken bile Profil ve Keşfet
// sekmelerinin controller'ları (ProfileController, ShortsController vb.)
// zaten oluşturulmuş oluyordu ve bu da kullanıcı o sekmelere hiç girmeden
// get_my_stats / get_shorts_per_university gibi gereksiz Supabase
// isteklerine yol açıyordu.
//
// Çözüm: her sekme yalnızca en az BİR KEZ seçildiğinde gerçek widget'ıyla
// inşa edilir (_builtIndices). Henüz ziyaret edilmemiş sekmeler için ucuz
// bir placeholder (SizedBox.shrink) döner — bottomNavigationBar'a tıklayıp
// o sekmeye ilk kez girildiğinde gerçek widget mount olur ve verisini o an
// çeker. Bir sekme bir kez ziyaret edildikten sonra IndexedStack sayesinde
// "canlı" kalmaya devam eder (geri dönüldüğünde yeniden fetch atmaz).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Ana Sayfa (index 0) uygulama açılışında zaten görünür sekme olduğu
  // için baştan "ziyaret edilmiş" sayılır; diğerleri kullanıcı sekmeye
  // dokununca bu sete eklenir.
  final Set<int> _builtIndices = {0};

  static const List<Widget> _tabs = [
    HomeTabWidget(),
    DiscoverTabWidget(),
    UniversitiesTabWidget(),
    SearchScreen(),
    /*     ProfileScreen(),
 */
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // Scaffold artık Obx dışında — yalnızca bir kez build edilir.
    // Sadece reaktif olan body (IndexedStack) ve bottomNavigationBar kendi Obx'leri içinde sarılır.
    //
    // Arama ve Profil ekranları artık ayrı bir route'a push edilmiyor;
    // IndexedStack'in 4. ve 5. sekmesi olarak burada yer alıyor.
    // Bu sayede bottomNavigationBar her zaman görünür kalır.
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      // "ÜniTV / KAMPÜS YAYINI" barı artık burada, en dıştaki Scaffold'a
      // ait — bu sayede IndexedStack'teki sekme (index) değişse bile
      // appBar yeniden build edilmez ve TÜM sekmelerde sabit kalır.
      appBar: const UniTvAppBar(),
      body: Obx(() {
        final index = controller.selectedIndex.value;
        // Seçilen sekme "ziyaret edildi" olarak işaretlenir; bir sonraki
        // build'de o index artık placeholder değil gerçek widget'ı döner.
        _builtIndices.add(index);

        return IndexedStack(
          index: index,
          children: List.generate(_tabs.length, (i) {
            if (!_builtIndices.contains(i)) {
              // Henüz hiç ziyaret edilmemiş sekme: controller'ı KURMA,
              // veri çekme — kullanıcı gerçekten o sekmeye geçene kadar.
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
            /*  BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ), */
          ],
        ),
      ),
    );
  }
}
 */
