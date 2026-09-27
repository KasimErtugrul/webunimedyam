// ─── Arama Sonucu Bulunamadı ────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/sizes.dart';

class ProfileActivityListNoResultsView extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  final String query;
  const ProfileActivityListNoResultsView({
    super.key,
    required this.sizes,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizes.noResultPaddingHorizontal,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppTheme.textSec(context),
              size: sizes.noResultIconSize,
            ),
            SizedBox(height: sizes.noResultSpacingLarge),
            Text(
              '"$query" için sonuç bulunamadı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: sizes.noResultTitleFontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sizes.noResultSpacingSmall),
            Text(
              'Üniversite adını veya video başlığını kontrol et',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: sizes.noResultSubtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}