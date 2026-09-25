/* // lib/presentation/screens/home/widgets/tabs/home_tab/widgets/university_horizontal_section_widget.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/university_stats_model.dart';
import '../universities/university_horizontal_card_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Başlık
  static const double titlePaddingLeft = 16;
  static const double titlePaddingTop = 0;
  static const double titlePaddingRight = 8;
  static const double titlePaddingBottom = 10;
  static const double titleFontSize = 16;
  static const double infoIconSize = 18;
  static const double infoIconPaddingHorizontal = 4;
  static const double infoIconPaddingVertical = 4;
  static const double infoIconSplashRadius = 20;
  static const double viewAllFontSize = 12;
  static const double viewAllPaddingHorizontal = 8;
  static const double viewAllPaddingVertical = 4;
  
  // Liste
  static const double listHeight = 200;
  static const double listPaddingHorizontal = 16;
 // static const double sectionSpacing = 24;
  
  // Shimmer
  static const int shimmerItemCount = 5;
  static const double shimmerCardWidth = 160;
  static const double shimmerCardMarginRight = 12;
  static const double shimmerCardBorderRadius = 14;
  
  // Empty
  static const double emptyFontSize = 13;
  
  // Dialog
  static const double dialogBorderRadius = 16;
  static const double dialogTitleFontSize = 16;
  static const double dialogContentFontSize = 14;
  static const double dialogContentLineHeight = 1.5;
}

class _TabletSizes {
  // Başlık - tablet için daha büyük
  static const double titlePaddingLeft = 20;
  static const double titlePaddingTop = 0;
  static const double titlePaddingRight = 12;
  static const double titlePaddingBottom = 12;
  static const double titleFontSize = 20;
  static const double infoIconSize = 22;
  static const double infoIconPaddingHorizontal = 6;
  static const double infoIconPaddingVertical = 6;
  static const double infoIconSplashRadius = 24;
  static const double viewAllFontSize = 14;
  static const double viewAllPaddingHorizontal = 10;
  static const double viewAllPaddingVertical = 6;
  
  // Liste - tablet için daha büyük
  static const double listHeight = 220;
  static const double listPaddingHorizontal = 20;
  //static const double sectionSpacing = 28;
  
  // Shimmer - tablet için daha büyük
  static const int shimmerItemCount = 4;
  static const double shimmerCardWidth = 180;
  static const double shimmerCardMarginRight = 14;
  static const double shimmerCardBorderRadius = 16;
  
  // Empty - tablet için daha büyük
  static const double emptyFontSize = 15;
  
  // Dialog - tablet için daha büyük
  static const double dialogBorderRadius = 20;
  static const double dialogTitleFontSize = 20;
  static const double dialogContentFontSize = 16;
  static const double dialogContentLineHeight = 1.6;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class UniversityHorizontalSection extends StatelessWidget {
  final String title;
  final String description;
  final List<UniversityStatsModel> items;
  final bool isLoading;

  final String? Function(UniversityStatsModel) imageUrlBuilder;
  final String Function(UniversityStatsModel) statLabelBuilder;
  final IconData statIcon;
  final bool showLogoLarge;
  final VoidCallback? onSeeAll;

  const UniversityHorizontalSection({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    required this.isLoading,
    required this.imageUrlBuilder,
    required this.statLabelBuilder,
    required this.statIcon,
    this.showLogoLarge = false,
    this.onSeeAll,
  });

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Responsive.isTablet(context)
                ? _TabletSizes.dialogBorderRadius
                : _PhoneSizes.dialogBorderRadius.r,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: Responsive.isTablet(context)
                ? _TabletSizes.dialogTitleFontSize
                : _PhoneSizes.dialogTitleFontSize.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPri(context),
          ),
        ),
        content: Text(
          description,
          style: TextStyle(
            fontSize: Responsive.isTablet(context)
                ? _TabletSizes.dialogContentFontSize
                : _PhoneSizes.dialogContentFontSize.sp,
            color: AppTheme.textSec(context),
            height: Responsive.isTablet(context)
                ? _TabletSizes.dialogContentLineHeight
                : _PhoneSizes.dialogContentLineHeight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Anladım',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            _PhoneSizes.titlePaddingLeft.w,
            _PhoneSizes.titlePaddingTop.h,
            _PhoneSizes.titlePaddingRight.w,
            _PhoneSizes.titlePaddingBottom.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.titleFontSize.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showInfoDialog(context),
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: _PhoneSizes.infoIconSize.sp,
                  color: AppTheme.textSec(context),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.infoIconPaddingHorizontal.w,
                  vertical: _PhoneSizes.infoIconPaddingVertical.h,
                ),
                constraints: const BoxConstraints(),
                splashRadius: _PhoneSizes.infoIconSplashRadius,
                tooltip: 'Bu liste hakkında',
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: _PhoneSizes.viewAllPaddingHorizontal.w,
                      vertical: _PhoneSizes.viewAllPaddingVertical.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: _PhoneSizes.viewAllFontSize.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: _PhoneSizes.listHeight.h,
          child: isLoading
              ? _buildShimmerPhone(context)
              : items.isEmpty
                  ? _buildEmptyPhone(context)
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: _PhoneSizes.listPaddingHorizontal.w,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return UniversityHorizontalCard(
                          stats: item,
                          imageUrl: imageUrlBuilder(item),
                          statLabel: statLabelBuilder(item),
                          statIcon: statIcon,
                          showLogoLarge: showLogoLarge,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildShimmerPhone(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.listPaddingHorizontal.w,
        ),
        itemCount: _PhoneSizes.shimmerItemCount,
        itemBuilder: (_, _) => Container(
          width: _PhoneSizes.shimmerCardWidth.w,
          margin: EdgeInsets.only(right: _PhoneSizes.shimmerCardMarginRight.w),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(
              _PhoneSizes.shimmerCardBorderRadius.r,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPhone(BuildContext context) {
    return Center(
      child: Text(
        'Veri bulunamadı',
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _PhoneSizes.emptyFontSize.sp,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            _TabletSizes.titlePaddingLeft,
            _TabletSizes.titlePaddingTop,
            _TabletSizes.titlePaddingRight,
            _TabletSizes.titlePaddingBottom,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showInfoDialog(context),
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: _TabletSizes.infoIconSize,
                  color: AppTheme.textSec(context),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _TabletSizes.infoIconPaddingHorizontal,
                  vertical: _TabletSizes.infoIconPaddingVertical,
                ),
                constraints: const BoxConstraints(),
                splashRadius: _TabletSizes.infoIconSplashRadius,
                tooltip: 'Bu liste hakkında',
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: _TabletSizes.viewAllPaddingHorizontal,
                      vertical: _TabletSizes.viewAllPaddingVertical,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: _TabletSizes.viewAllFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: _TabletSizes.listHeight,
          child: isLoading
              ? _buildShimmerTablet(context)
              : items.isEmpty
                  ? _buildEmptyTablet(context)
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: _TabletSizes.listPaddingHorizontal,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return UniversityHorizontalCard(
                          stats: item,
                          imageUrl: imageUrlBuilder(item),
                          statLabel: statLabelBuilder(item),
                          statIcon: statIcon,
                          showLogoLarge: showLogoLarge,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildShimmerTablet(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.listPaddingHorizontal,
        ),
        itemCount: _TabletSizes.shimmerItemCount,
        itemBuilder: (_, _) => Container(
          width: _TabletSizes.shimmerCardWidth,
          margin: EdgeInsets.only(right: _TabletSizes.shimmerCardMarginRight),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(
              _TabletSizes.shimmerCardBorderRadius,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTablet(BuildContext context) {
    return Center(
      child: Text(
        'Veri bulunamadı',
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _TabletSizes.emptyFontSize,
        ),
      ),
    );
  }
} */