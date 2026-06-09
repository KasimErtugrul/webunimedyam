// lib/presentation/screens/player/player_screen_widgets/engagement_bar/stat_badge_widget.dart
// DEĞİŞİKLİK: tappable parametresi eklendi — true ise hafif underline gösterir

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

class StatBadgeWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool loading;

  /// true ise sayı metninin altına hafif underline çizer, tıklanabilir olduğunu hissettir
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
    if (n == 0) return '0';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textSec(context), size: 15.sp),
        SizedBox(width: 4.w),
        loading
            ? SizedBox(
                width: 28.w,
                height: 10.h,
                child: LinearProgressIndicator(
                  backgroundColor: AppTheme.surface(context),
                  color: AppTheme.textSec(context).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _fmt(count),
                  key: ValueKey(count),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 12.sp,
                    decoration: tappable
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: AppTheme.textSec(context),
                  ),
                ),
              ),
      ],
    );
  }
}