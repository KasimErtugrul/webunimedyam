// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/universities_empty_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../universities_tab_layout_spec.dart';

class UniversitiesEmptyView extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final String? query;
  final VoidCallback onRetry;

  const UniversitiesEmptyView({
    super.key,
    required this.spec,
    required this.query,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuery = query != null && query!.isNotEmpty;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: spec.emptyIconSize.w,
              height: spec.emptyIconSize.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasQuery ? Icons.search_off_rounded : Icons.school_outlined,
                size: spec.emptyIconInner.sp,
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .scaleXY(begin: 0.8, end: 1, curve: Curves.easeOutBack),
            SizedBox(height: spec.emptySpacingL.h),
            Text(
              hasQuery ? 'Sonuç bulunamadı' : 'Üniversite bulunamadı',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: spec.emptyTitleFontSize.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPri(context),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            SizedBox(height: spec.emptySpacingM.h),
            Text(
              hasQuery
                  ? '"$query" için eşleşen üniversite yok.\nFarklı bir kelime dene.'
                  : 'Şu anda listelenecek üniversite yok.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: spec.emptySubtitleFontSize.sp,
                color: AppTheme.textSec(context),
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
            SizedBox(height: spec.emptySpacingL.h),
            SizedBox(
              height: spec.emptyButtonHeight.h,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  hasQuery ? Icons.close_rounded : Icons.refresh_rounded,
                  size: 18.sp,
                ),
                label: Text(
                  hasQuery ? 'Aramayı temizle' : 'Tekrar dene',
                  style: TextStyle(
                    fontSize: spec.emptyButtonFontSize.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(spec.emptyButtonRadius.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                ),
              ),
            ).animate().fadeIn(delay: 260.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}