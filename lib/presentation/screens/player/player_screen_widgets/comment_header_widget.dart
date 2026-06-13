// ═══════════════════════════════════════════════════════════════════════════
// Yorum başlığı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class CommentsHeaderWidget extends StatelessWidget {
  final int count;
  const CommentsHeaderWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── Başlık ve Sayı Etiketi ──────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Yorumlar',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 16.sp, // Bir tık daha belirgin
                fontWeight: FontWeight.bold,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 8.w),
              // MD3 Badge / Chip tasarımı
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),

        // ─── Boş Durum Mesajı ───────────────────────────────────
        if (count == 0)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'Henüz yorum yapılmamış. İlk sen yaz!',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // ─── Ayırıcı Çizgi ─────────────────────────────────────
        SizedBox(height: 12.h),
        Divider(
          height: 1,
          thickness: 1,
          color: AppTheme.textSec(context).withOpacity(0.08), // Çok ince ve şık
        ),
      ],
    );
  }
}
