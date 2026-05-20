// ═══════════════════════════════════════════════════════════════════════════
// Yorum giriş alanı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class CommentInputWidget extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSend;
  const CommentInputWidget({
    super.key,
    required this.textController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              hintText: 'Yorum yaz...',
              hintStyle: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 14.sp,
              ),
              filled: true,
              fillColor: AppTheme.surface(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onSend,
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.send_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 18.sp,
            ),
          ),
        ),
      ],
    );
  }
}