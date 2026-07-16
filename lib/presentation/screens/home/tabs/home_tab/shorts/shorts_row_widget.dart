// lib/presentation/screens/home/tabs/home_tab/shorts/shorts_row_widget.dart
//
// TASARIM DEĞİŞİKLİĞİ: Instagram Story tarzı (yuvarlak avatar + halka)
// yerine TikTok/Shorts benzeri DİKEY KART tasarımına geçildi.
// Her kart: tam kaplayan thumbnail + alt kısımda gradient üzerine
// üniversite logosu + başlık + yayın tarihi.
//
// RESPONSIVE NOT: Phone ve tablet için TAMAMEN AYRI sabitler ve kart
// widget'ları var (_PhoneSizes / _TabletSizes, _ShortsThumbItemPhone /
// _ShortsThumbItemTablet). ScreenUtil SADECE phone tarafında kullanılıyor.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/shorts_model.dart';
import '../../../../../controllers/shorts_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

/// Phone için sabitler. ScreenUtil (.w/.h/.sp) ile çarpılıyor.
class _PhoneSizes {
  // Satır / kart
  static const double rowHeight = 185;
  static const double cardWidth = 104;
  static const double cardHeight = 185;
  static const double cardMarginRight = 10;
  static const double cardBorderRadius = 12;
  static const double listPaddingHorizontal = 12;

  // Gradient + üst rozet
  static const double gradientHeight = 72;
  static const double durationTop = 6;
  static const double durationRight = 6;
  static const double durationPaddingHorizontal = 5;
  static const double durationPaddingVertical = 2;
  static const double durationBorderRadius = 4;
  static const double durationFontSize = 8;

  // Alt içerik (logo + başlık + tarih)
  static const double contentPaddingHorizontal = 7;
  static const double contentPaddingBottom = 7;
  static const double logoSize = 18;
  static const double logoBorder = 1.2;
  static const double logoTitleSpacing = 5;
  static const double uniNameFontSize = 8;
  static const double rowToTitleSpacing = 4;
  static const double titleFontSize = 9.5;
  static const double titleLineHeight = 1.2;
  static const double titleToTimeSpacing = 3;
  static const double timeAgoFontSize = 7.5;

  // Placeholder
  static const double placeholderIconSize = 26;
}

/// Tablet için sabitler. ScreenUtil'e HİÇ dokunmuyor — direkt piksel.
class _TabletSizes {
  static const double rowHeight = 220;
  static const double cardWidth = 124;
  static const double cardHeight = 220;
  static const double cardMarginRight = 12;
  static const double cardBorderRadius = 14;
  static const double listPaddingHorizontal = 24;

  static const double gradientHeight = 86;
  static const double durationTop = 8;
  static const double durationRight = 8;
  static const double durationPaddingHorizontal = 6;
  static const double durationPaddingVertical = 3;
  static const double durationBorderRadius = 5;
  static const double durationFontSize = 9;

  static const double contentPaddingHorizontal = 9;
  static const double contentPaddingBottom = 9;
  static const double logoSize = 22;
  static const double logoBorder = 1.4;
  static const double logoTitleSpacing = 6;
  static const double uniNameFontSize = 9.5;
  static const double rowToTitleSpacing = 5;
  static const double titleFontSize = 11.5;
  static const double titleLineHeight = 1.25;
  static const double titleToTimeSpacing = 4;
  static const double timeAgoFontSize = 9;

  static const double placeholderIconSize = 30;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

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
    if (position.pixels >= position.maxScrollExtent - 200) {
      Get.find<ShortsController>().loadMoreShorts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortsController>();

    return Obx(() {
      if (controller.isLoading.value) {
        // ── TEK DALLANMA NOKTASI ────────────────────────────────────
        return Responsive.isTablet(context)
            ? _buildTabletShimmer(context)
            : _buildPhoneShimmer(context);
      }

      if (controller.shorts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Responsive.isTablet(context)
          ? _tablet(context, controller)
          : _phone(context, controller);
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI
  // ═══════════════════════════════════════════════════════════════════════

  Widget _phone(BuildContext context, ShortsController controller) {
    return SizedBox(
      height: _PhoneSizes.rowHeight.h,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.listPaddingHorizontal.w,
        ),
        itemCount: controller.shorts.length + (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.shorts.length) {
            return _PhoneLoadMoreIndicator(
              isLoading: controller.isLoadingMore.value,
            );
          }
          return _ShortsThumbItemPhone(
            shorts: controller.shorts[index],
            initialIndex: index,
            allShorts: controller.shorts,
          );
        },
      ),
    );
  }

  Widget _buildPhoneShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: SizedBox(
        height: _PhoneSizes.rowHeight.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: _PhoneSizes.listPaddingHorizontal.w,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
            width: _PhoneSizes.cardWidth.w,
            height: _PhoneSizes.cardHeight.h,
            margin: EdgeInsets.only(right: _PhoneSizes.cardMarginRight.w),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(
                _PhoneSizes.cardBorderRadius.r,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _tablet(BuildContext context, ShortsController controller) {
    return SizedBox(
      height: _TabletSizes.rowHeight,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: _TabletSizes.listPaddingHorizontal,
        ),
        itemCount: controller.shorts.length + (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.shorts.length) {
            return _TabletLoadMoreIndicator(
              isLoading: controller.isLoadingMore.value,
            );
          }
          return _ShortsThumbItemTablet(
            shorts: controller.shorts[index],
            initialIndex: index,
            allShorts: controller.shorts,
          );
        },
      ),
    );
  }

  Widget _buildTabletShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: SizedBox(
        height: _TabletSizes.rowHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: _TabletSizes.listPaddingHorizontal,
          ),
          itemCount: 8,
          itemBuilder: (_, __) => Container(
            width: _TabletSizes.cardWidth,
            height: _TabletSizes.cardHeight,
            margin: const EdgeInsets.only(right: _TabletSizes.cardMarginRight),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(
                _TabletSizes.cardBorderRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// SAYFALAMA YÜKLENİYOR GÖSTERGESİ — phone / tablet ayrı
// ═══════════════════════════════════════════════════════════════════════

class _PhoneLoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  const _PhoneLoadMoreIndicator({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.w,
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

class _TabletLoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  const _TabletLoadMoreIndicator({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
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

// ═══════════════════════════════════════════════════════════════════════
// TEK BİR SHORTS KARTI — PHONE (Dikey kart, TikTok/Shorts tarzı)
// ═══════════════════════════════════════════════════════════════════════

class _ShortsThumbItemPhone extends StatelessWidget {
  final ShortsModel shorts;
  final int initialIndex;
  final List<ShortsModel> allShorts;

  const _ShortsThumbItemPhone({
    required this.shorts,
    required this.initialIndex,
    required this.allShorts,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final timeAgo = timeago.format(shorts.publishedAt, locale: 'tr');

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.shortsPlayer,
        arguments: {'shorts': allShorts, 'initialIndex': initialIndex},
      ),
      child: Container(
        width: _PhoneSizes.cardWidth.w,
        height: _PhoneSizes.cardHeight.h,
        margin: EdgeInsets.only(right: _PhoneSizes.cardMarginRight.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: shorts.bestThumbnail,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _placeholder(context),
              placeholder: (_, __) => _shimmerBox(context),
            ),

            // Alt gradient (metin okunabilirliği için)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _PhoneSizes.gradientHeight.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Süre rozeti — sağ üst
            if (shorts.duration.isNotEmpty)
              Positioned(
                top: _PhoneSizes.durationTop.h,
                right: _PhoneSizes.durationRight.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _PhoneSizes.durationPaddingHorizontal.w,
                    vertical: _PhoneSizes.durationPaddingVertical.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(
                      _PhoneSizes.durationBorderRadius.r,
                    ),
                  ),
                  child: Text(
                    _formatDuration(shorts.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _PhoneSizes.durationFontSize.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Alt içerik: logo + üniversite adı + başlık + tarih
            Positioned(
              left: _PhoneSizes.contentPaddingHorizontal.w,
              right: _PhoneSizes.contentPaddingHorizontal.w,
              bottom: _PhoneSizes.contentPaddingBottom.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: _PhoneSizes.logoSize.w,
                        height: _PhoneSizes.logoSize.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: _PhoneSizes.logoBorder,
                          ),
                        ),
                        child: ClipOval(
                          child: (shorts.logoUrl != null && shorts.logoUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: shorts.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.school, size: 10),
                                )
                              : const Icon(Icons.school, size: 10),
                        ),
                      ),
                      SizedBox(width: _PhoneSizes.logoTitleSpacing.w),
                      Expanded(
                        child: Text(
                          shorts.universityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: _PhoneSizes.uniNameFontSize.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _PhoneSizes.rowToTitleSpacing.h),
                  Text(
                    shorts.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _PhoneSizes.titleFontSize.sp,
                      fontWeight: FontWeight.w700,
                      height: _PhoneSizes.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: _PhoneSizes.titleToTimeSpacing.h),
                  Text(
                    timeAgo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: _PhoneSizes.timeAgoFontSize.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: _PhoneSizes.placeholderIconSize.sp,
    ),
  );

  Widget _shimmerBox(BuildContext context) =>
      Container(color: AppTheme.surface(context));
}

// ═══════════════════════════════════════════════════════════════════════
// TEK BİR SHORTS KARTI — TABLET (ayrı, sabit sayılarla)
// ═══════════════════════════════════════════════════════════════════════

class _ShortsThumbItemTablet extends StatelessWidget {
  final ShortsModel shorts;
  final int initialIndex;
  final List<ShortsModel> allShorts;

  const _ShortsThumbItemTablet({
    required this.shorts,
    required this.initialIndex,
    required this.allShorts,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final timeAgo = timeago.format(shorts.publishedAt, locale: 'tr');

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.shortsPlayer,
        arguments: {'shorts': allShorts, 'initialIndex': initialIndex},
      ),
      child: Container(
        width: _TabletSizes.cardWidth,
        height: _TabletSizes.cardHeight,
        margin: const EdgeInsets.only(right: _TabletSizes.cardMarginRight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: shorts.bestThumbnail,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _placeholder(context),
              placeholder: (_, __) => _shimmerBox(context),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _TabletSizes.gradientHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            if (shorts.duration.isNotEmpty)
              Positioned(
                top: _TabletSizes.durationTop,
                right: _TabletSizes.durationRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _TabletSizes.durationPaddingHorizontal,
                    vertical: _TabletSizes.durationPaddingVertical,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(
                      _TabletSizes.durationBorderRadius,
                    ),
                  ),
                  child: Text(
                    _formatDuration(shorts.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _TabletSizes.durationFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: _TabletSizes.contentPaddingHorizontal,
              right: _TabletSizes.contentPaddingHorizontal,
              bottom: _TabletSizes.contentPaddingBottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: _TabletSizes.logoSize,
                        height: _TabletSizes.logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: _TabletSizes.logoBorder,
                          ),
                        ),
                        child: ClipOval(
                          child: (shorts.logoUrl != null && shorts.logoUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: shorts.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.school, size: 12),
                                )
                              : const Icon(Icons.school, size: 12),
                        ),
                      ),
                      SizedBox(width: _TabletSizes.logoTitleSpacing),
                      Expanded(
                        child: Text(
                          shorts.universityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: _TabletSizes.uniNameFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _TabletSizes.rowToTitleSpacing),
                  Text(
                    shorts.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _TabletSizes.titleFontSize,
                      fontWeight: FontWeight.w700,
                      height: _TabletSizes.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.titleToTimeSpacing),
                  Text(
                    timeAgo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: _TabletSizes.timeAgoFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: _TabletSizes.placeholderIconSize,
    ),
  );

  Widget _shimmerBox(BuildContext context) =>
      Container(color: AppTheme.surface(context));
}

// ─── ISO 8601 süreyi "MM:SS" formatına çevirir ───────────────────────────────

String _formatDuration(String iso) {
  final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
  final match = regex.firstMatch(iso);
  if (match == null) return '';

  final h = int.tryParse(match.group(1) ?? '') ?? 0;
  final m = int.tryParse(match.group(2) ?? '') ?? 0;
  final s = int.tryParse(match.group(3) ?? '') ?? 0;

  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}