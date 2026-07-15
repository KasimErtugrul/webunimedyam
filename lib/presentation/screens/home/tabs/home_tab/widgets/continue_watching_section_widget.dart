// lib/presentation/screens/home/tabs/home_tab/widgets/continue_watching_section_widget.dart
//
// "İzlemeye Devam Et" — ana sayfada, kullanıcının yarıda bıraktığı videoları
// gösteren yatay liste. Veri tamamen local (Hive) kaynaklıdır; herhangi bir
// ağ isteği yapılmaz.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/watch_progress_model.dart';

// ═══════════════════════════════════════════════════════════════════════
// PHONE SABİTLERİ — ScreenUtil ile çarpılacak
// ═══════════════════════════════════════════════════════════════════════

class _PhoneSizes {
  // Bölüm başlığı
  static const double sectionPadLeft = 16;
  static const double sectionPadTop = 4;
  static const double sectionPadRight = 16;
  static const double sectionPadBottom = 10;
  static const double sectionIconSize = 18;
  static const double sectionIconSpacing = 6;
  static const double sectionTitleFontSize = 16;

  // Liste
  static const double listHeight = 178;
  static const double listPadHorizontal = 16;
  static const double listBottomSpacing = 8;

  // Kart
  static const double cardWidth = 168;
  static const double cardMarginRight = 12;
  static const double cardBorderRadius = 14;

  // Küçük resim (thumbnail)
  static const double gradientHeight = 30;
  static const double remainingBottom = 9;
  static const double remainingLeft = 8;
  static const double remainingFontSize = 9.5;
  static const double removeTop = 6;
  static const double removeRight = 6;
  static const double removePadding = 3;
  static const double removeIconSize = 14;
  static const double playIconSize = 34;
  static const double progressMinHeight = 3;
  static const double errorIconSize = 32;

  // Metin alanı
  static const double textPadLeft = 8;
  static const double textPadTop = 6;
  static const double textPadRight = 8;
  static const double textPadBottom = 8;
  static const double titleFontSize = 11;
  static const double titleLineHeight = 1.25;
  static const double titleSubSpacing = 3;
  static const double subtitleFontSize = 9.5;

  // Opaklıklar
  static const double removeBgAlpha = 0.55;
  static const double gradientEndAlpha = 0.75;
  static const double playIconAlpha = 0.85;
  static const double progressBgAlpha = 0.3;
}

// ═══════════════════════════════════════════════════════════════════════
// TABLET SABİTLERİ — Ham piksel, ScreenUtil yok
// ═══════════════════════════════════════════════════════════════════════

class _TabletSizes {
  // Bölüm başlığı
  static const double sectionPadLeft = 24;
  static const double sectionPadTop = 6;
  static const double sectionPadRight = 24;
  static const double sectionPadBottom = 12;
  static const double sectionIconSize = 20;
  static const double sectionIconSpacing = 8;
  static const double sectionTitleFontSize = 18;

  // Liste
  static const double listHeight = 176;
  static const double listPadHorizontal = 24;
  static const double listBottomSpacing = 8;

  // Kart
  static const double cardWidth = 200;
  static const double cardMarginRight = 16;
  static const double cardBorderRadius = 12;

  // Küçük resim (thumbnail)
  static const double gradientHeight = 28;
  static const double remainingBottom = 8;
  static const double remainingLeft = 8;
  static const double remainingFontSize = 10;
  static const double removeTop = 6;
  static const double removeRight = 6;
  static const double removePadding = 4;
  static const double removeIconSize = 14;
  static const double playIconSize = 36;
  static const double progressMinHeight = 3;
  static const double errorIconSize = 34;

  // Metin alanı
  static const double textPadLeft = 8;
  static const double textPadTop = 6;
  static const double textPadRight = 8;
  static const double textPadBottom = 8;
  static const double titleFontSize = 12;
  static const double titleLineHeight = 1.25;
  static const double titleSubSpacing = 3;
  static const double subtitleFontSize = 10;

  // Opaklıklar
  static const double removeBgAlpha = 0.55;
  static const double gradientEndAlpha = 0.75;
  static const double playIconAlpha = 0.85;
  static const double progressBgAlpha = 0.3;
}

// ═══════════════════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════════════════

class ContinueWatchingSectionWidget extends StatelessWidget {
  final List<WatchProgressModel> items;
  final void Function(String videoId) onRemove;

  const ContinueWatchingSectionWidget({
    super.key,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ── Phone ──────────────────────────────────────────────
  Widget _buildPhone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            _PhoneSizes.sectionPadLeft.w,
            _PhoneSizes.sectionPadTop.h,
            _PhoneSizes.sectionPadRight.w,
            _PhoneSizes.sectionPadBottom.h,
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                size: _PhoneSizes.sectionIconSize.sp,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: _PhoneSizes.sectionIconSpacing.w),
              Expanded(
                child: Text(
                  'İzlemeye Devam Et',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.sectionTitleFontSize.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _PhoneSizes.listHeight.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.listPadHorizontal.w,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _CardPhone(
                key: ValueKey(item.video.videoId),
                item: item,
                onRemove: () => onRemove(item.video.videoId),
              );
            },
          ),
        ),
        SizedBox(height: _PhoneSizes.listBottomSpacing.h),
      ],
    );
  }

  // ── Tablet ─────────────────────────────────────────────
  Widget _buildTablet(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            _TabletSizes.sectionPadLeft,
            _TabletSizes.sectionPadTop,
            _TabletSizes.sectionPadRight,
            _TabletSizes.sectionPadBottom,
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                size: _TabletSizes.sectionIconSize,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: _TabletSizes.sectionIconSpacing),
              Expanded(
                child: Text(
                  'İzlemeye Devam Et',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.sectionTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _TabletSizes.listHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: _TabletSizes.listPadHorizontal,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _CardTablet(
                key: ValueKey(item.video.videoId),
                item: item,
                onRemove: () => onRemove(item.video.videoId),
              );
            },
          ),
        ),
        SizedBox(height: _TabletSizes.listBottomSpacing),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PHONE KARTI
// ═══════════════════════════════════════════════════════════════════════

class _CardPhone extends StatelessWidget {
  final WatchProgressModel item;
  final VoidCallback onRemove;

  const _CardPhone({super.key, required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final video = item.video;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        width: _PhoneSizes.cardWidth.w,
        margin: EdgeInsets.only(right: _PhoneSizes.cardMarginRight.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail + ilerleme çubuğu ───────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.bestThumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: _PhoneSizes.errorIconSize.sp,
                      ),
                    ),
                  ),
                  // Karartma gradyanı (alt taraf)
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
                            Colors.black.withValues(
                              alpha: _PhoneSizes.gradientEndAlpha,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Kalan süre
                  Positioned(
                    bottom: _PhoneSizes.remainingBottom.h,
                    left: _PhoneSizes.remainingLeft.w,
                    child: Text(
                      '${item.formattedRemaining} kaldı',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _PhoneSizes.remainingFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Kaldır butonu
                  Positioned(
                    top: _PhoneSizes.removeTop.h,
                    right: _PhoneSizes.removeRight.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(_PhoneSizes.removePadding.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: _PhoneSizes.removeBgAlpha,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: _PhoneSizes.removeIconSize.sp,
                        ),
                      ),
                    ),
                  ),
                  // Oynat ikonu (ortada, hafif)
                  Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white.withValues(
                        alpha: _PhoneSizes.playIconAlpha,
                      ),
                      size: _PhoneSizes.playIconSize.sp,
                    ),
                  ),
                  // İlerleme çubuğu — thumbnail'in en altında
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      child: LinearProgressIndicator(
                        value: item.progressFraction,
                        minHeight: _PhoneSizes.progressMinHeight.h,
                        backgroundColor: Colors.white.withValues(
                          alpha: _PhoneSizes.progressBgAlpha,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Başlık + üniversite ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                _PhoneSizes.textPadLeft.w,
                _PhoneSizes.textPadTop.h,
                _PhoneSizes.textPadRight.w,
                _PhoneSizes.textPadBottom.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _PhoneSizes.titleFontSize.sp,
                      fontWeight: FontWeight.w700,
                      height: _PhoneSizes.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: _PhoneSizes.titleSubSpacing.h),
                  Text(
                    video.universityName ?? video.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _PhoneSizes.subtitleFontSize.sp,
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
}

// ═══════════════════════════════════════════════════════════════════════
// TABLET KARTI
// ═══════════════════════════════════════════════════════════════════════

class _CardTablet extends StatelessWidget {
  final WatchProgressModel item;
  final VoidCallback onRemove;

  const _CardTablet({super.key, required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final video = item.video;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        width: _TabletSizes.cardWidth,
        margin: EdgeInsets.only(right: _TabletSizes.cardMarginRight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail + ilerleme çubuğu ───────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.bestThumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: _TabletSizes.errorIconSize,
                      ),
                    ),
                  ),
                  // Karartma gradyanı (alt taraf)
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
                            Colors.black.withValues(
                              alpha: _TabletSizes.gradientEndAlpha,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Kalan süre
                  Positioned(
                    bottom: _TabletSizes.remainingBottom,
                    left: _TabletSizes.remainingLeft,
                    child: Text(
                      '${item.formattedRemaining} kaldı',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _TabletSizes.remainingFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Kaldır butonu
                  Positioned(
                    top: _TabletSizes.removeTop,
                    right: _TabletSizes.removeRight,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(_TabletSizes.removePadding),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: _TabletSizes.removeBgAlpha,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: _TabletSizes.removeIconSize,
                        ),
                      ),
                    ),
                  ),
                  // Oynat ikonu (ortada, hafif)
                  Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white.withValues(
                        alpha: _TabletSizes.playIconAlpha,
                      ),
                      size: _TabletSizes.playIconSize,
                    ),
                  ),
                  // İlerleme çubuğu — thumbnail'in en altında
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      child: LinearProgressIndicator(
                        value: item.progressFraction,
                        minHeight: _TabletSizes.progressMinHeight,
                        backgroundColor: Colors.white.withValues(
                          alpha: _TabletSizes.progressBgAlpha,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Başlık + üniversite ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                _TabletSizes.textPadLeft,
                _TabletSizes.textPadTop,
                _TabletSizes.textPadRight,
                _TabletSizes.textPadBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _TabletSizes.titleFontSize,
                      fontWeight: FontWeight.w700,
                      height: _TabletSizes.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.titleSubSpacing),
                  Text(
                    video.universityName ?? video.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.subtitleFontSize,
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
}
