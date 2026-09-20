// lib/presentation/screens/player/player_screen_widgets/comment_tile_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/comment_model.dart';

class _Sizes {
  final double cardRadius;
  final double cardPaddingH;
  final double cardPaddingV;
  final double avatarRadius;
  final double avatarLetterFontSize;
  final double avatarSpacing;
  final double usernameTimeSpacing;
  final double dotSpacing;
  final double contentSpacing;
  final double deleteButtonPadding;
  final double usernameFontSize;
  final double timeFontSize;
  final double commentFontSize;
  final double commentLineHeight;
  final double deleteIconSize;
  final double deleteSplashRadius;
  final double deleteMinWidth;
  final double deleteMinHeight;

  const _Sizes._({
    required this.cardRadius,
    required this.cardPaddingH,
    required this.cardPaddingV,
    required this.avatarRadius,
    required this.avatarLetterFontSize,
    required this.avatarSpacing,
    required this.usernameTimeSpacing,
    required this.dotSpacing,
    required this.contentSpacing,
    required this.deleteButtonPadding,
    required this.usernameFontSize,
    required this.timeFontSize,
    required this.commentFontSize,
    required this.commentLineHeight,
    required this.deleteIconSize,
    required this.deleteSplashRadius,
    required this.deleteMinWidth,
    required this.deleteMinHeight,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        cardRadius: 14,
        cardPaddingH: 16,
        cardPaddingV: 14,
        avatarRadius: 22,
        avatarLetterFontSize: 16,
        avatarSpacing: 14,
        usernameTimeSpacing: 10,
        dotSpacing: 10,
        contentSpacing: 6,
        deleteButtonPadding: 6,
        usernameFontSize: 15,
        timeFontSize: 13,
        commentFontSize: 15,
        commentLineHeight: 1.5,
        deleteIconSize: 22,
        deleteSplashRadius: 20,
        deleteMinWidth: 34,
        deleteMinHeight: 34,
      );
    }
    return const _Sizes._(
      cardRadius: 12,
      cardPaddingH: 12,
      cardPaddingV: 10,
      avatarRadius: 18,
      avatarLetterFontSize: 14,
      avatarSpacing: 12,
      usernameTimeSpacing: 8,
      dotSpacing: 8,
      contentSpacing: 4,
      deleteButtonPadding: 4,
      usernameFontSize: 13,
      timeFontSize: 11,
      commentFontSize: 13,
      commentLineHeight: 1.45,
      deleteIconSize: 18,
      deleteSplashRadius: 16,
      deleteMinWidth: 28,
      deleteMinHeight: 28,
    );
  }
}

class CommentTileWidget extends StatelessWidget {
  static const String _kMaskedUsername = 'Gizli Kullanıcı';

  final CommentModel comment;
  final bool canDelete;
  final VoidCallback onDelete;

  const CommentTileWidget({
    super.key,
    required this.comment,
    required this.canDelete,
    required this.onDelete,
  });

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
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
    final s = _Sizes.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    final profile = comment.profile;
    final hasAvatar =
        profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty;
    final username = profile?.username ?? 'Anonim';
    final isMasked = username == _kMaskedUsername;
    final initial = username[0].toUpperCase();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: s.cardPaddingH.w,
        vertical: s.cardPaddingV.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(s.cardRadius.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ──
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isMasked
                  ? null
                  : LinearGradient(
                      colors: [
                        primary.withValues(alpha: 0.6),
                        primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isMasked
                  ? AppTheme.textSec(context).withValues(alpha: 0.3)
                  : null,
            ),
            child: CircleAvatar(
              radius: s.avatarRadius.r,
              backgroundColor: Colors.transparent,
              backgroundImage: (hasAvatar && !isMasked)
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: (hasAvatar && !isMasked)
                  ? null
                  : Center(
                      child: isMasked
                          ? Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: s.avatarRadius.r,
                            )
                          : Text(
                              initial,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: s.avatarLetterFontSize.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
            ),
          ),
          SizedBox(width: s.avatarSpacing.w),

          // ── İçerik ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontWeight: FontWeight.w600,
                          fontSize: s.usernameFontSize.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: s.usernameTimeSpacing.w),
                    Text(
                      '·',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: s.usernameFontSize.sp,
                      ),
                    ),
                    SizedBox(width: s.dotSpacing.w),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: s.timeFontSize.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.contentSpacing.h),
                Text(
                  comment.content,
                  style: TextStyle(
                    color: AppTheme.textSec(context).withValues(alpha: 0.9),
                    fontSize: s.commentFontSize.sp,
                    height: s.commentLineHeight,
                  ),
                ),
              ],
            ),
          ),

          // ── Sil ──
          if (canDelete)
            Padding(
              padding: EdgeInsets.only(left: s.deleteButtonPadding.w),
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.textSec(context).withValues(alpha: 0.6),
                  size: s.deleteIconSize.sp,
                ),
                splashRadius: s.deleteSplashRadius.r,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: s.deleteMinWidth.w,
                  minHeight: s.deleteMinHeight.h,
                ),
              ),
            ),
        ],
      ),
    );
  }
}