// lib/presentation/screens/home/tabs/discovery_tab/discover_widgets.dart
//
// Discover tab'ın ortak widget'ları. Hepsi DiscoverLayoutSpec'ten beslenir,
// ScreenUtil kullanmaz. Görsel değerler orijinal discover_tab_widget.dart'taki
// inline ternary'lerden birebir aktarıldı.
//
// ⚠️ PROVISIONAL: DiscoverLeaderboardCard + iki shimmer TASLAK — orijinal
// gövdeleri paylaşılan dosyada kesildiği için görülemedi. Ayrıntı:
// dosya sonu "PROVISIONAL" bölümü.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/utils/formatters.dart';
import '../../../../../../data/models/university_stats_model.dart';

import '../../../../../../data/models/video_engagement_model.dart';
import '../discover_layout_spec.dart';

// ═══════════════════════════════════════════════════════════
// Hub kartı (parıltı + quick search)
// ═══════════════════════════════════════════════════════════

class DiscoverHubCard extends StatelessWidget {
  const DiscoverHubCard({
    super.key,
    required this.spec,
    required this.onSearchTap,
  });

  final DiscoverLayoutSpec spec;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spec.hubCardRadius),
        gradient: LinearGradient(
          colors: [
            scheme.surfaceContainer,
            scheme.surfaceContainerHigh,
            scheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sağ alt parıltı
          Positioned(
            right: -spec.hubGlowShift,
            bottom: -spec.hubGlowShift,
            child: Container(
              width: spec.hubGlowSize,
              height: spec.hubGlowSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(spec.hubPad),
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                height: spec.searchHeight,
                padding: EdgeInsets.symmetric(horizontal: spec.searchPadH),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(spec.searchRadius),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: scheme.outline,
                      size: spec.searchIconSize,
                    ),
                    SizedBox(width: spec.searchIconGap),
                    Expanded(
                      child: Text(
                        'Seminer, robotik, konser veya kanal ara...',
                        style: TextStyle(
                          color: scheme.outline,
                          fontSize: spec.searchFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: spec.searchTuneBoxSize,
                      height: spec.searchTuneBoxSize,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(spec.searchTuneRadius),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: scheme.onSurfaceVariant,
                        size: spec.searchTuneIconSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Segment switcher (Videolar / Kanallar)
// ═══════════════════════════════════════════════════════════

class DiscoverSegmentSwitcher extends StatelessWidget {
  const DiscoverSegmentSwitcher({
    super.key,
    required this.spec,
    required this.selectedIndex,
    required this.onChanged,
  });

  final DiscoverLayoutSpec spec;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  Widget _button(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final selected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (selectedIndex != index) onChanged(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: spec.segmentButtonVPad),
          decoration: BoxDecoration(
            color: selected ? scheme.surfaceContainerHigh : Colors.transparent,
            borderRadius: BorderRadius.circular(spec.segmentButtonRadius),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: spec.segmentIconSize,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
              SizedBox(width: spec.segmentIconGap),
              Text(
                label,
                style: TextStyle(
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  fontSize: spec.segmentFontSize,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(spec.segmentOuterPad),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(spec.segmentOuterRadius),
      ),
      child: Row(
        children: [
          _button(
            context,
            index: 0,
            label: 'Videolar',
            icon: Icons.smart_display_rounded,
          ),
          _button(
            context,
            index: 1,
            label: 'Kanallar',
            icon: Icons.podcasts_rounded,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Bölüm başlığı (ikon + başlık + badge / trailing text / Tümü)
// ═══════════════════════════════════════════════════════════

class DiscoverSectionHeader extends StatelessWidget {
  const DiscoverSectionHeader({
    super.key,
    required this.spec,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.trailingText,
    this.trailingBadge,
    this.onSeeAll,
  });

  final DiscoverLayoutSpec spec;
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? trailingText;
  final String? trailingBadge;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side flexes so a long section title truncates gracefully
        // instead of pushing the trailing badge / "Tümü" action off-screen.
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: spec.secHeaderIconSize),
              SizedBox(width: spec.secHeaderGap),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: spec.secHeaderTitleSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (trailingBadge != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spec.secBadgePadH,
              vertical: spec.secBadgePadV,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(spec.secBadgeRadius),
            ),
            child: Text(
              trailingBadge!,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: spec.secBadgeFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (trailingText != null)
          Text(
            trailingText!,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: spec.secTrailingFontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: spec.secTrailingLetterSpacing,
            ),
          )
        else if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'Tümü',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: spec.secSeeAllFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.primary,
                  size: spec.secSeeAllIconSize,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Büyük vitrin video kartı
// ═══════════════════════════════════════════════════════════

class DiscoverLargeVideoCard extends StatelessWidget {
  const DiscoverLargeVideoCard({
    super.key,
    required this.spec,
    required this.video,
    required this.badgeText,
    required this.badgeIcon,
    this.isFeatured = false,
  });

  final DiscoverLayoutSpec spec;
  final VideoEngagementModel video;
  final String badgeText;
  final IconData badgeIcon;
  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = video.channelTitle.isNotEmpty
        ? video.channelTitle
            .substring(
              0,
              video.channelTitle.length > 3 ? 3 : video.channelTitle.length,
            )
            .toUpperCase()
        : 'ÜNİ';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video.toVideoModel(),
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(spec.largeCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: scheme.surfaceContainerHighest),
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: video.fallbackThumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          scheme.surfaceContainerLowest.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Sol üst rozet (Etkileşim / Öne Çıkan)
                  Positioned(
                    top: spec.largeCardBadgeTop,
                    left: spec.largeCardBadgeLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: spec.largeCardBadgePadH,
                        vertical: spec.largeCardBadgePadV,
                      ),
                      decoration: BoxDecoration(
                        color: isFeatured
                            ? scheme.primary
                            : scheme.surfaceContainerLowest
                                .withValues(alpha: 0.85),
                        borderRadius:
                            BorderRadius.circular(spec.largeCardBadgeRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            badgeIcon,
                            color: isFeatured
                                ? scheme.onPrimary
                                : scheme.primary,
                            size: spec.largeCardBadgeIconSize,
                          ),
                          SizedBox(width: spec.largeCardBadgePadV),
                          Text(
                            badgeText,
                            style: TextStyle(
                              color: isFeatured
                                  ? scheme.onPrimary
                                  : scheme.primary,
                              fontSize: spec.largeCardBadgeFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sağ alt süre — DAVRANIŞ DEĞİŞİKLİĞİ: duration boşsa
                  // '18:42' uydurmak yerine rozet hiç çizilmez.
                  if (video.duration.isNotEmpty)
                    Positioned(
                      bottom: spec.largeCardDurationBottom,
                      right: spec.largeCardDurationRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spec.largeCardDurationPadH,
                          vertical: spec.largeCardDurationPadV,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLowest
                              .withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(
                            spec.largeCardDurationRadius,
                          ),
                        ),
                        child: Text(
                          video.duration,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: spec.largeCardDurationFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Merkez play
                  Center(
                    child: Container(
                      width: spec.largeCardPlaySize,
                      height: spec.largeCardPlaySize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary.withValues(alpha: 0.85),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: scheme.onPrimary,
                        size: spec.largeCardPlayIconSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(spec.largeCardInfoPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: spec.largeCardTitleSize,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: spec.largeCardTitleGap),
                  Row(
                    children: [
                      Container(
                        width: spec.largeCardAvatarSize,
                        height: spec.largeCardAvatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.surfaceContainerHighest,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: spec.largeCardAvatarFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: spec.largeCardAvatarGap),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                video.channelTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: spec.largeCardChannelFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: spec.largeCardChannelVerifiedGap),
                            Icon(
                              Icons.verified_rounded,
                              color: scheme.primary,
                              size: spec.largeCardVerifiedIconSize,
                            ),
                            SizedBox(width: spec.largeCardMetaGap),
                            Text(
                              '•',
                              style: TextStyle(
                                color: scheme.outline,
                                fontSize: spec.largeCardDotFontSize,
                              ),
                            ),
                            SizedBox(width: spec.largeCardMetaGap),
                            Text(
                              '${video.ytViewCount.compact} İzlenme',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: spec.largeCardMetaFontSize,
                              ),
                            ),
                            SizedBox(width: spec.largeCardMetaGap),
                            Text(
                              '•',
                              style: TextStyle(
                                color: scheme.outline,
                                fontSize: spec.largeCardDotFontSize,
                              ),
                            ),
                            SizedBox(width: spec.largeCardMetaGap),
                            Text(
                              timeAgoTr(video.publishedAt),
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: spec.largeCardMetaFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ═══════════════════════════════════════════════════════════
// En çok izlenen kanal satırı
// ═══════════════════════════════════════════════════════════

class DiscoverTopChannelRow extends StatelessWidget {
  const DiscoverTopChannelRow({
    super.key,
    required this.spec,
    required this.stats,
    this.isFollowed = false,
  });

  final DiscoverLayoutSpec spec;
  final UniversityStatsModel stats;
  final bool isFollowed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = stats.name.isNotEmpty
        ? stats.name
            .substring(0, stats.name.length > 2 ? 2 : stats.name.length)
            .toUpperCase()
        : 'ÜN';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.universityDetail,
        arguments: stats.universityId,
      ),
      child: Container(
        padding: EdgeInsets.all(spec.channelRowPad),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(spec.channelRowRadius),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: spec.channelLogoSize,
                  height: spec.channelLogoSize,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(spec.channelLogoRadius),
                  ),
                  alignment: Alignment.center,
                  child: stats.logoUrl != null && stats.logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(spec.channelLogoRadius),
                          child: CachedNetworkImage(
                            imageUrl: stats.logoUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Text(
                          initials,
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: spec.channelInitialsFontSize,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                Positioned(
                  bottom: -spec.channelCheckOffset,
                  right: -spec.channelCheckOffset,
                  child: Container(
                    width: spec.channelCheckBadgeSize,
                    height: spec.channelCheckBadgeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                    ),
                    child: Icon(
                      Icons.check,
                      color: scheme.onPrimary,
                      size: spec.channelCheckIconSize,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: spec.channelRowGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          stats.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: spec.channelNameFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: spec.channelNameDotGap),
                      Container(
                        width: spec.channelNameDotSize,
                        height: spec.channelNameDotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spec.channelNameDotGap),
                  // Stats line (views • videos). Wrapped in FittedBox so that
                  // on narrow phones / large system font scale the row scales
                  // down instead of overflowing — truncating mid-number would
                  // break the meaning, so ellipsis is not an option here.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${stats.totalYtViews.compact} İzlenme',
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: spec.channelStatsFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: spec.channelStatsGap),
                        Text(
                          '•',
                          style: TextStyle(
                            color: scheme.outline,
                            fontSize: spec.channelStatsDotFontSize,
                          ),
                        ),
                        SizedBox(width: spec.channelStatsGap),
                        Text(
                          '${stats.totalVideos} Video',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: spec.channelStatsFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spec.channelButtonGap),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spec.channelButtonPadH,
                vertical: spec.channelButtonPadV,
              ),
              decoration: BoxDecoration(
                color: isFollowed
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(spec.channelButtonRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFollowed ? Icons.check : Icons.add,
                    size: spec.channelButtonIconSize,
                    color: isFollowed ? scheme.onPrimary : scheme.primary,
                  ),
                  SizedBox(width: spec.channelNameDotGap),
                  Text(
                    isFollowed ? 'Takipte' : 'Takip Et',
                    style: TextStyle(
                      color: isFollowed ? scheme.onPrimary : scheme.primary,
                      fontSize: spec.channelButtonFontSize,
                      fontWeight: FontWeight.w700,
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

// ═══════════════════════════════════════════════════════════════════════════
// ⚠️ PROVISIONAL BÖLÜM
// Orijinal dosya _buildLeaderboardCard gövdesinin ORTASINDA kesildi ve
// iki shimmer metodunun gövdesi hiç paylaşılmadı. Aşağıdakiler TASLAKTIR —
// orijinal görselleriyle birebir aynı oldukları garanti EDİLEMEZ.
// Orijinalleri yapıştırırsan spec'e birebir çevirip bunların yerine koyarım.
// ═══════════════════════════════════════════════════════════════════════════

class DiscoverLeaderboardCard extends StatelessWidget {
  const DiscoverLeaderboardCard({
    super.key,
    required this.spec,
    required this.stats,
    required this.rank,
  });

  final DiscoverLayoutSpec spec;
  final UniversityStatsModel stats;
  final String rank;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = stats.name.isNotEmpty
        ? stats.name
            .substring(0, stats.name.length > 2 ? 2 : stats.name.length)
            .toUpperCase()
        : 'ÜN';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.universityDetail,
        arguments: stats.universityId,
      ),
      child: Container(
        padding: EdgeInsets.all(spec.leaderboardPad),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(spec.leaderboardRadius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                rank,
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(width: spec.leaderboardColumnGap),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHighest,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(width: spec.leaderboardColumnGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${stats.totalYtViews.compact} İzlenme • ${stats.totalVideos} Video',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11.5,
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

class DiscoverVideoCardShimmer extends StatelessWidget {
  const DiscoverVideoCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(2, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 12, color: Colors.white),
                          const SizedBox(height: 6),
                          Container(height: 10, width: 140, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class DiscoverChannelCardShimmer extends StatelessWidget {
  const DiscoverChannelCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(3, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 10, width: 120, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}