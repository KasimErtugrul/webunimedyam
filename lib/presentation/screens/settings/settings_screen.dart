// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/user_settings_model.dart';
import '../../controllers/settings_controller.dart';
import 'settings_layout_spec.dart';
import 'widgets/settings_header.dart';
import 'widgets/settings_pickers.dart';
import 'widgets/settings_privacy_notice.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_theme_selector.dart';
import 'widgets/settings_tile.dart';

/// Ayarlar ekranı — tasarım birebir: blur'lu sabit header, alt açıklama,
/// Görünüm (tema segmenti + Liste/Çark pill'i), Oynatma Tercihleri
/// (Otomatik Oynat / Varsayılan Kalite / Ders Altyazıları), Bildirimler
/// (3 switch), Gizlilik ve Güvenlik ("Yüksek Koruma" rozeti + "Gizli Profil
/// Aktif" kutusu + master switch + AKTİVİTE BAZLI İZİNLER + durum butonları),
/// Dil ve Sistem, Hesap İşlemleri (şifre / önbellek rozeti / kırmızı çıkış)
/// ve sürüm dipnotu.
///
/// Koddaki, tasarımda doğrudan karşılığı olmayan özellikler KORUNDU:
/// hata snackbar'ı (ever worker), yükleniyor durumu, görünürlük pick
/// sheet'leri (durum butonuna dokununca açılır → tavan mantığı korunur),
/// çıkış onay diyaloğu, giriş animasyonları.
/// Ekran state'i yoktur (setState kullanılmaz) — tüm reaktivite Rx + Obx.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller;
  Worker? _errorWorker;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<SettingsController>();
    _errorWorker = ever(_controller.errorMessage, (message) {
      if (message != null && mounted) {
        final scheme = Theme.of(context).colorScheme;
        Get.snackbar(
          'Hata',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: scheme.error,
          colorText: scheme.onError,
          margin: const EdgeInsets.all(12),
        );
        _controller.errorMessage.value = null;
      }
    });
  }

  @override
  void dispose() {
    _errorWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = SettingsLayoutSpec.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Obx(() {
        final s = _controller.settings.value;
        final isLoading = _controller.isLoading.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SettingsHeader(spec: spec),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
                  child: (isLoading && s == null)
                      ? Padding(
                          padding: EdgeInsets.only(top: 120.h),
                          child: const CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : _buildContent(context, spec, s),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ═══════════════════════════ İçerik ═══════════════════════════

  Widget _buildContent(
    BuildContext context,
    SettingsLayoutSpec spec,
    UserSettingsModel? s,
  ) {
    final c = _controller;
    final scheme = Theme.of(context).colorScheme;
    final isPrivate = c.profileVisibility.value == VisibilityOption.private;

    final sections = <Widget>[
      // ── 1. GÖRÜNÜM ────────────────────────────────────────────
      SettingsSection(
        spec: spec,
        icon: Icons.palette_rounded,
        title: 'Görünüm',
        divided: false,
        padding: EdgeInsets.all(spec.cardPadding.w),
        children: [
          Text(
            'Tema Seçimi',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: spec.labelFontSize.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spec.labelGap.h),
          SettingsThemeSelector(
            spec: spec,
            current: s?.theme ?? 'system',
            onChanged: c.changeTheme,
          ),
          SizedBox(height: spec.cardInnerGap.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ana Sayfa Akış Şekli',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: spec.rowTitleFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: spec.rowGap.h),
                    Text(
                      'Çark (Carousel) veya Dikey Liste',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: spec.rowSubtitleFontSize.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              SettingsFeedModeToggle(
                spec: spec,
                current: c.homeLayout.value,
                onChanged: c.changeHomeLayout,
              ),
            ],
          ),
        ],
      ),

      SizedBox(height: spec.sectionGap.h),

      // ── 2. OYNATMA TERCİHLERİ ─────────────────────────────────
      SettingsSection(
        spec: spec,
        icon: Icons.smart_display_outlined,
        title: 'Oynatma Tercihleri',
        children: [
          SettingsSwitchRow(
            spec: spec,
            title: 'Otomatik Oynat',
            subtitle: 'Akıştaki videolar sessizce başlasın',
            value: s?.autoplay ?? true,
            onChanged: (_) => c.toggleAutoplay(),
          ),
          SettingsRow(
            spec: spec,
            title: 'Varsayılan Kalite',
            subtitle: 'Hücresel ve Wi-Fi için üst sınır',
            onTap: () => showSettingsQualityPicker(
              context: context,
              spec: spec,
              current: c.videoQuality.value,
              onChanged: c.changeVideoQuality,
            ),
            trailing: _QualityButton(spec: spec, label: c.videoQuality.value),
          ),
          SettingsSwitchRow(
            spec: spec,
            title: 'Ders Altyazıları',
            subtitle: 'Otomatik Türkçe transkript desteği',
            value: c.subtitlesEnabled.value,
            onChanged: c.toggleSubtitles,
          ),
        ],
      ),

      SizedBox(height: spec.sectionGap.h),

      // ── 3. BİLDİRİMLER ────────────────────────────────────────
      SettingsSection(
        spec: spec,
        icon: Icons.notifications_active_rounded,
        title: 'Bildirimler',
        children: [
          SettingsSwitchRow(
            spec: spec,
            title: 'Anlık Push Bildirimleri',
            subtitle: 'Kampüs canlı yayınları ve duyurular',
            value: s?.notificationsEnabled ?? true,
            onChanged: (_) => c.toggleNotifications(),
          ),
          SettingsSwitchRow(
            spec: spec,
            title: 'Yeni Video Yüklendiğinde',
            subtitle: 'Sadece takip edilen kulüpler ve hocalar',
            value: s?.notifyNewVideos ?? true,
            onChanged: (_) => c.toggleNotifyNewVideos(),
          ),
          SettingsSwitchRow(
            spec: spec,
            title: 'Yorum Yanıtı ve Beğeniler',
            subtitle: 'Topluluk etkileşim güncellemeleri',
            value: c.notifyInteractions.value,
            onChanged: c.toggleNotifyInteractions,
          ),
        ],
      ),

      SizedBox(height: spec.sectionGap.h),

      // ── 4. GİZLİLİK VE GÜVENLİK ───────────────────────────────
      SettingsSection(
        spec: spec,
        icon: Icons.shield_outlined,
        title: 'Gizlilik ve Güvenlik',
        trailing: isPrivate ? _ProtectionBadge(spec: spec) : null,
        aboveCard: isPrivate
            ? Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: SettingsPrivacyNotice(spec: spec),
              )
            : null,
        divided: false,
        children: [
          // Master switch (tasarımda satır zemini koyu: container-high)
          SettingsSwitchRow(
            spec: spec,
            title: 'Gizli Profil Modu',
            titleIcon: Icon(
              Icons.lock_rounded,
              size: 16.sp,
              color: scheme.primary,
            ),
            subtitle: 'Arama sonuçlarında yalnızca onaylı öğrenciler görebilir',
            value: isPrivate,
            color: scheme.surfaceContainerHigh,
            onChanged: (v) => c.changeProfileVisibility(
              v ? VisibilityOption.private : VisibilityOption.public,
            ),
          ),
          // "AKTİVİTE BAZLI İZİNLER" şeridi
          Container(
            width: double.infinity,
            color: scheme.surfaceContainerLowest,
            padding: EdgeInsets.symmetric(
              horizontal: spec.stripPaddingH.w,
              vertical: spec.stripPaddingV.h,
            ),
            child: Text(
              'AKTİVİTE BAZLI İZİNLER',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: spec.stripFontSize.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          _activityRow(
            context,
            spec,
            Icons.history_rounded,
            'İzleme Geçmişi',
            'Hangi dersleri izlediğiniz',
            s?.watchHistoryVisibility ?? VisibilityOption.public,
            c.changeWatchHistoryVisibility,
          ),
          _dividerRow(spec, scheme),
          _activityRow(
            context,
            spec,
            Icons.thumb_up_rounded,
            'Beğenilen Videolar',
            'Beğendiğiniz yayın ve içerikler',
            s?.likesVisibility ?? VisibilityOption.public,
            c.changeLikesVisibility,
          ),
          _dividerRow(spec, scheme),
          _activityRow(
            context,
            spec,
            Icons.bookmark_rounded,
            'Favori Dersler & Oynatma Listeleri',
            'Kaydettiğiniz arşivler',
            s?.favoritesVisibility ?? VisibilityOption.public,
            c.changeFavoritesVisibility,
          ),
          _dividerRow(spec, scheme),
          _activityRow(
            context,
            spec,
            Icons.forum_rounded,
            'Kampüs Yorumları',
            'Yayınlara bıraktığınız notlar',
            s?.commentsVisibility ?? VisibilityOption.public,
            c.changeCommentsVisibility,
          ),
        ],
      ),

      SizedBox(height: spec.sectionGap.h),

      // ── 5. DİL VE SİSTEM ──────────────────────────────────────
      SettingsSection(
        spec: spec,
        icon: Icons.language_rounded,
        title: 'Dil ve Sistem',
        children: [
          SettingsRow(
            spec: spec,
            title: 'Uygulama Dili',
            subtitle: 'Arayüz ve yayın dili tercihi',
            onTap: () {
              // TODO: dil seçme akışı
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Türkçe (TR)',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: spec.qualityFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: spec.qualityIconSize.sp,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          SettingsSwitchRow(
            spec: spec,
            title: 'Hareketi Azalt',
            subtitle: 'Animasyon ve akış geçişlerini sadeleştir',
            value: c.reduceMotion.value,
            onChanged: c.toggleReduceMotion,
          ),
        ],
      ),

      SizedBox(height: spec.sectionGap.h),

      // ── 6. HESAP İŞLEMLERİ ────────────────────────────────────
      SettingsSection(
        spec: spec,
        icon: Icons.manage_accounts_rounded,
        title: 'Hesap İşlemleri',
        divided: false,
        children: [
          SettingsRow(
            spec: spec,
            icon: Icons.key_rounded,
            title: 'Şifre Değiştir',
            onTap: () => Get.toNamed(AppRoutes.changePassword),
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: spec.qualityIconSize.sp,
              color: scheme.onSurfaceVariant,
            ),
          ),
          _dividerRow(spec, scheme),
          SettingsRow(
            spec: spec,
            icon: Icons.cleaning_services_rounded,
            title: 'Önbelleği Temizle',
            subtitle: 'Çevrimdışı ders kopyaları ve geçici veriler',
            onTap: c.clearCacheWithBadge,
            trailing: SettingsCacheBadge(
              spec: spec,
              cleared: c.cacheBadgeCleared.value,
            ),
          ),
          _dividerRow(spec, scheme),
          // Kırmızı "Oturumu Kapat" butonu (bg-error-container)
          Padding(
            padding: EdgeInsets.all(spec.logoutAreaPadding.w),
            child: Material(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(spec.logoutButtonRadius.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(spec.logoutButtonRadius.r),
                onTap: () => _confirmSignOut(context, spec),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: spec.logoutButtonPaddingV.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: spec.logoutIconSize.sp,
                        color: scheme.onError,
                      ),
                      SizedBox(width: spec.logoutGap.w),
                      Text(
                        'Oturumu Kapat',
                        style: TextStyle(
                          color: scheme.onError,
                          fontSize: spec.logoutFontSize.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spec.contentPaddingH.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Alt açıklama (tasarım: pt-space-xs pb-space-md)
          Padding(
            padding: EdgeInsets.only(
              top: spec.subtitleTopPadding.h,
              bottom: spec.subtitleBottomPadding.h,
            ),
            child: Text(
              'Uygulama tercihlerinizi, gizlilik düzeyinizi ve video '
              'deneyiminizi yönetin.',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: spec.subtitleFontSize.sp,
                height: 20 / 14,
              ),
            ),
          ),
          ...sections
              .animate(interval: 60.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          _buildFooter(context, spec),
        ],
      ),
    );
  }

  // ═══════════════════════════ Parçalar ═══════════════════════════

  Widget _activityRow(
    BuildContext context,
    SettingsLayoutSpec spec,
    IconData icon,
    String title,
    String subtitle,
    VisibilityOption current,
    Future<void> Function(VisibilityOption) onChanged,
  ) {
    return SettingsRow(
      spec: spec,
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: SettingsStateButton(
        spec: spec,
        isPrivate: current == VisibilityOption.private,
        // Mevcut pick sheet'i korundu: tavan (ceiling) mantığı + açıklama
        // buradan devam ediyor. Tasarım JS'i doğrudan çeviriyor; ancak
        // tavan kısıtı kullanıcıya açıklansın diye sheet tercih edildi.
        onTap: () => showSettingsVisibilitySheet(
          context: context,
          spec: spec,
          title: title,
          subtitle: subtitle,
          current: current,
          ceiling: _controller.profileVisibility.value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _dividerRow(SettingsLayoutSpec spec, ColorScheme scheme) => Container(
    height: 1,
    margin: EdgeInsets.symmetric(horizontal: spec.dividerInset.w),
    color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
  );

  Widget _buildFooter(BuildContext context, SettingsLayoutSpec spec) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        top: spec.sectionGap.h,
        bottom: spec.footerBottomSpacing.h,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_rounded,
                size: spec.footerIconSize.sp,
                color: scheme.primary.withValues(alpha: 0.6),
              ),
              SizedBox(width: spec.footerGap.w),
              Text(
                'ÜniTV Campus Media Hub',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontSize: spec.footerTitleFontSize.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Sürüm 2.4.1 (Build 8904) · Lisanslı Üniversite Ağı',
            style: TextStyle(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              fontSize: spec.footerVersionFontSize.sp,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    SettingsLayoutSpec spec,
  ) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spec.dialogRadius.r),
        ),
        icon: Icon(Icons.logout_rounded, color: scheme.error, size: 32.sp),
        title: Text(
          'Çıkış Yap?',
          style: TextStyle(
            fontSize: spec.dialogTitleFontSize.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Hesabından çıkmak istediğine emin misin?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              minimumSize: Size(120.w, spec.dialogButtonHeight.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: Text(
              'Çıkış Yap',
              style: TextStyle(
                fontSize: spec.dialogButtonFontSize.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.signOut();
    }
  }
}

// ═══════════════════════════ Ekran-özel görseller ═══════════════════════════

/// "1080p (FHD) ⌄" kalite butonu (bg-surface-container-highest + primary).
class _QualityButton extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final String label;
  const _QualityButton({required this.spec, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spec.qualityPaddingH.w,
        vertical: spec.qualityPaddingV.h,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(spec.qualityRadius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: scheme.primary,
              fontSize: spec.qualityFontSize.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.expand_more_rounded,
            size: spec.qualityIconSize.sp,
            color: scheme.primary,
          ),
        ],
      ),
    );
  }
}

/// "Yüksek Koruma" rozeti (gizli profil aktifken; nabız atan nokta).
class _ProtectionBadge extends StatelessWidget {
  final SettingsLayoutSpec spec;
  const _ProtectionBadge({required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spec.badgePaddingH.w,
        vertical: spec.badgePaddingV.h,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                width: spec.badgeDotSize.w,
                height: spec.badgeDotSize.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 0.25, end: 1, duration: 900.ms),
          SizedBox(width: spec.badgeGap.w),
          Text(
            'Yüksek Koruma',
            style: TextStyle(
              color: scheme.primary,
              fontSize: spec.badgeFontSize.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
