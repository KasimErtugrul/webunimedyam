// ═══════════════════════════════════════════════════════════════════════════
// Yorum kartı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/comment_model.dart';

class CommentTileWidget extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onDelete;

  const CommentTileWidget({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppTheme.surface(context),
            child: Text(
              (comment.profile?.username ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.profile?.username ?? 'Kullanıcı',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  comment.content,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: EdgeInsets.only(left: 8.w, top: 2.h),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.textSec(context),
                size: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}