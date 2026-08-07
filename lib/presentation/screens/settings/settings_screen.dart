// lib/presentation/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/user_settings_model.dart';
import '../../controllers/settings_controller.dart';
import 'utils/settings_sizes.dart';
import 'widgets/ceiling_note.dart';
import 'widgets/section_header.dart';
import 'widgets/settings_divider.dart';
import 'widgets/settings_tile.dart';
import 'widgets/switch_tile.dart';
import 'widgets/visibility_tile.dart';

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (TEK DALLANMA NOKTASI)
// ═══════════════════════════════════════════════════════════

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
    // KURAL 5 — TEK DALLANMA NOKTASI
    final SettingsSizes sizes = Responsive.isTablet(context)
        ? const SettingsTabletSizes()
        : const SettingsPhoneSizes();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Obx(() {
        final s = _controller.settings.value;
        final isLoading = _controller.isLoading.value;
        final profVis = _controller.profileVisibility.value;

        if (isLoading && s == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.only(bottom: sizes.listBottomPadding),
          children: [
            // ═══ GÖRÜNÜM ═══════════════════════════════════════
            SettingsSectionHeader(sizes: sizes, title: 'Görünüm'),
            SettingsTile(
              sizes: sizes,
              icon: Icons.palette_outlined,
              title: 'Tema',
              subtitle: _themeLabel(s?.theme),
              onTap: () => _showThemeDialog(context, sizes),
            ),
            Obx(
              () => SettingsTile(
                sizes: sizes,
                icon: Icons.view_agenda_outlined,
                title: 'Ana Sayfa Görünümü',
                subtitle: _homeLayoutLabel(_controller.homeLayout.value),
                onTap: () => _showHomeLayoutDialog(context, sizes),
              ),
            ),

            // ═══ OYNATMA ═══════════════════════════════════════
            SettingsDivider(sizes: sizes),
            SettingsSectionHeader(sizes: sizes, title: 'Oynatma'),
            SettingsSwitchTile(
              sizes: sizes,
              value: s?.autoplay ?? true,
              onChanged: (_) => _controller.toggleAutoplay(),
              icon: Icons.play_circle_outline,
              title: 'Otomatik Oynat',
              subtitle: 'Sıradaki videoyu otomatik başlat',
            ),

            // ═══ BİLDİRİMLER ════════════════════════════════════
            SettingsDivider(sizes: sizes),
            SettingsSectionHeader(sizes: sizes, title: 'Bildirimler'),
            SettingsSwitchTile(
              sizes: sizes,
              value: s?.notificationsEnabled ?? true,
              onChanged: (_) => _controller.toggleNotifications(),
              icon: Icons.notifications_outlined,
              title: 'Bildirimler',
              subtitle: 'Tüm bildirimleri aç/kapat',
            ),
            if (s?.notificationsEnabled ?? true) ...[
              SettingsSwitchTile(
                sizes: sizes,
                value: s?.notifyNewVideos ?? true,
                onChanged: (_) => _controller.toggleNotifyNewVideos(),
                icon: Icons.ondemand_video_outlined,
                title: 'Yeni Video',
                subtitle: 'Takip ettiğin kanalların yeni videoları',
              ),
            ],

            // ═══ GİZLİLİK ═══════════════════════════════════════
            SettingsDivider(sizes: sizes),
            SettingsSectionHeader(sizes: sizes, title: 'Gizlilik'),

            SettingsVisibilityTile(
              sizes: sizes,
              icon: Icons.account_circle_outlined,
              title: 'Profil Görünürlüğü',
              subtitle: 'Profilini kimler görebilir?',
              current: profVis,
              ceiling: null,
              onChanged: _controller.changeProfileVisibility,
            ),

            SettingsCeilingNote(sizes: sizes, profileVisibility: profVis),

            Padding(
              padding: EdgeInsets.fromLTRB(
                sizes.sectionHeaderPaddingLeft,
                sizes.sectionHeaderPaddingTop,
                sizes.sectionHeaderPaddingRight,
                sizes.sectionHeaderPaddingBottom,
              ),
              child: Text(
                'Aktivite Görünürlüğü'.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: sizes.sectionHeaderFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: sizes.sectionHeaderLetterSpacing,
                ),
              ),
            ),

            SettingsVisibilityTile(
              sizes: sizes,
              icon: Icons.history_outlined,
              title: 'İzleme Geçmişi',
              subtitle: 'İzlediğin videolar',
              current: s?.watchHistoryVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeWatchHistoryVisibility,
            ),
            SettingsVisibilityTile(
              sizes: sizes,
              icon: Icons.thumb_up_outlined,
              title: 'Beğeniler',
              subtitle: 'Beğendiğin videolar',
              current: s?.likesVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeLikesVisibility,
            ),
            SettingsVisibilityTile(
              sizes: sizes,
              icon: Icons.bookmark_border_outlined,
              title: 'Favoriler',
              subtitle: 'Favori listelerin',
              current: s?.favoritesVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeFavoritesVisibility,
            ),
            SettingsVisibilityTile(
              sizes: sizes,
              icon: Icons.chat_bubble_outline,
              title: 'Yorumlar',
              subtitle:
                  'Profilinde "yorum yaptığın videolar" listesi görünür mü? '
                  '(Yorumların, videoların altında her zaman herkese açıktır)',
              current: s?.commentsVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeCommentsVisibility,
            ),

            // ═══ HESAP ══════════════════════════════════════════
            SettingsDivider(sizes: sizes),
            SettingsSectionHeader(sizes: sizes, title: 'Hesap'),
            SettingsTile(
              sizes: sizes,
              icon: Icons.lock_outline,
              title: 'Şifre Değiştir',
              onTap: () => Get.toNamed(AppRoutes.changePassword),
            ),
            SettingsTile(
              sizes: sizes,
              icon: Icons.delete_sweep_outlined,
              title: 'Cache Temizle',
              subtitle: 'Yerel verileri temizle',
              onTap: _controller.clearCache,
            ),
            SettingsTile(
              sizes: sizes,
              icon: Icons.logout_outlined,
              title: 'Çıkış Yap',
              titleColor: Colors.red,
              onTap: _controller.signOut,
            ),
          ],
        );
      }),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsSizes sizes) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Tema',
          style: TextStyle(fontSize: sizes.dialogTitleFontSize),
        ),
        content: Obx(() {
          final String current = _controller.settings.value?.theme ?? 'system';
          return RadioGroup<String>(
            groupValue: current,
            onChanged: (String? v) {
              if (v != null) {
                _controller.changeTheme(v);
                Get.back();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ['system', 'light', 'dark']
                  .map(
                    (theme) => RadioListTile<String>(
                      title: Text(_themeLabel(theme)),
                      value: theme,
                    ),
                  )
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  String _themeLabel(String? theme) {
    switch (theme) {
      case 'dark':
        return 'Koyu';
      case 'light':
        return 'Açık';
      default:
        return 'Sistem';
    }
  }

  void _showHomeLayoutDialog(BuildContext context, SettingsSizes sizes) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Ana Sayfa Görünümü',
          style: TextStyle(fontSize: sizes.dialogTitleFontSize),
        ),
        content: Obx(() {
          final String currentLayout = _controller.homeLayout.value;
          return RadioGroup<String>(
            groupValue: currentLayout,
            onChanged: (String? v) {
              if (v != null) {
                _controller.changeHomeLayout(v);
                Get.back();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ['list', 'wheel']
                  .map(
                    (layout) => RadioListTile<String>(
                      title: Text(_homeLayoutLabel(layout)),
                      subtitle: Text(_homeLayoutSublabel(layout)),
                      value: layout,
                    ),
                  )
                  .toList(),
            ),
          );
        }),
      ),
    );
  }

  String _homeLayoutLabel(String? layout) {
    switch (layout) {
      case 'wheel':
        return 'Wheel Görünümü';
      default:
        return 'Liste Görünümü';
    }
  }

  String _homeLayoutSublabel(String layout) {
    switch (layout) {
      case 'wheel':
        return 'Videolar döner bir çark şeklinde gösterilir';
      default:
        return 'Videolar tam genişlikte alt alta listelenir';
    }
  }
}

// ═══════════════════════════════════════════════════════════
// TEKİL WIDGET'LAR (TEK SINIF, sizes İLE)
// ═══════════════════════════════════════════════════════════








