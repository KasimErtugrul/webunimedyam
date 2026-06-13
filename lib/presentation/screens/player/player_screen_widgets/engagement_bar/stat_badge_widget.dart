// lib/presentation/screens/player/player_screen_widgets/engagement_bar/stat_badge_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

class StatBadgeWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool loading;

  /// true ise rengi primary yapar ve hafif underline çizer
  final bool tappable;

  const StatBadgeWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.loading,
    this.tappable = false,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    // Tıklanabilirse primary renk tonlarına geç, değilse ikincil (pasif) renk kal
    final Color iconColor = tappable
        ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
        : AppTheme.textSec(context);

    final Color textColor = tappable
        ? Theme.of(context).colorScheme.primary
        : AppTheme.textSec(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4.h,
        horizontal: 2.w,
      ), // InkWell için alan
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── İkon veya Yükleme ──────────────────────────────────
          if (loading)
            SizedBox(
              width: 15.sp,
              height: 15.sp,
              child: CircularProgressIndicator(
                strokeWidth: 1.5.w,
                color: AppTheme.textSec(context).withOpacity(0.5),
              ),
            )
          else
            Icon(icon, color: iconColor, size: 15.sp),

          SizedBox(width: 4.w),

          // ─── Metin veya Skeleton Yükleme ────────────────────────
          if (loading)
            Container(
              width: 24.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: AppTheme.textSec(context).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4.r),
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                _fmt(count),
                key: ValueKey(count),
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.sp,
                  fontWeight: tappable ? FontWeight.w600 : FontWeight.normal,
                  height: 1.2, // Dikey hizalamayı sabitler
                  decoration: tappable
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: Theme.of(context).colorScheme.primary
                      .withOpacity(0.3), // Çok hafif şeffak alt çizgi
                  decorationThickness: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
