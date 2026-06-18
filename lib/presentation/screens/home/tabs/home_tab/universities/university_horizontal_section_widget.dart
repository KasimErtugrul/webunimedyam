// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/university_horizontal_section_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_stats_model.dart';
import 'university_horizontal_card_widget.dart';

class UniversityHorizontalSection extends StatelessWidget {
  final String title;
  final String description;
  final List<UniversityStatsModel> items;
  final bool isLoading;

  /// Her kart için thumbnail URL'ini döndüren fonksiyon
  final String? Function(UniversityStatsModel) imageUrlBuilder;

  /// Her kart için istatistik etiketini döndüren fonksiyon
  final String Function(UniversityStatsModel) statLabelBuilder;

  /// İstatistik ikonu
  final IconData statIcon;

  /// Logo büyük gösterilsin mi? (En Büyük Kanallar)
  final bool showLogoLarge;

  /// "Tümünü Gör" tıklandığında çalışır
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
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPri(context),
          ),
        ),
        content: Text(
          description,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSec(context),
            height: 1.5,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Başlık Satırı ────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 8.w, 10.h),
          child: Row(
            children: [
              // Başlık metni
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // ℹ️ Bilgi butonu
              IconButton(
                onPressed: () => _showInfoDialog(context),
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 18.sp,
                  color: AppTheme.textSec(context),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                constraints: const BoxConstraints(),
                splashRadius: 20,
                tooltip: 'Bu liste hakkında',
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Yatay Liste ──────────────────────────────────────────────────
        SizedBox(
          height: 200.h,
          child: isLoading
              ? _buildShimmer(context)
              : items.isEmpty
                  ? _buildEmpty(context)
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
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

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (_, _) => Container(
          width: 160.w,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Text(
        'Veri bulunamadı',
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
