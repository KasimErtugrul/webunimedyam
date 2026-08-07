
// ─── University Card ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/university_model.dart';
import '../utils/followed_universities_list_sizes.dart';

class FollowedUniversitiesListCard extends StatelessWidget {
  final FollowedUniversitiesListSizes sizes;
  final UniversityModel university;

  const FollowedUniversitiesListCard({super.key, 
    required this.sizes,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.universityDetail, arguments: university),
      child: Container(
        margin: EdgeInsets.only(bottom: sizes.listCardBottomMargin),
        padding: EdgeInsets.symmetric(
          horizontal: sizes.listCardPaddingHorizontal,
          vertical: sizes.listCardPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(sizes.listCardBorderRadius),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(sizes.listLogoBorderRadius),
              child: university.logoUrl != null
                  ? Image.network(
                      university.logoUrl!,
                      width: sizes.listLogoSize,
                      height: sizes.listLogoSize,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _logoPlaceholder(context),
                    )
                  : _logoPlaceholder(context),
            ),
            SizedBox(width: sizes.listLogoSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name ?? '',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: sizes.listTitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (university.city != null) ...[
                    SizedBox(height: sizes.listCityTopSpacing),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: sizes.listCityIconSize,
                          color: AppTheme.textSec(context),
                        ),
                        SizedBox(width: sizes.listCitySpacing),
                        Text(
                          university.city!,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: sizes.listCityFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
              size: sizes.listChevronSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholder(BuildContext context) {
    return Container(
      width: sizes.listLogoSize,
      height: sizes.listLogoSize,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(sizes.listLogoBorderRadius),
      ),
      child: Icon(
        Icons.account_balance_rounded,
        color: AppTheme.textSec(context),
        size: sizes.listPlaceholderIconSize,
      ),
    );
  }
}