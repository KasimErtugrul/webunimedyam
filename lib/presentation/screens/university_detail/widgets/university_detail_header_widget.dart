import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/university_detail_controller.dart';
import '../utils/university_detail_sizes.dart';

class UniversityDetailHeader extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final UniversityDetailController controller;
  const UniversityDetailHeader({
    super.key,
    required this.sizes,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) {
        return Container(
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      final hasLogo = uni.logoUrl != null && uni.logoUrl!.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.06),
              AppTheme.bg(context).withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: sizes.headerTopPadding),
            Container(
              width: sizes.headerLogoOuterSize,
              height: sizes.headerLogoOuterSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
              child: Center(
                child: Container(
                  width: sizes.headerLogoInnerSize,
                  height: sizes.headerLogoInnerSize,
                  padding: EdgeInsets.all(sizes.headerLogoPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.18),
                      width: sizes.headerLogoBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        blurRadius: sizes.headerLogoShadowBlur,
                        spreadRadius: sizes.headerLogoShadowSpread,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: uni.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => Center(
                              child: SizedBox(
                                width: sizes.headerLogoInnerSize * 0.3,
                                height: sizes.headerLogoInnerSize * 0.3,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: sizes.headerLogoInnerSize * 0.4,
                            ),
                          )
                        : Icon(
                            Icons.school_rounded,
                            color: AppTheme.primaryColor,
                            size: sizes.headerLogoInnerSize * 0.4,
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: sizes.headerBadgeSpacing),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizes.headerPaddingHorizontal,
              ),
              child: Text(
                uni.name ?? '',
                style: TextStyle(
                  fontSize: sizes.headerNameFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPri(context),
                  height: sizes.headerNameLineHeight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (uni.city != null) ...[
              SizedBox(height: sizes.headerCitySpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: sizes.headerCityIconSize,
                    color: AppTheme.textSec(context),
                  ),
                  SizedBox(width: sizes.headerCityIconSpacing),
                  Text(
                    uni.city!,
                    style: TextStyle(
                      fontSize: sizes.headerCityFontSize,
                      color: AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: sizes.headerBadgeSpacing),
            Obx(() {
              if (!controller.isFavorite.value) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sizes.headerBadgePaddingHorizontal,
                  vertical: sizes.headerBadgePaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    sizes.headerBadgeBorderRadius,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      size: sizes.headerBadgeIconSize,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: sizes.headerBadgeIconSize * 0.4),
                    Text(
                      'Favorilerimde',
                      style: TextStyle(
                        fontSize: sizes.headerBadgeFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}