// lib/presentation/screens/home/widgets/tabs/home_tab/shorts/shorts_row_widget.dart
//
// FIX: Shorts artık yayınlanma tarihine göre gösterilir (en yeni önce).
// Her üniversitenin en son yüklediği short önce gelir.
// Sonsuz döngüyü önlemek için cache kullanılmaz — her açılışta taze veri.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/shorts_model.dart';
import '../../../../../controllers/shorts_controller.dart';

class ShortsRowWidget extends StatefulWidget {
  const ShortsRowWidget({super.key});

  @override
  State<ShortsRowWidget> createState() => _ShortsRowWidgetState();
}

class _ShortsRowWidgetState extends State<ShortsRowWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Sona ~200px kala bir sonraki 10'luk sayfayı önceden yükle.
    if (position.pixels >= position.maxScrollExtent - 200) {
      Get.find<ShortsController>().loadMoreShorts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmer(context);
      }

      if (controller.shorts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Yatay Kaydırma Listesi ───────────────────────────────────
          SizedBox(
            height: 110.h,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              // hasMore true ise sona bir loading item ekleniyor.
              itemCount:
                  controller.shorts.length + (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= controller.shorts.length) {
                  return _LoadMoreIndicator(
                    isLoading: controller.isLoadingMore.value,
                  );
                }
                return _ShortsThumbItem(
                  shorts: controller.shorts[index],
                  initialIndex: index,
                  allShorts: controller.shorts,
                );
              },
            ),
          ),

          // SizedBox(height: 8.h),

          /*  // ── Ayraç ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(
              color: AppTheme.surface(context),
              thickness: 1,
              height: 1,
            ),
          ), */

          //SizedBox(height: 4.h),
        ],
      );
    });
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: SizedBox(
        height: 140.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          itemCount: 6,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 56.w,
                  height: 10.h,
                  color: AppTheme.surface(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sayfalama Yükleniyor Göstergesi ──────────────────────────────────────

class _LoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  const _LoadMoreIndicator({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w,
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

// ─── Tek bir shorts öğesi ────────────────────────────────────────────────────

class _ShortsThumbItem extends StatelessWidget {
  final ShortsModel shorts;
  final int initialIndex;
  final List<ShortsModel> allShorts;

  const _ShortsThumbItem({
    required this.shorts,
    required this.initialIndex,
    required this.allShorts,
  });

  @override
  Widget build(BuildContext context) {
    // timeago Türkçe locale desteği
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final timeAgo = timeago.format(shorts.publishedAt, locale: 'tr');

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.shortsPlayer,
          arguments: {'shorts': allShorts, 'initialIndex': initialIndex},
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Avatar: Thumbnail + Logo overlay ─────────────────────
            SizedBox(
              width: 68.w,
              height: 68.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Dış halka (gradient ring)
                  Container(
                    width: 68.w,
                    height: 68.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1DB954), Color(0xFF0A84FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.bg(context),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: shorts.bestThumbnail,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF1A1A1A),
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Üniversite logosu (sağ alt)
                  if (shorts.logoUrl != null && shorts.logoUrl!.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppTheme.bg(context),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: shorts.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.school, size: 12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 5.h),

            // ── Üniversite adı (kısaltılmış) ─────────────────────────
            SizedBox(
              width: 72.w,
              child: Text(
                _shortName(shorts.universityName),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSec(context),
                  height: 1.2,
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // ── Yayınlanma tarihi (timeago) ───────────────────────────
            SizedBox(
              width: 72.w,
              child: Text(
                timeAgo,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.sp,
                  color: AppTheme.textSec(context).withOpacity(0.6),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Atatürk Üniversitesi" → "Atatürk Üni."
  String _shortName(String name) {
    return name
        .replaceAll('Üniversitesi', 'Üni.')
        .replaceAll('Teknik Üniversitesi', 'T.Ü.')
        .replaceAll('Vakıf Üniversitesi', 'V.Ü.');
  }
}