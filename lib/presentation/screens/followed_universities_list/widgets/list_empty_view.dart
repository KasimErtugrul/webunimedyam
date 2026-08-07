
// ─── Empty View ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/followed_universities_list_sizes.dart';

class FollowedUniversitiesListEmptyView extends StatelessWidget {
  final FollowedUniversitiesListSizes sizes;
  final bool isOwnProfile;

  const FollowedUniversitiesListEmptyView({super.key, 
    required this.sizes,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sizes.emptyPaddingHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              color: AppTheme.textSec(context),
              size: sizes.emptyIconSize,
            ),
            SizedBox(height: sizes.emptySpacingLarge),
            Text(
              isOwnProfile
                  ? 'Henüz üniversite takip etmedin'
                  : 'Takip edilen üniversite bulunamadı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: sizes.emptyTitleFontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sizes.emptySpacingSmall),
            Text(
              isOwnProfile
                  ? 'Takip ettiğin üniversiteler burada görünür'
                  : 'Bu kullanıcının takip listesi gizli olabilir',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: sizes.emptySubtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
