/* // lib/presentation/screens/home/tabs/home_tab/widgets/followed_universities_row_widget.dart
//
// TAKİP ETTİĞİN ÜNİVERSİTELER — YATAY KAYDIRMALI ŞERİT
// ─────────────────────────────────────────────────────────────────────────
// Amaç: Kullanıcının takip ettiği üniversitelerin son videolarını ana
// sayfada, kişiselleştirilmiş bir şerit olarak öne çıkarmak.
//
// PERFORMANS NOTU (güncellendi):
// İlk versiyonda bu widget `controller.videos` (ana feed, sayfalanmış)
// listesini client-side filtreliyordu — sıfır ekstra sorgu ama ciddi bir
// kusuru vardı: takip edilen bir üniversitenin son videosu ana feed'in
// henüz yüklenmemiş bir sonraki sayfasında kalırsa şeritte GÖRÜNMÜYORDU
// (gerçek kullanımda tespit edildi — bkz. HomeController.
// loadFollowedUniversitiesVideos).
//
// Artık `controller.followedUniversitiesVideos` kullanılıyor: bu liste
// `VideoRepository.getVideosByUniversityIds()` ile TEK bir Supabase
// sorgusuyla (N+1 değil, `university_id IN (...)`) besleniyor ve
// kullanıcı takip listesini değiştirdiğinde (`_uniFavSubscription`)
// otomatik yenileniyor. Yani hâlâ "üniversite başına ayrı sorgu" yok,
// ama artık ana feed'in sayfalama sınırına da bağımlı değil.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../controllers/home_controller.dart';
import 'video_grid_card_widget.dart';

class _PhoneSizes {
  static const double titlePaddingLeft = 16;
  static const double titlePaddingTop = 4;
  static const double titlePaddingRight = 16;
  static const double titlePaddingBottom = 12;
  static const double titleFontSize = 16;
  static const double subtitleFontSize = 12.5;
  static const double titleSubtitleSpacing = 2;

  static const double listHeight = 250;
  static const double listPaddingHorizontal = 16;
  static const double cardWidth = 170;
  static const double cardSpacing = 12;
}

class _TabletSizes {
  static const double titlePaddingLeft = 20;
  static const double titlePaddingTop = 6;
  static const double titlePaddingRight = 20;
  static const double titlePaddingBottom = 14;
  static const double titleFontSize = 20;
  static const double subtitleFontSize = 14;
  static const double titleSubtitleSpacing = 4;

  static const double listHeight = 290;
  static const double listPaddingHorizontal = 20;
  static const double cardWidth = 210;
  static const double cardSpacing = 16;
}

class FollowedUniversitiesRowWidget extends StatelessWidget {
  const FollowedUniversitiesRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.favoriteUniversityIds.isEmpty) {
        return const SizedBox.shrink();
      }

      final items = controller.followedUniversitiesVideos;
      final isLoading = controller.isFollowedUniversitiesVideosLoading.value;

      if (!isLoading && items.isEmpty) return const SizedBox.shrink();

      return Responsive.isTablet(context)
          ? _buildTablet(context, items)
          : _buildPhone(context, items);
    });
  }

  // ═══════════════════════════════════════════════════════════
  // PHONE
  // ═══════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            _PhoneSizes.titlePaddingLeft.w,
            _PhoneSizes.titlePaddingTop.h,
            _PhoneSizes.titlePaddingRight.w,
            _PhoneSizes.titlePaddingBottom.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎓 Takip Ettiklerin',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.titleFontSize.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: _PhoneSizes.titleSubtitleSpacing.h),
                    Text(
                      'Takip ettiğin üniversitelerden son paylaşımlar',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _PhoneSizes.subtitleFontSize.sp,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    Get.toNamed(AppRoutes.followedUniversitiesList),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _PhoneSizes.listHeight.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.listPaddingHorizontal.w,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                SizedBox(width: _PhoneSizes.cardSpacing.w),
            itemBuilder: (context, index) {
              return SizedBox(
                width: _PhoneSizes.cardWidth.w,
                child: VideoGridCardWidget(video: items[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TABLET
  // ═══════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            _TabletSizes.titlePaddingLeft,
            _TabletSizes.titlePaddingTop,
            _TabletSizes.titlePaddingRight,
            _TabletSizes.titlePaddingBottom,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎓 Takip Ettiklerin',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _TabletSizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: _TabletSizes.titleSubtitleSpacing),
                    Text(
                      'Takip ettiğin üniversitelerden son paylaşımlar',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _TabletSizes.subtitleFontSize,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    Get.toNamed(AppRoutes.followedUniversitiesList),
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _TabletSizes.listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: _TabletSizes.listPaddingHorizontal,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: _TabletSizes.cardSpacing),
            itemBuilder: (context, index) {
              return SizedBox(
                width: _TabletSizes.cardWidth,
                child: VideoGridCardWidget(video: items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
} */