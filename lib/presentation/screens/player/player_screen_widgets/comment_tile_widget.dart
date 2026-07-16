// lib/presentation/screens/player/player_screen_widgets/comment_tile_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/comment_model.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Kart
  static const double cardBorderRadius = 12;
  static const double cardPaddingHorizontal = 12;
  static const double cardPaddingVertical = 10;
  static const double cardBackgroundOpacity = 0.6;
  static const double cardBorderOpacity = 0.08;

  // Avatar
  static const double avatarRadius = 18;
  static const double avatarLetterFontSize = 14;

  // Spacing
  static const double avatarSpacing = 12;
  static const double usernameTimeSpacing = 8;
  static const double dotSpacing = 8;
  static const double contentSpacing = 4;
  static const double deleteButtonPadding = 4;

  // Font sizes
  static const double usernameFontSize = 13;
  static const double timeFontSize = 11;
  static const double commentFontSize = 13;
  static const double commentLineHeight = 1.45;

  // Delete button
  static const double deleteIconSize = 18;
  static const double deleteSplashRadius = 16;
  static const double deleteMinWidth = 28;
  static const double deleteMinHeight = 28;
}

class _TabletSizes {
  // Kart - tablet için daha büyük
  static const double cardBorderRadius = 14;
  static const double cardPaddingHorizontal = 16;
  static const double cardPaddingVertical = 14;
  static const double cardBackgroundOpacity = 0.6;
  static const double cardBorderOpacity = 0.08;

  // Avatar - tablet için daha büyük
  static const double avatarRadius = 22;
  static const double avatarLetterFontSize = 16;

  // Spacing - tablet için daha geniş
  static const double avatarSpacing = 14;
  static const double usernameTimeSpacing = 10;
  static const double dotSpacing = 10;
  static const double contentSpacing = 6;
  static const double deleteButtonPadding = 6;

  // Font sizes - tablet için daha büyük
  static const double usernameFontSize = 15;
  static const double timeFontSize = 13;
  static const double commentFontSize = 15;
  static const double commentLineHeight = 1.5;

  // Delete button - tablet için daha büyük
  static const double deleteIconSize = 22;
  static const double deleteSplashRadius = 20;
  static const double deleteMinWidth = 34;
  static const double deleteMinHeight = 34;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

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
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final profile = comment.profile;
    final hasAvatar = profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty;
    final username = profile?.username ?? 'Anonim';
    final initial = username[0].toUpperCase();

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.cardPaddingHorizontal.w,
          vertical: _PhoneSizes.cardPaddingVertical.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface(context).withOpacity(_PhoneSizes.cardBackgroundOpacity),
          borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius.r),
          border: Border.all(
            color: AppTheme.textSec(context).withOpacity(_PhoneSizes.cardBorderOpacity),
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
                radius: _PhoneSizes.avatarRadius.r,
                backgroundColor: Colors.transparent,
                backgroundImage: hasAvatar ? NetworkImage(profile.avatarUrl!) : null,
                child: hasAvatar
                    ? null
                    : Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _PhoneSizes.avatarLetterFontSize.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: _PhoneSizes.avatarSpacing.w),

            // ─── İçerik ─────────────────────────────────────────────
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
                            fontSize: _PhoneSizes.usernameFontSize.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: _PhoneSizes.usernameTimeSpacing.w),
                      Text(
                        '·',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: _PhoneSizes.usernameFontSize.sp,
                        ),
                      ),
                      SizedBox(width: _PhoneSizes.dotSpacing.w),
                      Text(
                        _timeAgo(comment.createdAt),
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: _PhoneSizes.timeFontSize.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _PhoneSizes.contentSpacing.h),
                  Text(
                    comment.content,
                    style: TextStyle(
                      color: AppTheme.textSec(context).withOpacity(0.9),
                      fontSize: _PhoneSizes.commentFontSize.sp,
                      height: _PhoneSizes.commentLineHeight,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Silme Butonu ───────────────────────────────────
            if (canDelete)
              Padding(
                padding: EdgeInsets.only(left: _PhoneSizes.deleteButtonPadding.w),
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.textSec(context).withOpacity(0.6),
                    size: _PhoneSizes.deleteIconSize.sp,
                  ),
                  splashRadius: _PhoneSizes.deleteSplashRadius.r,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: _PhoneSizes.deleteMinWidth.w,
                    minHeight: _PhoneSizes.deleteMinHeight.h,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final profile = comment.profile;
    final hasAvatar = profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty;
    final username = profile?.username ?? 'Anonim';
    final initial = username[0].toUpperCase();

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.cardPaddingHorizontal,
          vertical: _TabletSizes.cardPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surface(context).withOpacity(_TabletSizes.cardBackgroundOpacity),
          borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
          border: Border.all(
            color: AppTheme.textSec(context).withOpacity(_TabletSizes.cardBorderOpacity),
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
                radius: _TabletSizes.avatarRadius,
                backgroundColor: Colors.transparent,
                backgroundImage: hasAvatar ? NetworkImage(profile.avatarUrl!) : null,
                child: hasAvatar
                    ? null
                    : Center(
                        child: Text(
                          initial,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _TabletSizes.avatarLetterFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(width: _TabletSizes.avatarSpacing),

            // ─── İçerik ─────────────────────────────────────────────
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
                            fontSize: _TabletSizes.usernameFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: _TabletSizes.usernameTimeSpacing),
                      Text(
                        '·',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: _TabletSizes.usernameFontSize,
                        ),
                      ),
                      SizedBox(width: _TabletSizes.dotSpacing),
                      Text(
                        _timeAgo(comment.createdAt),
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: _TabletSizes.timeFontSize,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _TabletSizes.contentSpacing),
                  Text(
                    comment.content,
                    style: TextStyle(
                      color: AppTheme.textSec(context).withOpacity(0.9),
                      fontSize: _TabletSizes.commentFontSize,
                      height: _TabletSizes.commentLineHeight,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Silme Butonu ───────────────────────────────────
            if (canDelete)
              Padding(
                padding: EdgeInsets.only(left: _TabletSizes.deleteButtonPadding),
                child: IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.textSec(context).withOpacity(0.6),
                    size: _TabletSizes.deleteIconSize,
                  ),
                  splashRadius: _TabletSizes.deleteSplashRadius,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: _TabletSizes.deleteMinWidth,
                    minHeight: _TabletSizes.deleteMinHeight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}