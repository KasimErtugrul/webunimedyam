// lib/presentation/screens/university_detail/tabs/about_tab/about_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../data/models/university_model.dart';
import '../../../../controllers/university_detail_controller.dart';
import '../../../../controllers/university_radio_controller.dart';
import '../../university_detail_layout_spec.dart';

const _kRadioColor = Color(0xFF8B5CF6);

// ─── Section Title ──────────────────────────────────────────────────────────

class UniversityAboutSectionTitle extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final String title;
  const UniversityAboutSectionTitle({
    super.key,
    required this.spec,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: spec.sectionTitleFontSize.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPri(context),
          ),
        ),
      ],
    );
  }
}

// ─── Favorite Button ────────────────────────────────────────────────────────

class UniversityAboutFavoriteButton extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityDetailController controller;
  const UniversityAboutFavoriteButton({
    super.key,
    required this.spec,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFav = controller.isFavorite.value;
      final isLoading = controller.isFavoriteLoading.value;

      return SizedBox(
        width: double.infinity,
        height: spec.favButtonHeight.h,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : controller.toggleFavorite,
          icon: isLoading
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isFav ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                  size: spec.favButtonIconSize.sp,
                ),
          label: Text(
            isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
            style: TextStyle(
              fontSize: spec.favButtonFontSize.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFav
                ? AppTheme.card(context)
                : AppTheme.primaryColor,
            foregroundColor: isFav ? AppTheme.primaryColor : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spec.favButtonRadius.r),
              side: isFav
                  ? BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    )
                  : BorderSide.none,
            ),
          ),
        ),
      );
    });
  }
}

// ─── Description Card ───────────────────────────────────────────────────────

class UniversityAboutDescriptionCard extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityModel uni;
  const UniversityAboutDescriptionCard({
    super.key,
    required this.spec,
    required this.uni,
  });

  @override
  Widget build(BuildContext context) {
    final hasDesc = uni.description?.isNotEmpty == true;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spec.cardPadding.w),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(spec.cardRadius.r),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha: 0.06),
        ),
      ),
      child: ReadMoreText(
        hasDesc ? uni.description! : 'Bu üniversite için açıklama bulunmuyor.',
        trimMode: TrimMode.Line,
        trimLines: 5,
        trimCollapsedText: ' Daha fazla',
        trimExpandedText: ' Daha az',
        style: TextStyle(
          fontSize: spec.descFontSize.sp,
          color: AppTheme.textSec(context),
          height: spec.descLineHeight,
          fontStyle: hasDesc ? FontStyle.normal : FontStyle.italic,
        ),
        moreStyle: TextStyle(
          fontSize: spec.descFontSize.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
        lessStyle: TextStyle(
          fontSize: spec.descFontSize.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

// ─── Info Card + Row ────────────────────────────────────────────────────────

class UniversityAboutInfoCard extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityModel uni;
  final UniversityDetailController controller;
  const UniversityAboutInfoCard({
    super.key,
    required this.spec,
    required this.uni,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final typeText = uni.displayUniversityType;
    final hasAddress = uni.address?.isNotEmpty == true;

    final rows = <(IconData, String, String)>[
      (Icons.location_on_rounded, 'Şehir', uni.city ?? '—'),
      (
        Icons.calendar_today_rounded,
        'Kuruluş Yılı',
        uni.foundedYear != null ? '${uni.foundedYear}' : '—',
      ),
      (Icons.account_balance_rounded, 'Üniversite Tipi', typeText ?? '—'),
      // ↓↓↓ YENİ: Adres (varsa gösterilir)
      if (hasAddress) (Icons.location_city_rounded, 'Adres', uni.address!),
      (
        Icons.play_circle_rounded,
        'Video Sayısı',
        uni.videoCount != null ? '${uni.videoCount}' : '—',
      ),
      (
        Icons.people_rounded,
        'Abone Sayısı',
        uni.subscriberCount != null ? controller.formattedSubscriberCount : '—',
      ),
      (
        Icons.visibility_rounded,
        'Toplam İzlenme',
        uni.viewCount != null ? controller.formattedViewCount : '—',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(spec.cardRadius.r),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _InfoRow(
              spec: spec,
              icon: rows[i].$1,
              label: rows[i].$2,
              value: rows[i].$3,
            ),
            if (i < rows.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: spec.rowPaddingH.w + spec.rowIconBoxSize.w + 12.w,
                color: AppTheme.textSec(context).withValues(alpha: 0.06),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.spec,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spec.rowPaddingH.w,
        vertical: spec.rowPaddingV.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: spec.rowIconBoxSize.w,
            height: spec.rowIconBoxSize.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(spec.rowIconBoxRadius.r),
            ),
            child: Icon(
              icon,
              size: spec.rowIconSize.sp,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(width: spec.rowIconSpacing.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: spec.rowLabelFontSize.sp,
                    color: AppTheme.textSec(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: spec.rowValueSpacing.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: spec.rowValueFontSize.sp,
                    color: AppTheme.textPri(context),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Link Button ────────────────────────────────────────────────────────────

class UniversityAboutLinkButton extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const UniversityAboutLinkButton({
    super.key,
    required this.spec,
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(spec.cardRadius.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(spec.cardRadius.r),
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spec.rowPaddingH.w,
            vertical: spec.rowPaddingV.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(spec.cardRadius.r),
            border: Border.all(
              color: AppTheme.textSec(context).withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: spec.rowIconBoxSize.w,
                height: spec.rowIconBoxSize.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(spec.rowIconBoxRadius.r),
                ),
                child: Icon(icon, size: spec.rowIconSize.sp, color: color),
              ),
              SizedBox(width: spec.rowIconSpacing.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: spec.rowValueFontSize.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPri(context),
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: (spec.rowValueFontSize + 2).sp,
                color: AppTheme.textSec(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Radio Card + Wave ──────────────────────────────────────────────────────

class UniversityAboutRadioCard extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityModel university;
  final UniversityRadioController radioController;

  const UniversityAboutRadioCard({
    super.key,
    required this.spec,
    required this.university,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isThisPlaying =
          radioController.currentPlayingUrl.value == university.radioLink;
      final buffering = isThisPlaying && radioController.isBuffering;
      final playing = isThisPlaying && radioController.isPlaying;

      return Container(
        padding: EdgeInsets.all(spec.cardPadding.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isThisPlaying
                ? [_kRadioColor.withValues(alpha: 0.15), AppTheme.card(context)]
                : [AppTheme.card(context), AppTheme.card(context)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(spec.cardRadius.r),
          border: Border.all(
            color: isThisPlaying
                ? _kRadioColor.withValues(alpha: 0.4)
                : AppTheme.textSec(context).withValues(alpha: 0.06),
            width: isThisPlaying ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: spec.radioIconBox.w,
              height: spec.radioIconBox.w,
              decoration: BoxDecoration(
                color: _kRadioColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(spec.radioIconBoxRadius.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (playing || buffering)
                    _RadioWave(spec: spec, isActive: playing),
                  Icon(
                    buffering
                        ? Icons.hdr_weak_rounded
                        : (playing
                              ? Icons.equalizer_rounded
                              : Icons.radio_rounded),
                    color: _kRadioColor,
                    size: spec.radioIconSize.sp,
                  ),
                ],
              ),
            ),
            SizedBox(width: spec.rowIconSpacing.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Üniversite Radyosu',
                    style: TextStyle(
                      fontSize: spec.radioTitleFontSize.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPri(context),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isThisPlaying
                        ? (playing
                              ? 'Canlı Yayın Dinleniyor...'
                              : (buffering
                                    ? 'Yayına Bağlanılıyor...'
                                    : 'Yayın Duraklatıldı'))
                        : 'Canlı yayını dinlemek için tıkla',
                    style: TextStyle(
                      fontSize: spec.radioSubtitleFontSize.sp,
                      color: isThisPlaying
                          ? _kRadioColor
                          : AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(spec.radioPlayBtnSize.w),
                onTap: () => radioController.togglePlayPause(
                  url: university.radioLink!,
                  name: university.name ?? '',
                  logoUrl: university.logoUrl,
                ),
                child: Container(
                  width: spec.radioPlayBtnSize.w,
                  height: spec.radioPlayBtnSize.w,
                  decoration: BoxDecoration(
                    color: isThisPlaying
                        ? _kRadioColor
                        : _kRadioColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: isThisPlaying
                        ? [
                            BoxShadow(
                              color: _kRadioColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: buffering
                      ? SizedBox(
                          width: spec.radioPlayBtnSize.w * 0.45,
                          height: spec.radioPlayBtnSize.w * 0.45,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isThisPlaying ? Colors.white : _kRadioColor,
                          size: spec.radioPlayIconSize.sp,
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RadioWave extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final bool isActive;
  const _RadioWave({required this.spec, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(spec.radioIconBoxRadius.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final h = isActive
              ? (spec.radioIconSize.sp +
                    (i % 2 == 0 ? spec.radioIconSize.sp * 0.5 : 0))
              : spec.radioIconSize.sp * 0.4;
          return AnimatedContainer(
            duration: Duration(milliseconds: 400 + i * 120),
            width: 3.w,
            height: h,
            margin: EdgeInsets.symmetric(horizontal: 1.5.w),
            decoration: BoxDecoration(
              color: _kRadioColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          );
        }),
      ),
    );
  }
}
