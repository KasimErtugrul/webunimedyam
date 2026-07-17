// lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../controllers/home_controller.dart';

import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'tabs/discovery_tab/discover_tab_widget.dart';
import 'tabs/home_tab/home_tab_widget.dart';
import 'tabs/universities_tab/universities_tab_widget.dart';

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
    ProfileScreen(),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
