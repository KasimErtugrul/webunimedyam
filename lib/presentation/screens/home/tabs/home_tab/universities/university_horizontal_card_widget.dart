// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/university_horizontal_card_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/university_stats_model.dart';

class _Sizes {
  final bool isTablet;
  final double cardWidth;
  final double cardHeight;
  final double cardRadius;
  final double gradientHeight;
  final double logoSize;
  final double placeholderIconSize;
  final double contentPaddingH;
  final double contentPaddingV;
  final double titleFontSize;
  final double titleLineHeight;
  final double statPaddingH;
  final double statPaddingV;
  final double statRadius;
  final double statIconSize;
  final double statFontSize;
  final double statSpacing;

  const _Sizes._({
    required this.isTablet,
    required this.cardWidth,
    required this.cardHeight,
    required this.cardRadius,
    required this.gradientHeight,
    required this.logoSize,
    required this.placeholderIconSize,
    required this.contentPaddingH,
    required this.contentPaddingV,
    required this.titleFontSize,
    required this.titleLineHeight,
    required this.statPaddingH,
    required this.statPaddingV,
    required this.statRadius,
    required this.statIconSize,
    required this.statFontSize,
    required this.statSpacing,
  });

  factory _Sizes.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, ≥1024px): tablet ölçekleri + web ince ayarları.
    if (Responsive.isWeb(context)) {
      return const _Sizes._(
        isTablet: true,
        cardWidth: 200,
        cardHeight: 244,
        cardRadius: 16,
        gradientHeight: 48,
        logoSize: 100,
        placeholderIconSize: 38,
        contentPaddingH: 12,
        contentPaddingV: 10,
        titleFontSize: 14,
        titleLineHeight: 1.35,
        statPaddingH: 8,
        statPaddingV: 4,
        statRadius: 7,
        statIconSize: 13,
        statFontSize: 11.5,
        statSpacing: 4,
      );
    }
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        cardWidth: 180,
        cardHeight: 220,
        cardRadius: 16,
        gradientHeight: 44,
        logoSize: 90,
        placeholderIconSize: 36,
        contentPaddingH: 10,
        contentPaddingV: 8,
        titleFontSize: 13,
        titleLineHeight: 1.35,
        statPaddingH: 8,
        statPaddingV: 4,
        statRadius: 7,
        statIconSize: 12,
        statFontSize: 11,
        statSpacing: 4,
      );
    }
    return const _Sizes._(
      isTablet: false,
      cardWidth: 160,
      cardHeight: 200,
      cardRadius: 14,
      gradientHeight: 40,
      logoSize: 80,
      placeholderIconSize: 32,
      contentPaddingH: 8,
      contentPaddingV: 6,
      titleFontSize: 11.5,
      titleLineHeight: 1.3,
      statPaddingH: 6,
      statPaddingV: 3,
      statRadius: 6,
      statIconSize: 10,
      statFontSize: 9.5,
      statSpacing: 3,
    );
  }
}

class UniversityHorizontalCard extends StatelessWidget {
  final UniversityStatsModel stats;
  final String? imageUrl;
  final String statLabel;
  final IconData statIcon;
  final bool showLogoLarge;

  const UniversityHorizontalCard({
    super.key,
    required this.stats,
    required this.imageUrl,
    required this.statLabel,
    required this.statIcon,
    this.showLogoLarge = false,
  });

  void _navigateToDetail() {
    Get.toNamed(AppRoutes.universityDetail, arguments: stats.universityId);
  }

  @override
  Widget build(BuildContext context) {
    final spec = _Sizes.of(context);

    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(spec.cardRadius),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: _navigateToDetail,
        child: SizedBox(
          width: spec.cardWidth,
          height: spec.cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(context, spec),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: spec.gradientHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.card(context).withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spec.contentPaddingH,
                    vertical: spec.contentPaddingV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stats.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: spec.titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: spec.titleLineHeight,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spec.statPaddingH,
                          vertical: spec.statPaddingV,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(spec.statRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statIcon,
                              size: spec.statIconSize,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: spec.statSpacing),
                            Flexible(
                              child: Text(
                                statLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: spec.statFontSize,
                                  fontWeight: FontWeight.w700,
                                ),
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
      ),
    );
  }

  Widget _buildImage(BuildContext context, _Sizes spec) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return _placeholder(context, spec);

    if (showLogoLarge) {
      return Container(
        color: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F0F0),
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            width: spec.logoSize,
            height: spec.logoSize,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => _placeholder(context, spec),
            placeholder: (_, _) => _shimmerBox(context),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => _placeholder(context, spec),
      placeholder: (_, _) => _shimmerBox(context),
    );
  }

  Widget _placeholder(BuildContext context, _Sizes spec) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.school_rounded,
      color: AppTheme.textSec(context),
      size: spec.placeholderIconSize,
    ),
  );

  Widget _shimmerBox(BuildContext context) =>
      Container(color: AppTheme.surface(context));
}
