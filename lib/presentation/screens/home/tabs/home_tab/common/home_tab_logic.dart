// lib/presentation/screens/home/tabs/home_tab/common/home_tab_logic.dart
//
// Phone ve tablet Home tab'larında BİREBİR AYNI olan state mantığı:
// scroll, sonsuz yükleme, pull-to-refresh, auth ve "Ana Sayfa'ya basınca
// başa dön" worker'ları. Kullanım:
//
//   class _XState extends State<X> with HomeTabLogic {
//     @override
//     HomeTabSizes get sizes => const PhoneHomeTabSizes(); // ya da Tablet
//   }
//
// initState/dispose'u mixin halleder; concrete State override etmez
// (etmesi gerekirse super.initState() çağırmalı).

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../controllers/home/home_controller.dart';
import '../../../../../controllers/shorts_controller.dart';
import '../shorts/shorts_row_widget.dart';
import 'home_tab_sizes.dart';
import 'home_tab_widgets.dart';

mixin HomeTabLogic<T extends StatefulWidget> on State<T> {
  // Her State kendi boyut setini verir (phone / tablet).
  HomeTabSizes get sizes;

  late final HomeController controller = Get.find<HomeController>();

  final ScrollController scrollController = ScrollController();

  // RefreshIndicator'ı kod içinden (kullanıcı parmağıyla çekmeden) de
  // tetikleyebilmek için: "Ana Sayfa"ya tekrar basıldığında hem spinner
  // görünsün hem de gerçek yenileme mantığı çalışsın.
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Worker? _authWorker;
  Worker? _homeResetWorker;

  @mustCallSuper
  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);

    _authWorker = ever(controller.showAuthRequired, (required) {
      if (required) {
        showHomeAuthDialog(sizes);
        controller.showAuthRequired.value = false;
      }
    });

    // BottomNavigationBar'daki "Ana Sayfa"ya basıldığında HomeController
    // bu sinyali artırır; listeyi en üste kaydırıp yenilemeyi tetikleriz.
    _homeResetWorker = ever<int>(controller.homeTabResetSignal, (_) {
      resetToTopAndRefresh();
    });
  }

  @mustCallSuper
  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    _authWorker?.dispose();
    _homeResetWorker?.dispose();
    super.dispose();
  }

  // Pull-to-refresh ile tetiklenen tam yenileme akışı.
  // Önceki analizdeki gibi paralel (Future.wait) açılabilir; davranış
  // değişmesin diye orijinaldeki sıralı await hâli korundu.
  Future<void> refreshHomeTab() async {
    await controller.refreshVideos();
    await controller.loadVideoSections();
    await controller.loadPlaylists();
    await controller.loadUniversityStats();
    await controller.loadContinueWatching();
    await Get.find<ShortsController>().refresh();
  }

  // "Ana Sayfa" sekmesine basıldığında: listeyi en üste kaydır + spinnerla
  // programatik yenileme (pull-to-refresh ile aynı veri akışı).
  void resetToTopAndRefresh() {
    if (!mounted) return;

    if (scrollController.hasClients && scrollController.offset > 0) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      refreshIndicatorKey.currentState?.show();
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      controller.loadMoreVideos();
    }
  }

  // Ekran dolmadan (maxScrollExtent <= 0 iken) ilk sayfayı doldurmak için.
  void maybeAutoLoadMore() {
    if (!mounted) return;
    if (!scrollController.hasClients) return;
    if (controller.isWheelView.value) return;
    if (!controller.hasMoreVideos.value || controller.isLoadingMore.value) {
      return;
    }
    if (scrollController.position.maxScrollExtent <= 0) {
      controller.loadMoreVideos();
    }
  }

  // İçerik sliver'ının ÜSTÜNDEKİ ortak sliver'lar.
  // (Utility bar → Shorts → İzlemeye Devam Et)
  List<Widget> commonSliversBeforeContent() {
    return [
      SliverToBoxAdapter(
        child: HomeUtilityBar(controller: controller, sizes: sizes),
      ),
      const SliverToBoxAdapter(child: ShortsRowWidget()),
      SliverToBoxAdapter(
        child: HomeContinueWatchingSection(
          controller: controller,
          sizes: sizes,
        ),
      ),
    ];
  }

  // İçerik sliver'ının ALTINDAKİ ortak sliver'lar (alt boşluk).
  List<Widget> commonSliversAfterContent() {
    return [SliverToBoxAdapter(child: SizedBox(height: sizes.bottomSpacing))];
  }
}

// Birleşik auth dialog.
// DÜRÜST NOT: Davranış değişikliği — phone kopyası hardcoded koyu renkler
// (0xFF1E1E2E / 0xFF6C63FF) kullanıyor ama login'e GİDİYORDU; tablet kopyası
// tema renklerini kullanıyor ama login'e GİTMİYORDU. Burada ikisinin
// "doğrusu" birleştirildi: tema renkleri + AppRoutes.login'e yönlendirme.
void showHomeAuthDialog(HomeTabSizes sizes) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(sizes.dialogBorderRadius),
      ),
      title: const Text('Giriş Gerekli'),
      content: const Text('Bu özelliği kullanmak için giriş yapman gerekiyor.'),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Vazgeç')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.toNamed(AppRoutes.login);
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(sizes.dialogButtonRadius),
            ),
          ),
          child: const Text('Giriş Yap'),
        ),
      ],
    ),
  );
}
