import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/comment_model.dart';

class CommentTileWidget extends StatelessWidget {
  final CommentModel comment;
  final bool canDelete;
  final VoidCallback onDelete;

  const CommentTileWidget({
    super.key,
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  /// Zaman formatını "2 saat önce" gibi okunabilir hale getiren yardımcı metot
  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} yıl önce';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} hafta önce';
    if (diff.inDays > 0) return '${diff.inDays} gün önce';
    if (diff.inHours > 0) return '${diff.inHours} saat önce';
    if (diff.inMinutes > 0) return '${diff.inMinutes} dakika önce';
    if (diff.inSeconds > 5) return '${diff.inSeconds} saniye önce';
    return 'Az önce';
  }

  @override
  Widget build(BuildContext context) {
    final profile = comment.profile;
    final bool hasAvatar =
        profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty;
    final String username = profile?.username ?? 'Anonim';
    final String initial = username[0].toUpperCase();

    return InkWell(
      onTap: () {}, // İleride beğeni/yanıtlama için tetikleyici olabilir
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.surface(
            context,
          ).withOpacity(0.6), // Hafif arka plan derinliği
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.textSec(context).withOpacity(0.08), // İnce çerçeve
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Avatar ────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    Theme.of(context).colorScheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.transparent,
                backgroundImage: hasAvatar
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: hasAvatar
                    ? null
                    : Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),

            // ─── İçerik (Ad, Zaman, Yorum) ─────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst Satır: Kullanıcı Adı ve Zaman
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          username,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '·',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _timeAgo(comment.createdAt),
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Yorum Metni
                  Text(
                    comment.content,
                    style: TextStyle(
                      color: AppTheme.textSec(context).withOpacity(0.9),
                      fontSize: 13.sp,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Silme Butonu ───────────────────────────────────
            if (canDelete)
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.textSec(context).withOpacity(0.6),
                    size: 18.sp,
                  ),
                  splashRadius: 16.r,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.h),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
