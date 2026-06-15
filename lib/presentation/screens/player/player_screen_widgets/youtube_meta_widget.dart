import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';

class YoutubeMetaWidget extends StatelessWidget {
  final VideoModel video;
  const YoutubeMetaWidget({super.key, required this.video});

  static const _ytRed = Color(0xFFFF0000);

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

    final months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
                color: sec.withValues(alpha: 0.12),
                thickness: 0.8.h,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.5.r),
                    decoration: BoxDecoration(
                      color: _ytRed,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      size: 9.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'İstatistikler',
                    style: TextStyle(
                      color: sec.withValues(alpha: 0.5),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Divider(
                color: sec.withValues(alpha: 0.12),
                thickness: 0.8.h,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // ── Ana Tablo Paneli ───────────────────────────
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol accent çizgi
              Container(width: 3.w, color: _ytRed.withValues(alpha: 0.55)),

              // İçerik
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── YouTube Başlığı ───────────────────────
                      _buildSectionHeader(),
                      SizedBox(height: 8.h),

                      // ── Tablo ──────────────────────────────────
                      _buildGridTable(context),
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

  // ── Yardımcı Widget'lar ────────────────────────────────────────────────────

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.r),
          decoration: BoxDecoration(
            color: _ytRed,
            borderRadius: BorderRadius.circular(2.r),
          ),
          child: Icon(
            Icons.play_arrow_rounded,
            size: 8.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          'YouTube',
          style: TextStyle(
            color: _ytRed.withValues(alpha: 0.8),
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGridTable(BuildContext context) {
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
                  ? BorderSide(color: sec.withValues(alpha: 0.06), width: 0.5)
                  : BorderSide.none,
            ),
          ),
          children: [
            _buildTableCellWidget(context, leftCell),
            rightCell != null
                ? _buildTableCellWidget(context, rightCell, isRightColumn: true)
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

  Widget _buildTableCellWidget(
    BuildContext context,
    _TableCell cell, {
    bool isRightColumn = false,
  }) {
    final sec = AppTheme.textSec(context);

    return Container(
      padding: EdgeInsets.only(
        top: 6.h,
        bottom: 6.h,
        left: isRightColumn ? 8.w : 0,
        right: isRightColumn ? 0 : 8.w,
      ),
      child: Row(
        children: [
          Icon(
            cell.icon,
            size: 12.sp,
            color: cell.iconColor ?? sec.withValues(alpha: 0.55),
          ),
          SizedBox(width: 6.w),
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
                          color: sec.withValues(alpha: 0.9),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (cell.badge != null) ...[
                      SizedBox(width: 4.w),
                      _miniBadge(cell.badge!),
                    ],
                  ],
                ),
                Text(
                  cell.label,
                  style: TextStyle(
                    color: sec.withValues(alpha: 0.4),
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _ytRed.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _ytRed,
          fontSize: 7.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

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
