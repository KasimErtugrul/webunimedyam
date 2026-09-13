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
import 'widgets/settings_ceiling_note.dart';
import 'widgets/settings_hero.dart';
import 'widgets/settings_pickers.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

// Renk paleti — her grubun kendi rengi
const _cTheme = Color(0xFF8B5CF6);       // mor
const _cLayout = Color(0xFF14B8A6);      // teal
const _cAutoplay = Color(0xFFF59E0B);    // amber
const _cNotifications = Color(0xFFEC4899); // pembe
const _cNewVideos = Color(0xFFEF4444);   // kırmızı
const _cProfile = Color(0xFF3B82F6);     // mavi
const _cHistory = Color(0xFF6366F1);     // indigo
const _cLikes = Color(0xFF06B6D4);       // cyan
const _cFavorites = Color(0xFFF43F5E);   // rose
const _cComments = Color(0xFF10B981);    // yeşil
const _cPassword = Color(0xFF8B5CF6);    // mor
const _cCache = Color(0xFF64748B);       // slate
const _cLogout = Color(0xFFEF4444);      // kırmızı

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
        Get.snackbar(
          'Hata',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
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

        if (isLoading && s == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SettingsHero(spec: spec)),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: spec.maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spec.contentPaddingH.w,
                      vertical: spec.sectionSpacing.h,
                    ),
                    child: _buildContent(context, spec, s),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: spec.contentPaddingBottom.h),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SettingsLayoutSpec spec,
    UserSettingsModel? s,
  ) {
    final profVis = _controller.profileVisibility.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══ GÖRÜNÜM ═══════════════════════════════════════════════
        SettingsSection(
          spec: spec,
          title: 'Görünüm',
          children: [
            SettingsTile(
              spec: spec,
              icon: Icons.palette_rounded,
              iconColor: _cTheme,
              title: 'Tema',
              subtitle: _themeLabel(s?.theme),
              onTap: () => showSettingsThemePicker(
                context: context,
                spec: spec,
                current: s?.theme ?? 'system',
                onChanged: (v) => _controller.changeTheme(v),
              ),
            ),
            Obx(
              () => SettingsTile(
                spec: spec,
                icon: Icons.dashboard_customize_rounded,
                iconColor: _cLayout,
                title: 'Ana Sayfa Görünümü',
                subtitle: _layoutLabel(_controller.homeLayout.value),
                onTap: () => showSettingsHomeLayoutPicker(
                  context: context,
                  spec: spec,
                  current: _controller.homeLayout.value,
                  onChanged: (v) => _controller.changeHomeLayout(v),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: spec.sectionSpacing.h),

        // ═══ OYNATMA ═══════════════════════════════════════════════
        SettingsSection(
          spec: spec,
          title: 'Oynatma',
          children: [
            SettingsSwitchTile(
              spec: spec,
              icon: Icons.play_circle_rounded,
              iconColor: _cAutoplay,
              title: 'Otomatik Oynat',
              subtitle: 'Sıradaki videoyu otomatik başlat',
              value: s?.autoplay ?? true,
              onChanged: (_) => _controller.toggleAutoplay(),
            ),
          ],
        ),

        SizedBox(height: spec.sectionSpacing.h),

        // ═══ BİLDİRİMLER ═══════════════════════════════════════════
        SettingsSection(
          spec: spec,
          title: 'Bildirimler',
          children: [
            SettingsSwitchTile(
              spec: spec,
              icon: Icons.notifications_rounded,
              iconColor: _cNotifications,
              title: 'Bildirimler',
              subtitle: 'Tüm bildirimleri aç/kapat',
              value: s?.notificationsEnabled ?? true,
              onChanged: (_) => _controller.toggleNotifications(),
            ),
            if (s?.notificationsEnabled ?? true)
              SettingsSwitchTile(
                spec: spec,
                icon: Icons.ondemand_video_rounded,
                iconColor: _cNewVideos,
                title: 'Yeni Video',
                subtitle: 'Takip ettiğin kanalların yeni videoları',
                value: s?.notifyNewVideos ?? true,
                onChanged: (_) => _controller.toggleNotifyNewVideos(),
              ),
          ],
        ),

        SizedBox(height: spec.sectionSpacing.h),

        // ═══ GİZLİLİK ══════════════════════════════════════════════
        SettingsSection(
          spec: spec,
          title: 'Gizlilik',
          children: [
            SettingsVisibilityTile(
              spec: spec,
              icon: Icons.account_circle_rounded,
              iconColor: _cProfile,
              title: 'Profil Görünürlüğü',
              subtitle: 'Profilini kimler görebilir?',
              current: profVis,
              ceiling: null,
              onChanged: _controller.changeProfileVisibility,
            ),
          ],
        ),

        SettingsCeilingNote(spec: spec, profileVisibility: profVis),

        SizedBox(height: 12.h),

        SettingsSection(
          spec: spec,
          title: 'Aktivite Görünürlüğü',
          children: [
            SettingsVisibilityTile(
              spec: spec,
              icon: Icons.history_rounded,
              iconColor: _cHistory,
              title: 'İzleme Geçmişi',
              subtitle: 'İzlediğin videolar',
              current: s?.watchHistoryVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeWatchHistoryVisibility,
            ),
            SettingsVisibilityTile(
              spec: spec,
              icon: Icons.thumb_up_rounded,
              iconColor: _cLikes,
              title: 'Beğeniler',
              subtitle: 'Beğendiğin videolar',
              current: s?.likesVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeLikesVisibility,
            ),
            SettingsVisibilityTile(
              spec: spec,
              icon: Icons.bookmark_rounded,
              iconColor: _cFavorites,
              title: 'Favoriler',
              subtitle: 'Favori listelerin',
              current: s?.favoritesVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeFavoritesVisibility,
            ),
            SettingsVisibilityTile(
              spec: spec,
              icon: Icons.chat_bubble_rounded,
              iconColor: _cComments,
              title: 'Yorumlar',
              subtitle: 'Profilinde görünen yorumlar',
              current: s?.commentsVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeCommentsVisibility,
            ),
          ],
        ),

        SizedBox(height: spec.sectionSpacing.h),

        // ═══ HESAP ═════════════════════════════════════════════════
        SettingsSection(
          spec: spec,
          title: 'Hesap',
          children: [
            SettingsTile(
              spec: spec,
              icon: Icons.lock_rounded,
              iconColor: _cPassword,
              title: 'Şifre Değiştir',
              subtitle: 'Hesap şifreni güncelle',
              onTap: () => Get.toNamed(AppRoutes.changePassword),
            ),
            SettingsTile(
              spec: spec,
              icon: Icons.cleaning_services_rounded,
              iconColor: _cCache,
              title: 'Cache Temizle',
              subtitle: 'Yerel verileri temizle',
              onTap: _controller.clearCache,
            ),
            SettingsTile(
              spec: spec,
              icon: Icons.logout_rounded,
              iconColor: _cLogout,
              title: 'Çıkış Yap',
              subtitle: 'Hesabından güvenli çıkış',
              titleColor: _cLogout,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: _cLogout.withValues(alpha: 0.6),
                size: spec.tileTrailingIconSize.sp,
              ),
              onTap: () => _confirmSignOut(context, spec),
            ),
          ],
        ),
      ]
          .animate(interval: 60.ms)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    SettingsLayoutSpec spec,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spec.dialogRadius.r),
        ),
        icon: Icon(
          Icons.logout_rounded,
          color: _cLogout,
          size: 32.sp,
        ),
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
              backgroundColor: _cLogout,
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

  String _themeLabel(String? theme) => switch (theme) {
        'dark' => 'Koyu',
        'light' => 'Açık',
        _ => 'Sistem',
      };

  String _layoutLabel(String? layout) =>
      layout == 'wheel' ? 'Wheel Görünümü' : 'Liste Görünümü';
}