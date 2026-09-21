// lib/presentation/screens/home/tabs/home_tab/widgets/continue_watching_section_widget.dart
//
// "İzlemeye Devam Et" — ana sayfada, kullanıcının yarıda bıraktığı videoları
// gösteren YATAY KAYDIRILABİLİR, 2 SIRALI (üst üste iki kart) liste.
// Veri tamamen local (Hive) kaynaklıdır; herhangi bir ağ isteği yapılmaz.
//
// TASARIM NOTU: KART TASARIMI DEĞİŞMEDİ — hâlâ tam genişlik kart (yatay
// mini-thumbnail + sağda başlık/kanal/ilerleme metni + sağ üstte X butonu,
// kartın en altında tam genişlikte ince ilerleme çubuğu). Yalnızca DİZİLİM
// değişti: kartlar 2'li gruplara ayrılır, her gruptaki 2 kart ÜST ÜSTE
// dizilir ve bu sütunlar yatayda kaydırılır. Sütun genişliği ekran
// genişliğinden geriye hesaplanır; sağda küçük bir "peek" (sonraki
// sütunun ucu) görünerek yapının kaydırılabilir olduğunu belli eder.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
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
  static const double sectionCountFontSize = 12;

  // Yatay kaydırma — her sütunda üst üste 2 kart
  static const double listPadHorizontal = 16;
  static const double columnGap = 12; // sütunlar arasındaki yatay boşluk
  static const double listGap =
      8; // aynı sütundaki 2 kart arasındaki dikey boşluk
  static const double listPeek = 24; // sağdan görünen sonraki sütunun ucu
  static const double listBottomSpacing = 8;

  // Kart
  static const double cardBorderRadius = 12;
  static const double cardInnerPadding = 8;
  static const double cardGap = 8;

  // Küçük resim (thumbnail) — tasarım: w-28 h-20 (112x80)
  static const double thumbWidth = 112;
  static const double thumbHeight = 80;
  static const double thumbBorderRadius = 8;
  static const double playOverlaySize = 32;
  static const double playIconSize = 20;
  static const double errorIconSize = 24;

  // İçerik
  static const double contentPaddingRight = 22;
  static const double verifiedIconSize = 13;
  static const double channelFontSize = 11;
  static const double channelIconSpacing = 4;
  static const double titleFontSize = 13.5;
  static const double titleLineHeight = 1.25;
  static const double titleTopSpacing = 2;
  static const double metaTopSpacing = 6;
  static const double metaFontSize = 11;

  // Kaldır (X) butonu
  static const double removeSize = 26;
  static const double removeIconSize = 15;
  static const double removeTop = 8;
  static const double removeRight = 8;

  // İlerleme çubuğu
  static const double progressHeight = 3;
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
  static const double sectionCountFontSize = 13;

  // Yatay kaydırma — her sütunda üst üste 2 kart
  static const double listPadHorizontal = 24;
  static const double columnGap = 16; // sütunlar arasındaki yatay boşluk
  static const double listGap =
      10; // aynı sütundaki 2 kart arasındaki dikey boşluk
  static const double listPeek = 32; // sağdan görünen sonraki sütunun ucu
  static const double listBottomSpacing = 8;

  // Kart
  static const double cardBorderRadius = 14;
  static const double cardInnerPadding = 10;
  static const double cardGap = 10;

  // Küçük resim (thumbnail)
  static const double thumbWidth = 132;
  static const double thumbHeight = 94;
  static const double thumbBorderRadius = 10;
  static const double playOverlaySize = 36;
  static const double playIconSize = 22;
  static const double errorIconSize = 28;

  // İçerik
  static const double contentPaddingRight = 26;
  static const double verifiedIconSize = 14;
  static const double channelFontSize = 12;
  static const double channelIconSpacing = 4;
  static const double titleFontSize = 15;
  static const double titleLineHeight = 1.25;
  static const double titleTopSpacing = 2;
  static const double metaTopSpacing = 6;
  static const double metaFontSize = 12;

  // Kaldır (X) butonu
  static const double removeSize = 28;
  static const double removeIconSize = 16;
  static const double removeTop = 8;
  static const double removeRight = 8;

  // İlerleme çubuğu
  static const double progressHeight = 4;
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
    final scheme = Theme.of(context).colorScheme;

    // Bir "sütun" = üst üste 2 kart. Sütun genişliği, ekranın kullanılabilir
    // genişliğinden geriye hesaplanır (sağdaki "peek" kadar pay bırakılarak)
    // — böylece kart tasarımı (tam genişlik) bozulmadan ekranda TAM 2 KART
    // görünür ve yapı yatayda kaydırılabilir olur.
    final double columnWidth =
        ScreenUtil().screenWidth -
        2 * _PhoneSizes.listPadHorizontal.w -
        _PhoneSizes.listPeek.w;

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
                Icons.history_rounded,
                size: _PhoneSizes.sectionIconSize.sp,
                color: scheme.primary,
              ),
              SizedBox(width: _PhoneSizes.sectionIconSpacing.w),
              Expanded(
                child: Text(
                  'İzlemeye Devam Et',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: _PhoneSizes.sectionTitleFontSize.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${items.length} video',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: _PhoneSizes.sectionCountFontSize.sp,
                ),
              ),
            ],
          ),
        ),
        // ── Yatay kaydırılan 2'li (üst üste) kart sütunları ──────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: _PhoneSizes.listPadHorizontal.w,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartlar 2'li gruplara ayrılır: her yatay adım bir sütun,
              // sütunun içinde 2 kart üst üste durur.
              for (int i = 0; i < items.length; i += 2) ...[
                if (i > 0) SizedBox(width: _PhoneSizes.columnGap.w),
                SizedBox(
                  width: columnWidth,
                  child: Column(
                    children: [
                      _CardPhone(
                        key: ValueKey(items[i].video.videoId),
                        item: items[i],
                        onRemove: () => onRemove(items[i].video.videoId),
                      ),
                      if (i + 1 < items.length) ...[
                        SizedBox(height: _PhoneSizes.listGap.h),
                        _CardPhone(
                          key: ValueKey(items[i + 1].video.videoId),
                          item: items[i + 1],
                          onRemove: () => onRemove(items[i + 1].video.videoId),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: _PhoneSizes.listBottomSpacing.h),
      ],
    );
  }

  // ── Tablet ─────────────────────────────────────────────
  Widget _buildTablet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Tablet tarafı da aynı düzen; ölçüler sabit piksel.
    final double columnWidth =
        MediaQuery.sizeOf(context).width -
        2 * _TabletSizes.listPadHorizontal -
        _TabletSizes.listPeek;

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
                Icons.history_rounded,
                size: _TabletSizes.sectionIconSize,
                color: scheme.primary,
              ),
              SizedBox(width: _TabletSizes.sectionIconSpacing),
              Expanded(
                child: Text(
                  'İzlemeye Devam Et',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: _TabletSizes.sectionTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${items.length} video',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: _TabletSizes.sectionCountFontSize,
                ),
              ),
            ],
          ),
        ),
        // ── Yatay kaydırılan 2'li (üst üste) kart sütunları ──────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: _TabletSizes.listPadHorizontal,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < items.length; i += 2) ...[
                if (i > 0) SizedBox(width: _TabletSizes.columnGap),
                SizedBox(
                  width: columnWidth,
                  child: Column(
                    children: [
                      _CardTablet(
                        key: ValueKey(items[i].video.videoId),
                        item: items[i],
                        onRemove: () => onRemove(items[i].video.videoId),
                      ),
                      if (i + 1 < items.length) ...[
                        SizedBox(height: _TabletSizes.listGap),
                        _CardTablet(
                          key: ValueKey(items[i + 1].video.videoId),
                          item: items[i + 1],
                          onRemove: () => onRemove(items[i + 1].video.videoId),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: _TabletSizes.listBottomSpacing),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PHONE KARTI — DEĞİŞMEDİ (orijinal tasarım: yatay mini-thumbnail + sağda
// içerik + sağ üstte X + en altta tam genişlik ilerleme çubuğu)
// ═══════════════════════════════════════════════════════════════════════

class _CardPhone extends StatelessWidget {
  final WatchProgressModel item;
  final VoidCallback onRemove;

  const _CardPhone({super.key, required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final video = item.video;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(_PhoneSizes.cardInnerPadding.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Thumbnail + oynat overlay ─────────────────────
                      SizedBox(
                        width: _PhoneSizes.thumbWidth.w,
                        height: _PhoneSizes.thumbHeight.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            _PhoneSizes.thumbBorderRadius.r,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: video.bestThumbnail,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: scheme.surfaceContainerHigh,
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: scheme.surfaceContainerHigh,
                                  child: Icon(
                                    Icons.play_circle_outline_rounded,
                                    color: scheme.onSurfaceVariant,
                                    size: _PhoneSizes.errorIconSize.sp,
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.25),
                              ),
                              Center(
                                child: Container(
                                  width: _PhoneSizes.playOverlaySize.w,
                                  height: _PhoneSizes.playOverlaySize.w,
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(
                                      alpha: 0.9,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: scheme.onPrimary,
                                    size: _PhoneSizes.playIconSize.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: _PhoneSizes.cardGap.w),
                      // ── İçerik: kanal + başlık + süre ─────────────────
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: _PhoneSizes.contentPaddingRight.w,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          video.universityName ??
                                              video.channelTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: scheme.primary,
                                            fontSize:
                                                _PhoneSizes.channelFontSize.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: _PhoneSizes.channelIconSpacing.w,
                                      ),
                                      Icon(
                                        Icons.verified_rounded,
                                        size: _PhoneSizes.verifiedIconSize.sp,
                                        color: scheme.primary,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: _PhoneSizes.titleTopSpacing.h,
                                  ),
                                  Text(
                                    video.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: _PhoneSizes.titleFontSize.sp,
                                      fontWeight: FontWeight.w600,
                                      height: _PhoneSizes.titleLineHeight,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: _PhoneSizes.metaTopSpacing.h,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.formattedPosition} / ${item.formattedDuration}',
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontSize: _PhoneSizes.metaFontSize.sp,
                                      ),
                                    ),
                                    Text(
                                      '${item.formattedRemaining} kaldı',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: _PhoneSizes.metaFontSize.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Kaldır (X) butonu ────────────────────────────────
                Positioned(
                  top: _PhoneSizes.removeTop.h,
                  right: _PhoneSizes.removeRight.w,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: _PhoneSizes.removeSize.w,
                      height: _PhoneSizes.removeSize.w,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close_rounded,
                        color: scheme.onSurfaceVariant,
                        size: _PhoneSizes.removeIconSize.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ── İlerleme çubuğu — kartın tam altında, tam genişlik ────
            SizedBox(
              width: double.infinity,
              height: _PhoneSizes.progressHeight.h,
              child: LinearProgressIndicator(
                value: item.progressFraction,
                minHeight: _PhoneSizes.progressHeight.h,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TABLET KARTI — DEĞİŞMEDİ (orijinal tasarım, sabit piksel ölçüler)
// ═══════════════════════════════════════════════════════════════════════

class _CardTablet extends StatelessWidget {
  final WatchProgressModel item;
  final VoidCallback onRemove;

  const _CardTablet({super.key, required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final video = item.video;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(_TabletSizes.cardInnerPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _TabletSizes.thumbWidth,
                        height: _TabletSizes.thumbHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            _TabletSizes.thumbBorderRadius,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: video.bestThumbnail,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: scheme.surfaceContainerHigh,
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: scheme.surfaceContainerHigh,
                                  child: Icon(
                                    Icons.play_circle_outline_rounded,
                                    color: scheme.onSurfaceVariant,
                                    size: _TabletSizes.errorIconSize,
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.black.withValues(alpha: 0.25),
                              ),
                              Center(
                                child: Container(
                                  width: _TabletSizes.playOverlaySize,
                                  height: _TabletSizes.playOverlaySize,
                                  decoration: BoxDecoration(
                                    color: scheme.primary.withValues(
                                      alpha: 0.9,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    color: scheme.onPrimary,
                                    size: _TabletSizes.playIconSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: _TabletSizes.cardGap),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: _TabletSizes.contentPaddingRight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          video.universityName ??
                                              video.channelTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: scheme.primary,
                                            fontSize:
                                                _TabletSizes.channelFontSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: _TabletSizes.channelIconSpacing,
                                      ),
                                      Icon(
                                        Icons.verified_rounded,
                                        size: _TabletSizes.verifiedIconSize,
                                        color: scheme.primary,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: _TabletSizes.titleTopSpacing,
                                  ),
                                  Text(
                                    video.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: _TabletSizes.titleFontSize,
                                      fontWeight: FontWeight.w600,
                                      height: _TabletSizes.titleLineHeight,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: _TabletSizes.metaTopSpacing,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item.formattedPosition} / ${item.formattedDuration}',
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontSize: _TabletSizes.metaFontSize,
                                      ),
                                    ),
                                    Text(
                                      '${item.formattedRemaining} kaldı',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: _TabletSizes.metaFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: _TabletSizes.removeTop,
                  right: _TabletSizes.removeRight,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: _TabletSizes.removeSize,
                      height: _TabletSizes.removeSize,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close_rounded,
                        color: scheme.onSurfaceVariant,
                        size: _TabletSizes.removeIconSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: _TabletSizes.progressHeight,
              child: LinearProgressIndicator(
                value: item.progressFraction,
                minHeight: _TabletSizes.progressHeight,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
