// lib/presentation/screens/player/player_screen_widgets/youtube_meta_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/video_model.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Divider
  static const double dividerThickness = 0.8;
  static const double dividerHorizontalPadding = 10;
  static const double dividerAlpha = 0.12;

  // YouTube badge
  static const double badgePadding = 2.5;
  static const double badgeBorderRadius = 3;
  static const double badgeIconSize = 9;
  static const double badgeSpacing = 5;

  // Section title
  static const double titleFontSize = 10;
  static const double titleLetterSpacing = 0.5;
  static const double titleAlpha = 0.5;

  // Container
  static const double containerBorderRadius = 10;
  static const double containerAlphaLight = 0.03;
  static const double containerAlphaDark = 0.04;
  static const double accentWidth = 3;
  static const double accentAlpha = 0.55;
  static const double contentPaddingHorizontal = 12;
  static const double contentPaddingVertical = 10;

  // Section header
  static const double sectionHeaderIconSize = 8;
  static const double sectionHeaderSpacing = 6;
  static const double sectionHeaderFontSize = 10;
  static const double sectionHeaderLetterSpacing = 0.5;

  // Table cells
  static const double cellPaddingTop = 6;
  static const double cellPaddingBottom = 6;
  static const double cellPaddingLeftRight = 8;
  static const double cellIconSize = 12;
  static const double cellIconSpacing = 6;
  static const double cellValueFontSize = 11.5;
  static const double cellLabelFontSize = 9;
  static const double cellBadgeSpacing = 4;
  static const double cellBadgePaddingHorizontal = 3;
  static const double cellBadgePaddingVertical = 1;
  static const double cellBadgeBorderRadius = 2;
  static const double cellBadgeFontSize = 7;
  static const double cellBadgeLetterSpacing = 0.5;
  static const double cellBorderAlpha = 0.06;
  static const double cellBorderWidth = 0.5;
  static const double cellValueAlpha = 0.9;
  static const double cellLabelAlpha = 0.4;

  // Spacing
  static const double headerSpacing = 10;
}

class _TabletSizes {
  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerHorizontalPadding = 16;
  static const double dividerAlpha = 0.12;

  // YouTube badge
  static const double badgePadding = 3.0;
  static const double badgeBorderRadius = 4;
  static const double badgeIconSize = 11;
  static const double badgeSpacing = 8;

  // Section title
  static const double titleFontSize = 12;
  static const double titleLetterSpacing = 0.6;
  static const double titleAlpha = 0.5;

  // Container
  static const double containerBorderRadius = 12;
  static const double containerAlphaLight = 0.03;
  static const double containerAlphaDark = 0.04;
  static const double accentWidth = 4;
  static const double accentAlpha = 0.55;
  static const double contentPaddingHorizontal = 16;
  static const double contentPaddingVertical = 14;

  // Section header
  static const double sectionHeaderIconSize = 10;
  static const double sectionHeaderSpacing = 8;
  static const double sectionHeaderFontSize = 12;
  static const double sectionHeaderLetterSpacing = 0.6;

  // Table cells
  static const double cellPaddingTop = 8;
  static const double cellPaddingBottom = 8;
  static const double cellPaddingLeftRight = 12;
  static const double cellIconSize = 16;
  static const double cellIconSpacing = 8;
  static const double cellValueFontSize = 14;
  static const double cellLabelFontSize = 11;
  static const double cellBadgeSpacing = 6;
  static const double cellBadgePaddingHorizontal = 4;
  static const double cellBadgePaddingVertical = 2;
  static const double cellBadgeBorderRadius = 3;
  static const double cellBadgeFontSize = 8;
  static const double cellBadgeLetterSpacing = 0.6;
  static const double cellBorderAlpha = 0.06;
  static const double cellBorderWidth = 0.5;
  static const double cellValueAlpha = 0.9;
  static const double cellLabelAlpha = 0.4;

  // Spacing
  static const double headerSpacing = 14;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class YoutubeMetaWidget extends StatelessWidget {
  final VideoModel video;
  const YoutubeMetaWidget({super.key, required this.video});

  static const Color _ytRed = Color(0xFFFF0000);

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  String _fmtDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 30) return '${diff.inDays} gün önce';

    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
    final sec = AppTheme.textSec(context);
    final isDark = AppTheme.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Bölüm başlığı ──────────────────────────
        Row(
          children: [
            Expanded(
              child: Divider(
                color: sec.withValues(alpha: _PhoneSizes.dividerAlpha),
                thickness: _PhoneSizes.dividerThickness.h,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _PhoneSizes.dividerHorizontalPadding.w,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(_PhoneSizes.badgePadding.r),
                    decoration: BoxDecoration(
                      color: _ytRed,
                      borderRadius: BorderRadius.circular(
                        _PhoneSizes.badgeBorderRadius.r,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: _PhoneSizes.badgeIconSize.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: _PhoneSizes.badgeSpacing.w),
                  Text(
                    'İstatistikler',
                    style: TextStyle(
                      color: sec.withValues(alpha: _PhoneSizes.titleAlpha),
                      fontSize: _PhoneSizes.titleFontSize.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _PhoneSizes.titleLetterSpacing,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Divider(
                color: sec.withValues(alpha: _PhoneSizes.dividerAlpha),
                thickness: _PhoneSizes.dividerThickness.h,
              ),
            ),
          ],
        ),
        SizedBox(height: _PhoneSizes.headerSpacing.h),

        // ── Ana Tablo Paneli ───────────────────────────
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: _PhoneSizes.containerAlphaDark)
                : Colors.black.withValues(alpha: _PhoneSizes.containerAlphaLight),
            borderRadius: BorderRadius.circular(
              _PhoneSizes.containerBorderRadius.r,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _PhoneSizes.accentWidth.w,
                color: _ytRed.withValues(alpha: _PhoneSizes.accentAlpha),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _PhoneSizes.contentPaddingHorizontal.w,
                    vertical: _PhoneSizes.contentPaddingVertical.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeaderPhone(),
                      SizedBox(height: _PhoneSizes.headerSpacing.h),
                      _buildGridTablePhone(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderPhone() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(_PhoneSizes.badgePadding.r),
          decoration: BoxDecoration(
            color: _ytRed,
            borderRadius: BorderRadius.circular(_PhoneSizes.badgeBorderRadius.r),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: _PhoneSizes.sectionHeaderIconSize.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: _PhoneSizes.sectionHeaderSpacing.w),
        Text(
          'YouTube',
          style: TextStyle(
            color: _ytRed.withValues(alpha: 0.8),
            fontSize: _PhoneSizes.sectionHeaderFontSize.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: _PhoneSizes.sectionHeaderLetterSpacing,
          ),
        ),
      ],
    );
  }

  Widget _buildGridTablePhone(BuildContext context) {
    final sec = AppTheme.textSec(context);

    final cells = <_TableCell>[
      _TableCell(
        icon: Icons.visibility_outlined,
        label: 'Görüntülenme',
        value: _fmtCount(video.viewCount),
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.thumb_up_off_alt_rounded,
        label: 'Beğeni',
        value: _fmtCount(video.likeCount),
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Yorum',
        value: _fmtCount(video.commentCount),
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.calendar_today_outlined,
        label: 'Yayınlanma',
        value: _fmtDate(video.publishedAt),
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.timer_outlined,
        label: 'Süre',
        value: video.formattedDuration.isEmpty ? '-' : video.formattedDuration,
        badge: video.isHd ? 'HD' : null,
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: video.isShorts
            ? Icons.movie_creation_outlined
            : Icons.videocam_outlined,
        label: 'Tür',
        value: video.isShorts ? 'Shorts' : 'Video',
        badge: video.isShorts ? 'SHORTS' : null,
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.account_circle_outlined,
        label: 'Kanal',
        value: video.channelTitle,
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
    ];

    final rows = <TableRow>[];

    for (var i = 0; i < cells.length; i += 2) {
      final leftCell = cells[i];
      final rightCell = i + 1 < cells.length ? cells[i + 1] : null;

      rows.add(
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: i + 2 < cells.length
                  ? BorderSide(
                      color: sec.withValues(alpha: _PhoneSizes.cellBorderAlpha),
                      width: _PhoneSizes.cellBorderWidth,
                    )
                  : BorderSide.none,
            ),
          ),
          children: [
            _buildTableCellWidgetPhone(context, leftCell),
            rightCell != null
                ? _buildTableCellWidgetPhone(
                    context,
                    rightCell,
                    isRightColumn: true,
                  )
                : const SizedBox(),
          ],
        ),
      );
    }

    return Table(
      columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
      children: rows,
    );
  }

  Widget _buildTableCellWidgetPhone(
    BuildContext context,
    _TableCell cell, {
    bool isRightColumn = false,
  }) {
    final sec = AppTheme.textSec(context);

    return Container(
      padding: EdgeInsets.only(
        top: _PhoneSizes.cellPaddingTop.h,
        bottom: _PhoneSizes.cellPaddingBottom.h,
        left: isRightColumn ? _PhoneSizes.cellPaddingLeftRight.w : 0,
        right: isRightColumn ? 0 : _PhoneSizes.cellPaddingLeftRight.w,
      ),
      child: Row(
        children: [
          Icon(
            cell.icon,
            size: _PhoneSizes.cellIconSize.sp,
            color: cell.iconColor ?? sec.withValues(alpha: 0.55),
          ),
          SizedBox(width: _PhoneSizes.cellIconSpacing.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        cell.value,
                        style: TextStyle(
                          color: sec.withValues(alpha: _PhoneSizes.cellValueAlpha),
                          fontSize: _PhoneSizes.cellValueFontSize.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (cell.badge != null) ...[
                      SizedBox(width: _PhoneSizes.cellBadgeSpacing.w),
                      _miniBadgePhone(cell.badge!),
                    ],
                  ],
                ),
                Text(
                  cell.label,
                  style: TextStyle(
                    color: sec.withValues(alpha: _PhoneSizes.cellLabelAlpha),
                    fontSize: _PhoneSizes.cellLabelFontSize.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadgePhone(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.cellBadgePaddingHorizontal.w,
        vertical: _PhoneSizes.cellBadgePaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: _ytRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(_PhoneSizes.cellBadgeBorderRadius.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _ytRed,
          fontSize: _PhoneSizes.cellBadgeFontSize.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: _PhoneSizes.cellBadgeLetterSpacing,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final sec = AppTheme.textSec(context);
    final isDark = AppTheme.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Bölüm başlığı ──────────────────────────
        Row(
          children: [
            Expanded(
              child: Divider(
                color: sec.withValues(alpha: _TabletSizes.dividerAlpha),
                thickness: _TabletSizes.dividerThickness,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _TabletSizes.dividerHorizontalPadding,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(_TabletSizes.badgePadding),
                    decoration: BoxDecoration(
                      color: _ytRed,
                      borderRadius: BorderRadius.circular(
                        _TabletSizes.badgeBorderRadius,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: _TabletSizes.badgeIconSize,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: _TabletSizes.badgeSpacing),
                  Text(
                    'İstatistikler',
                    style: TextStyle(
                      color: sec.withValues(alpha: _TabletSizes.titleAlpha),
                      fontSize: _TabletSizes.titleFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _TabletSizes.titleLetterSpacing,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Divider(
                color: sec.withValues(alpha: _TabletSizes.dividerAlpha),
                thickness: _TabletSizes.dividerThickness,
              ),
            ),
          ],
        ),
        SizedBox(height: _TabletSizes.headerSpacing),

        // ── Ana Tablo Paneli ───────────────────────────
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: _TabletSizes.containerAlphaDark)
                : Colors.black.withValues(alpha: _TabletSizes.containerAlphaLight),
            borderRadius: BorderRadius.circular(
              _TabletSizes.containerBorderRadius,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _TabletSizes.accentWidth,
                color: _ytRed.withValues(alpha: _TabletSizes.accentAlpha),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _TabletSizes.contentPaddingHorizontal,
                    vertical: _TabletSizes.contentPaddingVertical,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeaderTablet(),
                      SizedBox(height: _TabletSizes.headerSpacing),
                      _buildGridTableTablet(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeaderTablet() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(_TabletSizes.badgePadding),
          decoration: BoxDecoration(
            color: _ytRed,
            borderRadius: BorderRadius.circular(_TabletSizes.badgeBorderRadius),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: _TabletSizes.sectionHeaderIconSize,
            color: Colors.white,
          ),
        ),
        SizedBox(width: _TabletSizes.sectionHeaderSpacing),
        Text(
          'YouTube',
          style: TextStyle(
            color: _ytRed.withValues(alpha: 0.8),
            fontSize: _TabletSizes.sectionHeaderFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: _TabletSizes.sectionHeaderLetterSpacing,
          ),
        ),
      ],
    );
  }

  Widget _buildGridTableTablet(BuildContext context) {
    final sec = AppTheme.textSec(context);

    final cells = <_TableCell>[
      _TableCell(
        icon: Icons.visibility_outlined,
        label: 'Görüntülenme',
        value: _fmtCount(video.viewCount),
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.thumb_up_off_alt_rounded,
        label: 'Beğeni',
        value: _fmtCount(video.likeCount),
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Yorum',
        value: _fmtCount(video.commentCount),
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.calendar_today_outlined,
        label: 'Yayınlanma',
        value: _fmtDate(video.publishedAt),
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.timer_outlined,
        label: 'Süre',
        value: video.formattedDuration.isEmpty ? '-' : video.formattedDuration,
        badge: video.isHd ? 'HD' : null,
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: video.isShorts
            ? Icons.movie_creation_outlined
            : Icons.videocam_outlined,
        label: 'Tür',
        value: video.isShorts ? 'Shorts' : 'Video',
        badge: video.isShorts ? 'SHORTS' : null,
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
      _TableCell(
        icon: Icons.account_circle_outlined,
        label: 'Kanal',
        value: video.channelTitle,
        iconColor: _ytRed.withValues(alpha: 0.7),
      ),
    ];

    final rows = <TableRow>[];

    for (var i = 0; i < cells.length; i += 2) {
      final leftCell = cells[i];
      final rightCell = i + 1 < cells.length ? cells[i + 1] : null;

      rows.add(
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: i + 2 < cells.length
                  ? BorderSide(
                      color: sec.withValues(alpha: _TabletSizes.cellBorderAlpha),
                      width: _TabletSizes.cellBorderWidth,
                    )
                  : BorderSide.none,
            ),
          ),
          children: [
            _buildTableCellWidgetTablet(context, leftCell),
            rightCell != null
                ? _buildTableCellWidgetTablet(
                    context,
                    rightCell,
                    isRightColumn: true,
                  )
                : const SizedBox(),
          ],
        ),
      );
    }

    return Table(
      columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
      children: rows,
    );
  }

  Widget _buildTableCellWidgetTablet(
    BuildContext context,
    _TableCell cell, {
    bool isRightColumn = false,
  }) {
    final sec = AppTheme.textSec(context);

    return Container(
      padding: EdgeInsets.only(
        top: _TabletSizes.cellPaddingTop,
        bottom: _TabletSizes.cellPaddingBottom,
        left: isRightColumn ? _TabletSizes.cellPaddingLeftRight : 0,
        right: isRightColumn ? 0 : _TabletSizes.cellPaddingLeftRight,
      ),
      child: Row(
        children: [
          Icon(
            cell.icon,
            size: _TabletSizes.cellIconSize,
            color: cell.iconColor ?? sec.withValues(alpha: 0.55),
          ),
          SizedBox(width: _TabletSizes.cellIconSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        cell.value,
                        style: TextStyle(
                          color: sec.withValues(alpha: _TabletSizes.cellValueAlpha),
                          fontSize: _TabletSizes.cellValueFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (cell.badge != null) ...[
                      SizedBox(width: _TabletSizes.cellBadgeSpacing),
                      _miniBadgeTablet(cell.badge!),
                    ],
                  ],
                ),
                Text(
                  cell.label,
                  style: TextStyle(
                    color: sec.withValues(alpha: _TabletSizes.cellLabelAlpha),
                    fontSize: _TabletSizes.cellLabelFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadgeTablet(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.cellBadgePaddingHorizontal,
        vertical: _TabletSizes.cellBadgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: _ytRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(_TabletSizes.cellBadgeBorderRadius),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _ytRed,
          fontSize: _TabletSizes.cellBadgeFontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: _TabletSizes.cellBadgeLetterSpacing,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// YARDIMCI VERİ SINIFI (Ortak)
// ═══════════════════════════════════════════════════════════════════════

class _TableCell {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final String? badge;

  _TableCell({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.badge,
  });
}