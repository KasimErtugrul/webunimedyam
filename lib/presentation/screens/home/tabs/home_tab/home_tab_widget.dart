// lib/presentation/screens/home/widgets/tabs/home_tab/home_tab_widget.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';

import '../../../../controllers/home_controller.dart';
import '../../../../controllers/shorts_controller.dart';

import 'shorts/shorts_row_widget.dart';
import 'widgets/home_feed_wheel_widget.dart';
import 'widgets/video_card_widget.dart';

class HomeTabWidget extends StatefulWidget {
  const HomeTabWidget({super.key});

  @override
  State<HomeTabWidget> createState() => _HomeTabWidgetState();
}

class _HomeTabWidgetState extends State<HomeTabWidget> {
  final controller = Get.find<HomeController>();
  final ScrollController _scrollController = ScrollController();
  Worker? _authWorker;

  // Shorts satırının (yatay liste + ayraç) gerçek yüksekliği.
  // SliverAppBar'ın expandedHeight'ı bu değere göre hesaplanır.
  double get _shortsAreaHeight => 115.h;

  @override
  void initState() {
    super.initState();

    // IndexedStack tüm tab'ları aynı anda build eder, bu yüzden
    // ilk frame render olduktan sonra shorts yükle — ekran görünürken başlasın.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get.find<ShortsController>().loadShorts();
    });

    _scrollController.addListener(_onScroll);

    _authWorker = ever(controller.showAuthRequired, (required) {
      if (required) {
        _showAuthDialog();
        controller.showAuthRequired.value = false;
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      controller.loadMoreVideos();
    }
  }

  // BUG FIX: Sayfa boyu (ör. sadece 5-6 video) ekranı tam doldurmuyorsa
  // scroll extent 0'a yakın kalıyor ve kullanıcı hiç aşağı kaydıramadığı
  // için _onScroll asla tetiklenmiyordu — "10'lu pagination çalışmıyor"
  // hissi buradan geliyordu. Her frame sonunda içerik hâlâ sığıyor mu diye
  // kontrol edip gerekiyorsa otomatik bir sayfa daha çekiyoruz.
  void _maybeAutoLoadMore() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    // Wheel görünümünde bu "kısa ekran" auto-load mantığı uygulanmaz —
    // wheel artık kendi sayfalamasını HomeFeedWheelWidget içinde,
    // wheel index'i sona yaklaştıkça tetikliyor (bkz. home_feed_wheel_widget.dart).
    if (controller.isWheelView.value) return;
    if (!controller.hasMoreVideos.value || controller.isLoadingMore.value) {
      return;
    }
    if (_scrollController.position.maxScrollExtent <= 0) {
      controller.loadMoreVideos();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _authWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoLoadMore());

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            await controller.refreshVideos();
            await controller.loadPlaylists();
            await controller.loadUniversityStats();
            await Get.find<ShortsController>().refresh();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Üst Bar — Logo + Shorts (sabit/scroll appbar) ────────
              SliverAppBar(
                pinned: false,
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppTheme.bg(context),
                automaticallyImplyLeading: false,
                titleSpacing: 16.w,
                toolbarHeight: kToolbarHeight,
                expandedHeight: kToolbarHeight + _shortsAreaHeight,
                actions: [
                  Obx(
                    () => IconButton(
                      icon: Icon(
                        controller.isWheelView.value
                            ? Icons.view_list_rounded
                            : Icons.blur_circular_rounded,
                      ),
                      tooltip: controller.isWheelView.value
                          ? 'Liste Görünümü'
                          : 'Wheel Görünümü',
                      onPressed: controller.toggleWheelView,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.view_carousel_rounded),
                    tooltip: 'Üniversite Radarı',
                    onPressed: () => Get.toNamed(AppRoutes.universityWheel),
                  ),
                  IconButton(
                    icon: const Icon(Icons.radio_rounded),
                    onPressed: () => Get.toNamed(AppRoutes.radio),
                  ),
                ],
                title: Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'ÜniTV',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22.sp,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: EdgeInsets.only(top: kToolbarHeight),
                    child: const ShortsRowWidget(),
                  ),
                ),
              ),

              /* // ── Ayraç ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context).withValues(alpha: 0.35),
                  ),
                ),
              ), */

              // ── İçerik Alanı ───────────────────────────────────────
              Obx(() => _buildContentSliver(context)),

              // ── Alt Boşluk ───────────────────────────────────────────
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSliver(BuildContext context) {
    if (controller.isLoading.value) {
      return SliverToBoxAdapter(child: _buildVideoShimmer(context));
    }

    if (controller.errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(child: _buildErrorWidget(context));
    }

    final nonShorts = controller.videos.where((v) => !v.isShorts).toList();

    if (nonShorts.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyWidget(context));
    }

    // ── Wheel görünümü: aynı veriyi (nonShorts) farklı bir arayüzle
    // gösterir. Ekstra ağ isteği yapılmaz, ekstra video çekilmez.
    if (controller.isWheelView.value) {
      return SliverToBoxAdapter(
        child: HomeFeedWheelWidget(
          videos: nonShorts,
          universities: controller.universities,
        ),
      );
    }

    final showLoader = controller.hasMoreVideos.value;
    // BUG FIX: isLoadingMore burada (Obx'in senkron build çağrısı içinde)
    // okunmazsa, sadece aşağıdaki lazy SliverChildBuilderDelegate builder'ı
    // içinde okunduğu için Obx bunu bir bağımlılık olarak izleyemiyordu —
    // alt kısımdaki yükleniyor göstergesi hiç güncellenmiyordu.
    final isLoadingMore = controller.isLoadingMore.value;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= nonShorts.length) {
          return isLoadingMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }
        log(
          'home tab widget üniversite adları : ${nonShorts[index].universityName}',
        );
        return VideoCardWidget(video: nonShorts[index]);
      }, childCount: nonShorts.length + (showLoader ? 1 : 0)),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.textSec(context),
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            controller.errorMessage.value,
            style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: Size(100.w, 40.h)),
            onPressed: controller.loadVideos,
            child: Text('Tekrar Dene', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: Text(
          'Henüz video yok.',
          style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
        ),
      ),
    );
  }

  void _showAuthDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Giriş Gerekiyor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu özelliği kullanmak için giriş yapmanız gerekiyor.',
          style: TextStyle(color: Color(0xFF9E9EB8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Vazgeç',
              style: TextStyle(color: Color(0xFF9E9EB8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.login);
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 196.h,
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.h,
                          margin: EdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            color: AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14.h,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                height: 14.h,
                                width: 160.w,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                height: 11.h,
                                width: 100.w,
                                color: AppTheme.surface(context),
                              ),
                            ],
                          ),
                        ),
                      ],
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
