// ═══════════════════════════════════════════════════════════
// KART (TEK WIDGET)
// ═══════════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/university_stats_model.dart';
import '../../home/tabs/home_tab/universities/university_sections_config.dart';
import '../utils/university_stats_section_detail_sizes.dart';

class UniversityStatsSectionDetailCard extends StatelessWidget {
  const UniversityStatsSectionDetailCard({super.key, 
    required this.item,
    required this.sectionType,
    required this.sizes,
  });

  final UniversityStatsModel item;
  final UniversityStatsSectionType sectionType;
  final UniversityStatsSectionDetailSizes sizes;

  @override
  Widget build(BuildContext context) {
    final cfg = uniSectionConfigs.firstWhere((c) => c.type == sectionType);
    final hasLogo = item.logoUrl != null && item.logoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.universityDetail, arguments: item.universityId),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: sizes.cardMarginHorizontal,
          vertical: sizes.cardMarginVertical,
        ),
        padding: EdgeInsets.all(sizes.cardPadding),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(sizes.cardBorderRadius),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(sizes.logoBorderRadius),
              child: hasLogo
                  ? CachedNetworkImage(
                      imageUrl: item.logoUrl!,
                      width: sizes.logoSize,
                      height: sizes.logoSize,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholder(context),
                      placeholder: (_, _) => Container(
                        width: sizes.logoSize,
                        height: sizes.logoSize,
                        color: AppTheme.surface(context),
                      ),
                    )
                  : _placeholder(context),
            ),
            SizedBox(width: sizes.logoSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: sizes.titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.city != null && item.city!.isNotEmpty) ...[
                    SizedBox(height: sizes.citySpacingTop),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: sizes.cityIconSize,
                          color: AppTheme.textSec(context),
                        ),
                        SizedBox(width: sizes.citySpacing),
                        Flexible(
                          child: Text(
                            item.city!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.textSec(context),
                              fontSize: sizes.cityFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: sizes.citySpacingTop),
                  Row(
                    children: [
                      Icon(
                        cfg.statIcon,
                        size: sizes.statIconSize,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: sizes.statSpacing),
                      Flexible(
                        child: Text(
                          cfg.statLabelBuilder(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: sizes.statFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        width: sizes.logoSize,
        height: sizes.logoSize,
        color: AppTheme.surface(context),
        child: Icon(
          Icons.account_balance_rounded,
          color: AppTheme.textSec(context),
          size: sizes.placeholderIconSize,
        ),
      );
}