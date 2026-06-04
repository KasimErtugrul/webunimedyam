// lib/presentation/screens/home/widgets/tabs/home_tab/home_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/home_controller.dart';

import 'widgets/video_card_widget.dart';

class HomeTabWidget extends StatefulWidget {
  const HomeTabWidget({super.key});

  @override
  State<HomeTabWidget> createState() => _HomeTabWidgetState();
}

class _HomeTabWidgetState extends State<HomeTabWidget> {
  final controller = Get.find<HomeController>();
  Worker? _authWorker;

  @override
  void initState() {
    super.initState();

    // ── Controller'daki UI Bayraklarını Dinle ──────────────────────────────
    _authWorker = ever(controller.showAuthRequired, (required) {
      if (required) {
        _showAuthDialog();
        controller.showAuthRequired.value = false; // Bayrağı sıfırla
      }
    });
  }

  @override
  void dispose() {
    _authWorker?.dispose(); // Memory leak'i önle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            await controller.refreshVideos();
            await controller.loadPlaylists();
            await controller.loadUniversityStats();
          },
          child: CustomScrollView(
            slivers: [
              // ── AppBar (statik — sadece başlık reaktif) ────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppTheme.bg(context),
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Obx(() => Text(controller.appBarTitle)),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search_rounded, size: 24.sp),
                    onPressed: () => Get.toNamed(AppRoutes.search),
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline_rounded, size: 24.sp),
                    onPressed: () {
                      if (controller.isLoggedIn) {
                        Get.toNamed(AppRoutes.profile);
                      } else {
                        Get.toNamed(AppRoutes.login);
                      }
                    },
                  ),
                ],
              ),

              // ── Video Listesi Başlığı (statik) ───────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                  child: Text(
                    'Son Videolar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.sp,
                    ),
                  ),
                ),
              ),

              // ── İçerik Alanı (tek Obx — sadece bu kısım rebuild olur) ──
              Obx(() => _buildContentSliver(context)),

              // ── Alt Boşluk (statik) ──────────────────────────────────
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reaktif İçerik Seçici ──────────────────────────────────────────────
  Widget _buildContentSliver(BuildContext context) {
    if (controller.isLoading.value) {
      return SliverToBoxAdapter(child: _buildVideoShimmer(context));
    }

    if (controller.errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(child: _buildErrorWidget(context));
    }

    if (controller.videos.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyWidget(context));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => VideoCardWidget(video: controller.videos[index]),
        childCount: controller.videos.length,
      ),
    );
  }

  // ── Hata Widget ────────────────────────────────────────────────────────
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

  // ── Boş Liste Widget ───────────────────────────────────────────────────
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

  // ── Auth Dialog (UI Katmanında Yaşıyor) ────────────────────────────────
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

  // ── Shimmer Yükleniyor ─────────────────────────────────────────────────
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