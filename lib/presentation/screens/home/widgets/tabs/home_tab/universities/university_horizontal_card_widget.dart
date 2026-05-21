// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/university_horizontal_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../app/themes/app_theme.dart';
import '../../../../../../../data/models/university_stats_model.dart';

class UniversityHorizontalCard extends StatelessWidget {
  final UniversityStatsModel stats;

  /// Thumbnail/logo gösterilecek URL
  final String? imageUrl;

  /// Altta gösterilecek istatistik değeri (formatlı)
  final String statLabel;

  /// İstatistiğin ikonu
  final IconData statIcon;

  /// Logo mu büyük gösterilsin? (En Büyük Kanallar listesi)
  final bool showLogoLarge;

  const UniversityHorizontalCard({
    super.key,
    required this.stats,
    required this.imageUrl,
    required this.statLabel,
    required this.statIcon,
    this.showLogoLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      height: 200.h,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Üst: Thumbnail / Logo ─────────────────────────────────────
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(context),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40.h,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.card(context).withValues(alpha:  0.85),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Alt: İsim + Chip ──────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
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
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  // İstatistik chip
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statIcon,
                          size: 10.sp,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(width: 3.w),
                        Flexible(
                          child: Text(
                            statLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 9.5.sp,
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
    );
  }

  Widget _buildImage(BuildContext context) {
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return _placeholder(context);
    }

    if (showLogoLarge) {
      // Logo listesi: beyaz/gri arka plan üzerinde logo ortada
      return Container(
        color: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F0F0),
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            width: 80.w,
            height: 80.w,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => _placeholder(context),
            placeholder: (_, _) => _shimmerBox(context),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => _placeholder(context),
      placeholder: (_, _) => _shimmerBox(context),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: AppTheme.surface(context),
        child: Icon(
          Icons.school_rounded,
          color: AppTheme.textSec(context),
          size: 32.sp,
        ),
      );

  Widget _shimmerBox(BuildContext context) => Container(
        color: AppTheme.surface(context),
      );
}

// ─── Sayı formatlama ────────────────────────────────────────────────────────

String formatStatNumber(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
  return n.toString();
}

String formatDuration(int totalSec) {
  final h = totalSec ~/ 3600;
  if (h >= 1000) return '${(h / 1000).toStringAsFixed(1)}k s';
  return '$h s';
}