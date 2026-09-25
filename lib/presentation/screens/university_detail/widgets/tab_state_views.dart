// lib/presentation/screens/university_detail/widgets/tab_state_views.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../app/themes/app_theme.dart';
import '../university_detail_layout_spec.dart';

/// Tüm tab'ların ortak boş durum görünümü.
class UniversityTabEmptyView extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final IconData icon;
  final String title;
  final String subtitle;

  const UniversityTabEmptyView({
    super.key,
    required this.spec,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spec.contentPaddingH * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                  width: spec.stateIconBox,
                  height: spec.stateIconBox,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: spec.stateIconSize,
                    color: AppTheme.primaryColor.withValues(alpha: 0.7),
                  ),
                )
                .animate()
                .fadeIn(duration: 350.ms)
                .scaleXY(begin: 0.8, end: 1, curve: Curves.easeOutBack),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: spec.stateTitleFontSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPri(context),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: spec.stateSubtitleFontSize,
                color: AppTheme.textSec(context),
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

/// Tüm tab'ların ortak hata görünümü.
class UniversityTabErrorView extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final String message;
  final VoidCallback onRetry;

  const UniversityTabErrorView({
    super.key,
    required this.spec,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spec.contentPaddingH * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: spec.stateIconBox,
              height: spec.stateIconBox,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: spec.stateIconSize,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: spec.stateSubtitleFontSize,
                color: AppTheme.textSec(context),
                height: 1.4,
              ),
            ),
            SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tekrar Dene'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tüm tab'ların ortak shimmer/skeleton görünümü.
/// [Skeletonizer] ile sarmalayıp `child`'ı iskelet olarak render eder.
class UniversityTabSkeleton extends StatelessWidget {
  final Widget child;
  const UniversityTabSkeleton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(enabled: true, child: child);
  }
}

/// Video listesi için hazır iskelet kartı.
class UniversityVideoSkeletonCard extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  const UniversityVideoSkeletonCard({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spec.isTablet ? 18 : 14,
        vertical: spec.isTablet ? 10 : 8,
      ),
      child: Container(
        height: spec.shimmerListHeight,
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(spec.shimmerRadius),
        ),
      ),
    );
  }
}
