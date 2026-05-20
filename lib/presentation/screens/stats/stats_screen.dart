import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/stats_controller.dart';
import '../../../data/models/user_stats_model.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatsController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'İstatistiklerim',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPri(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textSec(context),
                      size: 22.sp,
                    ),
                    tooltip: 'Yenile',
                    onPressed: controller.refresh,
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3.w,
            ),
          );
        }

        if (controller.errorMessage.value != null ||
            controller.stats.value == null) {
          return _ErrorView(onRetry: controller.refresh);
        }

        return _StatsBody(stats: controller.stats.value!);
      }),
    );
  }
}

// ─── Hata görünümü ────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 56.sp,
            color: AppTheme.textSec(context),
          ),
          SizedBox(height: 16.h),
          Text(
            'İstatistikler yüklenemedi',
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'İnternet bağlantını kontrol et ve tekrar dene.',
            style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Tekrar Dene', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}

// ─── Ana gövde ────────────────────────────────────────────────────────────────

class _StatsBody extends StatelessWidget {
  final UserStatsModel stats;
  const _StatsBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => Get.find<StatsController>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero kart
            _HeroCard(stats: stats),
            SizedBox(height: 20.h),

            // ── Seri kartı (sadece streak > 0 ise)
            if (stats.currentStreakDays > 0 || stats.longestStreakDays > 0) ...[
              _StreakCard(stats: stats),
              SizedBox(height: 20.h),
            ],

            // ── Bu hafta / bu ay
            _SectionTitle(title: 'Dönem aktivitesi'),
            SizedBox(height: 10.h),
            _PeriodGrid(stats: stats),
            SizedBox(height: 20.h),

            // ── Genel aktivite
            _SectionTitle(title: 'Genel aktivite'),
            SizedBox(height: 10.h),
            _ActivityGrid(stats: stats),
            SizedBox(height: 20.h),

            // ── En çok izlenen üniversite
            if (stats.topUniversityName != null) ...[
              _SectionTitle(title: 'En çok izlediğin üniversite'),
              SizedBox(height: 10.h),
              _TopUniversityCard(stats: stats),
              SizedBox(height: 20.h),
            ],

            // ── Son izlenen video
            if (stats.lastWatchedTitle != null) ...[
              _SectionTitle(title: 'Son izlediğin video'),
              SizedBox(height: 10.h),
              _VideoCard(
                title: stats.lastWatchedTitle!,
                thumbnail: stats.lastWatchedThumbnail,
                date: stats.lastWatchedAt,
                icon: Icons.play_circle_rounded,
              ),
              SizedBox(height: 20.h),
            ],

            // ── Son beğenilen video
            if (stats.lastLikedTitle != null) ...[
              _SectionTitle(title: 'Son beğendiğin video'),
              SizedBox(height: 10.h),
              _VideoCard(
                title: stats.lastLikedTitle!,
                thumbnail: stats.lastLikedThumbnail,
                date: stats.lastLikedAt,
                icon: Icons.favorite_rounded,
                iconColor: Colors.redAccent,
              ),
              SizedBox(height: 8.h),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Hero kart ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final UserStatsModel stats;
  const _HeroCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final hours = stats.estimatedWatchMinutes ~/ 60;
    final mins = stats.estimatedWatchMinutes % 60;
    final watchTimeStr =
        hours > 0 ? '~$hours sa $mins dk' : '~$mins dk';

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kullanıcı satırı
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.username ?? stats.fullName ?? 'Kullanıcı',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (stats.memberSince != null)
                      Text(
                        'Üye · ${_formatDate(stats.memberSince!)}',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: 11.sp,
                        ),
                      ),
                  ],
                ),
              ),
              // Tahmini izleme süresi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    watchTimeStr,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'izleme süresi',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Divider(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            height: 1.h,
          ),
          SizedBox(height: 14.h),

          // 3'lü sayaç
          Row(
            children: [
              _HeroStat(
                  value: stats.totalWatched.toString(), label: 'İzlenen'),
              _VertDivider(),
              _HeroStat(
                  value: stats.totalLiked.toString(), label: 'Beğenilen'),
              _VertDivider(),
              _HeroStat(
                  value: stats.totalFavorited.toString(), label: 'Favori'),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${months[dt.month]} ${dt.year}';
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 32.h,
      color: AppTheme.primaryColor.withValues(alpha: 0.2),
    );
  }
}

// ─── Seri kartı ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final UserStatsModel stats;
  const _StreakCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.currentStreakDays} günlük seri 🔥',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'En uzun serin: ${stats.longestStreakDays} gün',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '🏆',
            style: TextStyle(fontSize: 22.sp),
          ),
        ],
      ),
    );
  }
}

// ─── Dönem grid ───────────────────────────────────────────────────────────────

class _PeriodGrid extends StatelessWidget {
  final UserStatsModel stats;
  const _PeriodGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.today_rounded,
            label: 'Bu hafta',
            value: stats.watchedThisWeek.toString(),
            sub: 'video izlendi',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _MetricCard(
            icon: Icons.calendar_month_rounded,
            label: 'Bu ay',
            value: stats.watchedThisMonth.toString(),
            sub: 'video izlendi',
          ),
        ),
      ],
    );
  }
}

// ─── Aktivite grid ────────────────────────────────────────────────────────────

class _ActivityGrid extends StatelessWidget {
  final UserStatsModel stats;
  const _ActivityGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.chat_bubble_rounded,
                label: 'Yorum',
                value: stats.totalCommented.toString(),
                sub: 'yapıldı',
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _MetricCard(
                icon: Icons.share_rounded,
                label: 'Paylaşım',
                value: stats.totalShared.toString(),
                sub: 'yapıldı',
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.school_rounded,
                label: 'Üniversite',
                value: stats.uniqueUniversitiesWatched.toString(),
                sub: 'farklı keşfedildi',
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _MetricCard(
                icon: Icons.play_circle_fill_rounded,
                label: 'Toplam',
                value: stats.totalWatched.toString(),
                sub: 'video izlendi',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Metric kart ─────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            sub,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── En çok izlenen üniversite ────────────────────────────────────────────────

class _TopUniversityCard extends StatelessWidget {
  final UserStatsModel stats;
  const _TopUniversityCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          if (stats.topUniversityLogo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: stats.topUniversityLogo!,
                width: 48.w,
                height: 48.w,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _LogoFallback(),
              ),
            )
          else
            _LogoFallback(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.topUniversityName!,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${stats.topUniversityWatchCount ?? 0} video izlendi',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: 22.sp,
          ),
        ],
      ),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.school_rounded,
        color: AppTheme.textSec(context),
        size: 24.sp,
      ),
    );
  }
}

// ─── Video kart ───────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final String title;
  final String? thumbnail;
  final DateTime? date;
  final IconData icon;
  final Color? iconColor;

  const _VideoCard({
    required this.title,
    this.thumbnail,
    this.date,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: thumbnail != null
                ? CachedNetworkImage(
                    imageUrl: thumbnail!,
                    width: 72.w,
                    height: 52.h,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _ThumbFallback(),
                  )
                : _ThumbFallback(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (date != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    _formatRelative(date!),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

class _ThumbFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 52.h,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        Icons.play_circle_outline_rounded,
        color: AppTheme.textSec(context),
        size: 24.sp,
      ),
    );
  }
}

// ─── Bölüm başlığı ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.textSec(context),
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}