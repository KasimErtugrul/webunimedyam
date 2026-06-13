import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

/// Tıklanabilir aksiyon butonu — ikon + sayı (MD3 Tinted ve Animasyonlu)
class EngagementActionWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final bool loading;
  final VoidCallback onTap;

  const EngagementActionWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.active,
    required this.loading,
    required this.onTap,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    if (n == 0) return '';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    // Aktifse ana renk, değilse ikincil metin rengi
    final color = active
        ? Theme.of(context).colorScheme.primary
        : AppTheme.textSec(context);

    // Aktifse hafif primary renkli arka plan, değilse tam şeffaf
    final bgColor = active
        ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
        : Colors.transparent;

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(20.r),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: 20.sp, // İkon boyutuyla aynı
                height: 20.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0.w,
                  color: color,
                ),
              )
            else
              AnimatedScale(
                scale: active
                    ? 1.15
                    : 1.0, // Aktif olunca hafif büyüme (Pop efekti)
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack, // Hafif sıçramalı animasyon
                child: Icon(icon, color: color, size: 20.sp),
              ),

            if (_fmt(count).isNotEmpty) ...[
              SizedBox(width: 6.w),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _fmt(count),
                  key: ValueKey(count),
                  style: TextStyle(
                    color: color,
                    fontSize: 13.sp,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    height: 1.0, // Dikey hizalamayı sabit tutar
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
