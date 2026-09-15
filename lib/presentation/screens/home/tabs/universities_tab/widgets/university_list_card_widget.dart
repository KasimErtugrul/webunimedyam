// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/university_list_card_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../controllers/home/home_controller.dart';
import '../universities_tab_layout_spec.dart';

/// Renk disiplini:
///   • Marka yeşili → takip aksiyonu, isim vurgusu
///   • Mor → sadece "Radyo" (canlı yayın anlamı)
///   • Gri → meta ve stat'lar (dekorasyon değil, bilgi)
const _kRadioColor = Color(0xFF8B5CF6);

class UniversityListCardWidget extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversityModel university;

  const UniversityListCardWidget({
    super.key,
    required this.spec,
    required this.university,
  });

  void _openDetail() =>
      Get.toNamed(AppRoutes.universityDetail, arguments: university);

  @override
  Widget build(BuildContext context) {
    final hasLogo = university.logoUrl?.isNotEmpty == true;
    final hasRadio = university.radioLink?.isNotEmpty == true;
    final hasStats =
        (university.subscriberCount ?? 0) > 0 ||
        (university.viewCount ?? 0) > 0 ||
        (university.videoCount ?? 0) > 0;

    return Padding(
      padding: EdgeInsets.only(bottom: spec.cardBottomMargin.h),
      child: Material(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(spec.cardRadius.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _openDetail,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              spec.cardPadding.w,
              spec.cardPadding.h,
              spec.cardPadding.w,
              spec.cardPadding.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(spec.cardRadius.r),
              border: Border.all(
                color: AppTheme.textSec(context).withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Logo(spec: spec, hasLogo: hasLogo, url: university.logoUrl),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── İsim + Takip ───────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              university.name ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.textPri(context),
                                fontSize: spec.cardTitleFontSize.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _FollowButtonCompact(
                            spec: spec,
                            university: university,
                          ),
                        ],
                      ),

                      // ── Meta (şehir · yıl · tip · radyo) ───
                      SizedBox(height: 6.h),
                      _MetaLine(
                        spec: spec,
                        city: university.city,
                        foundedYear: university.foundedYear,
                        universityType:
                            university.displayUniversityType, // ← değişti
                        hasRadio: hasRadio,
                      ),

                      // ── Stat'lar (varsa) ──────────────────
                      if (hasStats) ...[
                        SizedBox(height: 6.h),
                        _StatLine(
                          spec: spec,
                          subscriberCount: university.subscriberCount,
                          viewCount: university.viewCount,
                          videoCount: university.videoCount,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Logo ───────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final bool hasLogo;
  final String? url;

  const _Logo({required this.spec, required this.hasLogo, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: spec.cardLogoSize.w,
      height: spec.cardLogoSize.w,
      padding: EdgeInsets.all(hasLogo ? 6.w : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.08),
            AppTheme.primaryColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: hasLogo
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.contain,
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) => Icon(
                  Icons.school_rounded,
                  color: AppTheme.primaryColor,
                  size: spec.cardLogoSize.w * 0.4,
                ),
              )
            : Icon(
                Icons.school_rounded,
                color: AppTheme.primaryColor,
                size: spec.cardLogoSize.w * 0.4,
              ),
      ),
    );
  }
}

// ─── Meta satırı: 📍Bolu · 📅1992 · 🏛Devlet · 📻Radyo ─────────────────────

class _MetaLine extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final String? city;
  final int? foundedYear;
  final String? universityType; // artık formatlanmış geliyor
  final bool hasRadio;

  const _MetaLine({
    required this.spec,
    required this.city,
    required this.foundedYear,
    required this.universityType,
    required this.hasRadio,
  });

  // ❌ _formatType helper'ı silinecek

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    final typeText = universityType; // direkt kullan

    if (city != null && city!.isNotEmpty) {
      items.add(
        _Item(spec: spec, icon: Icons.location_on_rounded, text: city!),
      );
    }
    if (foundedYear != null) {
      if (items.isNotEmpty) items.add(const _Dot());
      items.add(
        _Item(
          spec: spec,
          icon: Icons.calendar_today_rounded,
          text: '$foundedYear',
        ),
      );
    }
    if (typeText != null && typeText.isNotEmpty) {
      if (items.isNotEmpty) items.add(const _Dot());
      items.add(
        _Item(spec: spec, icon: Icons.account_balance_rounded, text: typeText),
      );
    }
    if (hasRadio) {
      if (items.isNotEmpty) items.add(const _Dot());
      items.add(
        _Item(
          spec: spec,
          icon: Icons.radio_rounded,
          text: 'Radyo',
          color: _kRadioColor,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4.w,
      runSpacing: 4.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: items,
    );
  }
}

// ─── Stat satırı: 👥1.5B · 👁291B · ▶175 ───────────────────────────────────

class _StatLine extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final int? subscriberCount;
  final int? viewCount;
  final int? videoCount;

  const _StatLine({
    required this.spec,
    required this.subscriberCount,
    required this.viewCount,
    required this.videoCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if ((subscriberCount ?? 0) > 0) {
      items.add(
        _Item(
          spec: spec,
          icon: Icons.people_alt_rounded,
          text: _fmt(subscriberCount!),
          bold: true,
        ),
      );
    }
    if ((viewCount ?? 0) > 0) {
      if (items.isNotEmpty) items.add(const _Dot());
      items.add(
        _Item(
          spec: spec,
          icon: Icons.visibility_rounded,
          text: _fmt(viewCount!),
          bold: true,
        ),
      );
    }
    if ((videoCount ?? 0) > 0) {
      if (items.isNotEmpty) items.add(const _Dot());
      items.add(
        _Item(
          spec: spec,
          icon: Icons.play_circle_fill_rounded,
          text: '$videoCount',
          bold: true,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4.w,
      runSpacing: 4.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: items,
    );
  }

  /// Türkçe konvansiyon: bin → B, milyon → M.
  /// 10+ değerlerde ondalık yok (daha temiz).
  static String _fmt(int n) {
    if (n >= 1000000) {
      final v = n / 1000000;
      return v >= 10 ? '${v.toStringAsFixed(0)}M' : '${v.toStringAsFixed(1)}M';
    }
    if (n >= 1000) {
      final v = n / 1000;
      return v >= 10 ? '${v.toStringAsFixed(0)}B' : '${v.toStringAsFixed(1)}B';
    }
    return '$n';
  }
}

// ─── Tek bir ikon+metin çifti ───────────────────────────────────────────────

class _Item extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final IconData icon;
  final String text;
  final Color? color;
  final bool bold;

  const _Item({
    required this.spec,
    required this.icon,
    required this.text,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textSec(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: spec.cardMetaIconSize.sp, color: c),
        SizedBox(width: 3.w),
        Text(
          text,
          style: TextStyle(
            color: c,
            fontSize: spec.cardMetaFontSize.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        '·',
        style: TextStyle(
          color: AppTheme.textSec(context).withValues(alpha: 0.35),
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }
}

// ─── Kompakt Takip butonu ──────────────────────────────────────────────────

class _FollowButtonCompact extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversityModel university;

  const _FollowButtonCompact({required this.spec, required this.university});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Obx(() {
      final isFav = ctrl.favoriteUniversityIds.contains(university.id);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ctrl.toggleUniversityFavorite(university),
          borderRadius: BorderRadius.circular(20.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 30.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: isFav ? Colors.transparent : AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20.r),
              border: isFav
                  ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.45),
                      width: 1.2,
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFav ? Icons.check_rounded : Icons.add_rounded,
                  size: 13.sp,
                  color: isFav ? AppTheme.primaryColor : Colors.white,
                ),
                SizedBox(width: 3.w),
                Text(
                  isFav ? 'Takipte' : 'Takip',
                  style: TextStyle(
                    color: isFav ? AppTheme.primaryColor : Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
