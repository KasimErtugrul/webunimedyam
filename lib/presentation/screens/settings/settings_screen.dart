// lib/presentation/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/user_settings_model.dart';
import '../../controllers/settings_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarTitleSize = 20;

  // Padding
  static const double listBottomPadding = 32;
  static const double sectionHeaderPaddingLeft = 16;
  static const double sectionHeaderPaddingTop = 16;
  static const double sectionHeaderPaddingRight = 16;
  static const double sectionHeaderPaddingBottom = 4;
  static const double sectionHeaderFontSize = 11;
  static const double sectionHeaderLetterSpacing = 1.2;
  static const double tileContentPaddingHorizontal = 16;

  // Divider
  static const double dividerHeight = 8;
  static const double dividerThickness = 0.5;

  // Settings Tile
  static const double tileIconSize = 24;
  static const double tileTitleFontSize = 16;
  static const double tileSubtitleFontSize = 13;
  static const double tileTrailingIconSize = 20;

  // SwitchListTile
  static const double switchTitleFontSize = 16;
  static const double switchSubtitleFontSize = 13;
  static const double switchIconSize = 24;

  // Visibility Tile
  static const double visIconSize = 24;
  static const double visTitleFontSize = 16;
  static const double visSubtitleFontSize = 13;
  static const double visBadgePaddingHorizontal = 8;
  static const double visBadgePaddingVertical = 4;
  static const double visBadgeBorderRadius = 12;
  static const double visBadgeBorderWidth = 0.5;
  static const double visBadgeIconSize = 12;
  static const double visBadgeFontSize = 11;
  static const double visTrailingChevronSize = 20;
  static const double visTrailingSpacing = 4;

  // Visibility Bottom Sheet
  static const double sheetBorderRadius = 16;
  static const double sheetHandleWidth = 40;
  static const double sheetHandleHeight = 4;
  static const double sheetHandleBorderRadius = 2;
  static const double sheetHandleSpacing = 8;
  static const double sheetTitleFontSize = 17;
  static const double sheetSubtitleFontSize = 13;
  static const double sheetOptionSpacing = 12;
  static const double sheetBottomPadding = 16;
  static const double sheetOptionLeadingContainerSize = 36;
  static const double sheetOptionLeadingBorderRadius = 8;
  static const double sheetOptionLeadingIconSize = 20;
  static const double sheetOptionTitleFontSize = 15;
  static const double sheetOptionSubtitleFontSize = 12;
  static const double sheetOptionTrailingIconSize = 20;
  static const double sheetOptionTrailingLockSize = 16;

  // Visibility Option Row (disabled)
  static const double disabledOpacity = 0.35;

  // Ceiling Note
  static const double noteMarginLeft = 16;
  static const double noteMarginTop = 6;
  static const double noteMarginRight = 16;
  static const double noteMarginBottom = 2;
  static const double notePaddingHorizontal = 12;
  static const double notePaddingVertical = 9;
  static const double noteBorderRadius = 10;
  static const double noteBorderWidth = 0.8;
  static const double noteIconSize = 15;
  static const double noteIconSpacing = 8;
  static const double noteFontSize = 12;
  static const double noteLineHeight = 1.45;

  // Theme Dialog
  static const double dialogTitleFontSize = 16;

  // ✅ loadingStrokeWidth kaldırıldı (kullanılmıyor)
}

class _TabletSizes {
  // AppBar
  static const double appBarTitleSize = 24;

  // Padding
  static const double listBottomPadding = 40;
  static const double sectionHeaderPaddingLeft = 24;
  static const double sectionHeaderPaddingTop = 20;
  static const double sectionHeaderPaddingRight = 24;
  static const double sectionHeaderPaddingBottom = 6;
  static const double sectionHeaderFontSize = 14;
  static const double sectionHeaderLetterSpacing = 1.4;
  static const double tileContentPaddingHorizontal = 24;

  // Divider
  static const double dividerHeight = 10;
  static const double dividerThickness = 0.6;

  // Settings Tile
  static const double tileIconSize = 28;
  static const double tileTitleFontSize = 18;
  static const double tileSubtitleFontSize = 15;
  static const double tileTrailingIconSize = 24;

  // SwitchListTile
  static const double switchTitleFontSize = 18;
  static const double switchSubtitleFontSize = 15;
  static const double switchIconSize = 28;

  // Visibility Tile
  static const double visIconSize = 28;
  static const double visTitleFontSize = 18;
  static const double visSubtitleFontSize = 15;
  static const double visBadgePaddingHorizontal = 10;
  static const double visBadgePaddingVertical = 5;
  static const double visBadgeBorderRadius = 14;
  static const double visBadgeBorderWidth = 0.6;
  static const double visBadgeIconSize = 14;
  static const double visBadgeFontSize = 13;
  static const double visTrailingChevronSize = 24;
  static const double visTrailingSpacing = 6;

  // Visibility Bottom Sheet
  static const double sheetBorderRadius = 20;
  static const double sheetHandleWidth = 48;
  static const double sheetHandleHeight = 5;
  static const double sheetHandleBorderRadius = 3;
  static const double sheetHandleSpacing = 10;
  static const double sheetTitleFontSize = 20;
  static const double sheetSubtitleFontSize = 15;
  static const double sheetOptionSpacing = 14;
  static const double sheetBottomPadding = 20;
  static const double sheetOptionLeadingContainerSize = 44;
  static const double sheetOptionLeadingBorderRadius = 10;
  static const double sheetOptionLeadingIconSize = 24;
  static const double sheetOptionTitleFontSize = 17;
  static const double sheetOptionSubtitleFontSize = 14;
  static const double sheetOptionTrailingIconSize = 24;
  static const double sheetOptionTrailingLockSize = 18;

  // Visibility Option Row (disabled)
  static const double disabledOpacity = 0.35;

  // Ceiling Note
  static const double noteMarginLeft = 24;
  static const double noteMarginTop = 8;
  static const double noteMarginRight = 24;
  static const double noteMarginBottom = 4;
  static const double notePaddingHorizontal = 16;
  static const double notePaddingVertical = 12;
  static const double noteBorderRadius = 12;
  static const double noteBorderWidth = 1;
  static const double noteIconSize = 18;
  static const double noteIconSpacing = 10;
  static const double noteFontSize = 14;
  static const double noteLineHeight = 1.5;

  // Theme Dialog
  static const double dialogTitleFontSize = 18;

  // ✅ loadingStrokeWidth kaldırıldı (kullanılmıyor)
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
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
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: TextStyle(fontSize: _PhoneSizes.appBarTitleSize.sp),
        ),
      ),
      body: Obx(() {
        final s = _controller.settings.value;
        final isLoading = _controller.isLoading.value;
        final profVis = _controller.profileVisibility.value;

        if (isLoading && s == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.only(bottom: _PhoneSizes.listBottomPadding.h),
          children: [
            // ═══ GÖRÜNÜM ═══════════════════════════════════════
            _SectionHeaderPhone(title: 'Görünüm'),
            _SettingsTilePhone(
              icon: Icons.palette_outlined,
              title: 'Tema',
              subtitle: _themeLabel(s?.theme),
              onTap: () => _showThemeDialog(context),
            ),

            // ═══ OYNATMA ═══════════════════════════════════════
            _DividerPhone(),
            _SectionHeaderPhone(title: 'Oynatma'),
            _SwitchListTilePhone(
              value: s?.autoplay ?? true,
              onChanged: (_) => _controller.toggleAutoplay(),
              icon: Icons.play_circle_outline,
              title: 'Otomatik Oynat',
              subtitle: 'Sıradaki videoyu otomatik başlat',
            ),

            // ═══ BİLDİRİMLER ════════════════════════════════════
            _DividerPhone(),
            _SectionHeaderPhone(title: 'Bildirimler'),
            _SwitchListTilePhone(
              value: s?.notificationsEnabled ?? true,
              onChanged: (_) => _controller.toggleNotifications(),
              icon: Icons.notifications_outlined,
              title: 'Bildirimler',
              subtitle: 'Tüm bildirimleri aç/kapat',
            ),
            if (s?.notificationsEnabled ?? true) ...[
              _SwitchListTilePhone(
                value: s?.notifyNewVideos ?? true,
                onChanged: (_) => _controller.toggleNotifyNewVideos(),
                icon: Icons.ondemand_video_outlined,
                title: 'Yeni Video',
                subtitle: 'Takip ettiğin kanalların yeni videoları',
              ),
            ],

            // ═══ GİZLİLİK ═══════════════════════════════════════
            _DividerPhone(),
            _SectionHeaderPhone(title: 'Gizlilik'),

            _VisibilityTilePhone(
              icon: Icons.account_circle_outlined,
              title: 'Profil Görünürlüğü',
              subtitle: 'Profilini kimler görebilir?',
              current: profVis,
              ceiling: null,
              onChanged: _controller.changeProfileVisibility,
            ),

            _CeilingNotePhone(profileVisibility: profVis),

            Padding(
              padding: EdgeInsets.fromLTRB(
                _PhoneSizes.sectionHeaderPaddingLeft.w,
                _PhoneSizes.sectionHeaderPaddingTop.h,
                _PhoneSizes.sectionHeaderPaddingRight.w,
                _PhoneSizes.sectionHeaderPaddingBottom.h,
              ),
              child: Text(
                'Aktivite Görünürlüğü'.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.sectionHeaderFontSize.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: _PhoneSizes.sectionHeaderLetterSpacing,
                ),
              ),
            ),

            _VisibilityTilePhone(
              icon: Icons.history_outlined,
              title: 'İzleme Geçmişi',
              subtitle: 'İzlediğin videolar',
              current: s?.watchHistoryVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeWatchHistoryVisibility,
            ),
            _VisibilityTilePhone(
              icon: Icons.thumb_up_outlined,
              title: 'Beğeniler',
              subtitle: 'Beğendiğin videolar',
              current: s?.likesVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeLikesVisibility,
            ),
            _VisibilityTilePhone(
              icon: Icons.bookmark_border_outlined,
              title: 'Favoriler',
              subtitle: 'Favori listelerin',
              current: s?.favoritesVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeFavoritesVisibility,
            ),
            _VisibilityTilePhone(
              icon: Icons.chat_bubble_outline,
              title: 'Yorumlar',
              subtitle: 'Yaptığın yorumlar',
              current: s?.commentsVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeCommentsVisibility,
            ),

            // ═══ HESAP ══════════════════════════════════════════
            _DividerPhone(),
            _SectionHeaderPhone(title: 'Hesap'),
            _SettingsTilePhone(
              icon: Icons.delete_sweep_outlined,
              title: 'Cache Temizle',
              subtitle: 'Yerel verileri temizle',
              onTap: _controller.clearCache,
            ),
            _SettingsTilePhone(
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

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: TextStyle(fontSize: _TabletSizes.appBarTitleSize),
        ),
      ),
      body: Obx(() {
        final s = _controller.settings.value;
        final isLoading = _controller.isLoading.value;
        final profVis = _controller.profileVisibility.value;

        if (isLoading && s == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.only(bottom: _TabletSizes.listBottomPadding),
          children: [
            // ═══ GÖRÜNÜM ═══════════════════════════════════════
            _SectionHeaderTablet(title: 'Görünüm'),
            _SettingsTileTablet(
              icon: Icons.palette_outlined,
              title: 'Tema',
              subtitle: _themeLabel(s?.theme),
              onTap: () => _showThemeDialog(context),
            ),

            // ═══ OYNATMA ═══════════════════════════════════════
            _DividerTablet(),
            _SectionHeaderTablet(title: 'Oynatma'),
            _SwitchListTileTablet(
              value: s?.autoplay ?? true,
              onChanged: (_) => _controller.toggleAutoplay(),
              icon: Icons.play_circle_outline,
              title: 'Otomatik Oynat',
              subtitle: 'Sıradaki videoyu otomatik başlat',
            ),

            // ═══ BİLDİRİMLER ════════════════════════════════════
            _DividerTablet(),
            _SectionHeaderTablet(title: 'Bildirimler'),
            _SwitchListTileTablet(
              value: s?.notificationsEnabled ?? true,
              onChanged: (_) => _controller.toggleNotifications(),
              icon: Icons.notifications_outlined,
              title: 'Bildirimler',
              subtitle: 'Tüm bildirimleri aç/kapat',
            ),
            if (s?.notificationsEnabled ?? true) ...[
              _SwitchListTileTablet(
                value: s?.notifyNewVideos ?? true,
                onChanged: (_) => _controller.toggleNotifyNewVideos(),
                icon: Icons.ondemand_video_outlined,
                title: 'Yeni Video',
                subtitle: 'Takip ettiğin kanalların yeni videoları',
              ),
            ],

            // ═══ GİZLİLİK ═══════════════════════════════════════
            _DividerTablet(),
            _SectionHeaderTablet(title: 'Gizlilik'),

            _VisibilityTileTablet(
              icon: Icons.account_circle_outlined,
              title: 'Profil Görünürlüğü',
              subtitle: 'Profilini kimler görebilir?',
              current: profVis,
              ceiling: null,
              onChanged: _controller.changeProfileVisibility,
            ),

            _CeilingNoteTablet(profileVisibility: profVis),

            Padding(
              padding: EdgeInsets.fromLTRB(
                _TabletSizes.sectionHeaderPaddingLeft,
                _TabletSizes.sectionHeaderPaddingTop,
                _TabletSizes.sectionHeaderPaddingRight,
                _TabletSizes.sectionHeaderPaddingBottom,
              ),
              child: Text(
                'Aktivite Görünürlüğü'.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.sectionHeaderFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: _TabletSizes.sectionHeaderLetterSpacing,
                ),
              ),
            ),

            _VisibilityTileTablet(
              icon: Icons.history_outlined,
              title: 'İzleme Geçmişi',
              subtitle: 'İzlediğin videolar',
              current: s?.watchHistoryVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeWatchHistoryVisibility,
            ),
            _VisibilityTileTablet(
              icon: Icons.thumb_up_outlined,
              title: 'Beğeniler',
              subtitle: 'Beğendiğin videolar',
              current: s?.likesVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeLikesVisibility,
            ),
            _VisibilityTileTablet(
              icon: Icons.bookmark_border_outlined,
              title: 'Favoriler',
              subtitle: 'Favori listelerin',
              current: s?.favoritesVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeFavoritesVisibility,
            ),
            _VisibilityTileTablet(
              icon: Icons.chat_bubble_outline,
              title: 'Yorumlar',
              subtitle: 'Yaptığın yorumlar',
              current: s?.commentsVisibility ?? VisibilityOption.public,
              ceiling: profVis,
              onChanged: _controller.changeCommentsVisibility,
            ),

            // ═══ HESAP ══════════════════════════════════════════
            _DividerTablet(),
            _SectionHeaderTablet(title: 'Hesap'),
            _SettingsTileTablet(
              icon: Icons.delete_sweep_outlined,
              title: 'Cache Temizle',
              subtitle: 'Yerel verileri temizle',
              onTap: _controller.clearCache,
            ),
            _SettingsTileTablet(
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

  void _showThemeDialog(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final titleSize = isTablet ? _TabletSizes.dialogTitleFontSize : _PhoneSizes.dialogTitleFontSize.sp;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tema', style: TextStyle(fontSize: titleSize)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final theme in ['system', 'light', 'dark'])
              RadioListTile<String>(
                title: Text(_themeLabel(theme)),
                value: theme,
                groupValue: _controller.settings.value?.theme,
                activeColor: AppTheme.primaryColor,
                onChanged: (v) {
                  if (v != null) {
                    _controller.changeTheme(v);
                    Get.back();
                  }
                },
              ),
          ],
        ),
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
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (PHONE)
// ═══════════════════════════════════════════════════════════════════════

// ─── Section Header (Phone) ──────────────────────────────────────────────────

class _SectionHeaderPhone extends StatelessWidget {
  final String title;
  const _SectionHeaderPhone({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _PhoneSizes.sectionHeaderPaddingLeft.w,
        _PhoneSizes.sectionHeaderPaddingTop.h,
        _PhoneSizes.sectionHeaderPaddingRight.w,
        _PhoneSizes.sectionHeaderPaddingBottom.h,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _PhoneSizes.sectionHeaderFontSize.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: _PhoneSizes.sectionHeaderLetterSpacing,
        ),
      ),
    );
  }
}

// ─── Divider (Phone) ──────────────────────────────────────────────────────────

class _DividerPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: _PhoneSizes.dividerHeight.h,
      thickness: _PhoneSizes.dividerThickness,
      color: AppTheme.surface(context),
    );
  }
}

// ─── Settings Tile (Phone) ──────────────────────────────────────────────────

class _SettingsTilePhone extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTilePhone({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: _PhoneSizes.tileIconSize.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.textPri(context),
          fontSize: _PhoneSizes.tileTitleFontSize.sp,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.tileSubtitleFontSize.sp,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textSec(context),
        size: _PhoneSizes.tileTrailingIconSize.sp,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.tileContentPaddingHorizontal.w,
      ),
    );
  }
}

// ─── Switch List Tile (Phone) ────────────────────────────────────────────────

class _SwitchListTilePhone extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final String title;
  final String subtitle;

  const _SwitchListTilePhone({
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: _PhoneSizes.switchIconSize.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: _PhoneSizes.switchTitleFontSize.sp,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _PhoneSizes.switchSubtitleFontSize.sp,
        ),
      ),
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.tileContentPaddingHorizontal.w,
      ),
    );
  }
}

// ─── Ceiling Note (Phone) ────────────────────────────────────────────────────

class _CeilingNotePhone extends StatelessWidget {
  final VisibilityOption profileVisibility;
  const _CeilingNotePhone({required this.profileVisibility});

  @override
  Widget build(BuildContext context) {
    if (profileVisibility == VisibilityOption.public) return const SizedBox.shrink();

    final isPrivate = profileVisibility == VisibilityOption.private;
    final color = isPrivate ? Colors.orange : Colors.blue;
    final icon = isPrivate ? Icons.lock_outline : Icons.people_outlined;
    final msg = isPrivate
        ? 'Profil gizli — aktiviteler en fazla "Gizli" yapılabilir.'
        : 'Profil arkadaşlara açık — aktiviteler en fazla "Arkadaşlara açık" yapılabilir.';

    return Container(
      margin: EdgeInsets.fromLTRB(
        _PhoneSizes.noteMarginLeft.w,
        _PhoneSizes.noteMarginTop.h,
        _PhoneSizes.noteMarginRight.w,
        _PhoneSizes.noteMarginBottom.h,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.notePaddingHorizontal.w,
        vertical: _PhoneSizes.notePaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(_PhoneSizes.noteBorderRadius.r),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
          width: _PhoneSizes.noteBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: _PhoneSizes.noteIconSize.sp, color: color),
          SizedBox(width: _PhoneSizes.noteIconSpacing.w),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: color,
                fontSize: _PhoneSizes.noteFontSize.sp,
                height: _PhoneSizes.noteLineHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Visibility Tile (Phone) ─────────────────────────────────────────────────

class _VisibilityTilePhone extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VisibilityOption current;
  final VisibilityOption? ceiling;
  final Future<void> Function(VisibilityOption) onChanged;

  const _VisibilityTilePhone({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.ceiling,
    required this.onChanged,
  });

  bool _isAllowed(VisibilityOption option) {
    if (ceiling == null) return true;
    const order = [
      VisibilityOption.private,
      VisibilityOption.friends,
      VisibilityOption.public,
    ];
    return order.indexOf(option) <= order.indexOf(ceiling!);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: _PhoneSizes.visIconSize.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: _PhoneSizes.visTitleFontSize.sp,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _PhoneSizes.visSubtitleFontSize.sp,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VisibilityBadgePhone(option: current),
          SizedBox(width: _PhoneSizes.visTrailingSpacing.w),
          Icon(
            Icons.chevron_right,
            color: AppTheme.textSec(context),
            size: _PhoneSizes.visTrailingChevronSize.sp,
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.tileContentPaddingHorizontal.w,
      ),
      onTap: () => _showSheet(context),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_PhoneSizes.sheetBorderRadius.r),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: _PhoneSizes.sheetHandleSpacing.h),
            Container(
              width: _PhoneSizes.sheetHandleWidth.w,
              height: _PhoneSizes.sheetHandleHeight.h,
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.sheetHandleBorderRadius.r,
                ),
              ),
            ),
            SizedBox(height: _PhoneSizes.sheetHandleSpacing.h),
            Text(
              title,
              style: TextStyle(
                fontSize: _PhoneSizes.sheetTitleFontSize.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPri(context),
              ),
            ),
            SizedBox(height: _PhoneSizes.sheetHandleSpacing.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: _PhoneSizes.sheetSubtitleFontSize.sp,
                color: AppTheme.textSec(context),
              ),
            ),
            SizedBox(height: _PhoneSizes.sheetOptionSpacing.h),
            for (final option in VisibilityOption.values)
              _VisibilityOptionRowPhone(
                option: option,
                isCurrent: option == current,
                isAllowed: _isAllowed(option),
                ceiling: ceiling,
                onTap: () {
                  if (!_isAllowed(option)) return;
                  Get.back();
                  onChanged(option);
                },
              ),
            SizedBox(height: _PhoneSizes.sheetBottomPadding.h),
          ],
        ),
      ),
    );
  }
}

// ─── Visibility Badge (Phone) ───────────────────────────────────────────────

class _VisibilityBadgePhone extends StatelessWidget {
  final VisibilityOption option;
  const _VisibilityBadgePhone({required this.option});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (option) {
      VisibilityOption.public => (
          Icons.public_outlined,
          Colors.green,
          'Herkese',
        ),
      VisibilityOption.friends => (
          Icons.people_outlined,
          Colors.blue,
          'Arkadaş',
        ),
      VisibilityOption.private => (Icons.lock_outline, Colors.orange, 'Gizli'),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.visBadgePaddingHorizontal.w,
        vertical: _PhoneSizes.visBadgePaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_PhoneSizes.visBadgeBorderRadius.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: _PhoneSizes.visBadgeBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _PhoneSizes.visBadgeIconSize.sp, color: color),
          SizedBox(width: _PhoneSizes.visTrailingSpacing.w),
          Text(
            label,
            style: TextStyle(
              fontSize: _PhoneSizes.visBadgeFontSize.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Visibility Option Row (Phone) ──────────────────────────────────────────

class _VisibilityOptionRowPhone extends StatelessWidget {
  final VisibilityOption option;
  final bool isCurrent;
  final bool isAllowed;
  final VisibilityOption? ceiling;
  final VoidCallback onTap;

  const _VisibilityOptionRowPhone({
    required this.option,
    required this.isCurrent,
    required this.isAllowed,
    required this.ceiling,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (iconData, color) = _iconAndColor(option);
    final dimmed = !isAllowed;

    return Opacity(
      opacity: dimmed ? _PhoneSizes.disabledOpacity : 1.0,
      child: ListTile(
        enabled: isAllowed,
        onTap: isAllowed ? onTap : null,
        leading: Container(
          width: _PhoneSizes.sheetOptionLeadingContainerSize.w,
          height: _PhoneSizes.sheetOptionLeadingContainerSize.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              _PhoneSizes.sheetOptionLeadingBorderRadius.r,
            ),
          ),
          child: Icon(
            iconData,
            color: color,
            size: _PhoneSizes.sheetOptionLeadingIconSize.sp,
          ),
        ),
        title: Text(
          option.label,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: _PhoneSizes.sheetOptionTitleFontSize.sp,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          dimmed
              ? 'Profil "${ceiling!.label}" olduğu için seçilemiyor'
              : option.sublabel,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _PhoneSizes.sheetOptionSubtitleFontSize.sp,
          ),
        ),
        trailing: isCurrent
            ? Icon(
                Icons.check_rounded,
                color: AppTheme.primaryColor,
                size: _PhoneSizes.sheetOptionTrailingIconSize.sp,
              )
            : dimmed
                ? Icon(
                    Icons.lock_outline,
                    color: AppTheme.textSec(context),
                    size: _PhoneSizes.sheetOptionTrailingLockSize.sp,
                  )
                : null,
      ),
    );
  }

  (IconData, Color) _iconAndColor(VisibilityOption o) {
    switch (o) {
      case VisibilityOption.public:
        return (Icons.public_outlined, Colors.green);
      case VisibilityOption.friends:
        return (Icons.people_outlined, Colors.blue);
      case VisibilityOption.private:
        return (Icons.lock_outline, Colors.orange);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (TABLET)
// ═══════════════════════════════════════════════════════════════════════

// ─── Section Header (Tablet) ──────────────────────────────────────────────────

class _SectionHeaderTablet extends StatelessWidget {
  final String title;
  const _SectionHeaderTablet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _TabletSizes.sectionHeaderPaddingLeft,
        _TabletSizes.sectionHeaderPaddingTop,
        _TabletSizes.sectionHeaderPaddingRight,
        _TabletSizes.sectionHeaderPaddingBottom,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _TabletSizes.sectionHeaderFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: _TabletSizes.sectionHeaderLetterSpacing,
        ),
      ),
    );
  }
}

// ─── Divider (Tablet) ──────────────────────────────────────────────────────────

class _DividerTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: _TabletSizes.dividerHeight,
      thickness: _TabletSizes.dividerThickness,
      color: AppTheme.surface(context),
    );
  }
}

// ─── Settings Tile (Tablet) ──────────────────────────────────────────────────

class _SettingsTileTablet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTileTablet({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: _TabletSizes.tileIconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.textPri(context),
          fontSize: _TabletSizes.tileTitleFontSize,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.tileSubtitleFontSize,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textSec(context),
        size: _TabletSizes.tileTrailingIconSize,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.tileContentPaddingHorizontal,
      ),
    );
  }
}

// ─── Switch List Tile (Tablet) ────────────────────────────────────────────────

class _SwitchListTileTablet extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final String title;
  final String subtitle;

  const _SwitchListTileTablet({
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: _TabletSizes.switchIconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: _TabletSizes.switchTitleFontSize,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _TabletSizes.switchSubtitleFontSize,
        ),
      ),
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.tileContentPaddingHorizontal,
      ),
    );
  }
}

// ─── Ceiling Note (Tablet) ────────────────────────────────────────────────────

class _CeilingNoteTablet extends StatelessWidget {
  final VisibilityOption profileVisibility;
  const _CeilingNoteTablet({required this.profileVisibility});

  @override
  Widget build(BuildContext context) {
    if (profileVisibility == VisibilityOption.public) return const SizedBox.shrink();

    final isPrivate = profileVisibility == VisibilityOption.private;
    final color = isPrivate ? Colors.orange : Colors.blue;
    final icon = isPrivate ? Icons.lock_outline : Icons.people_outlined;
    final msg = isPrivate
        ? 'Profil gizli — aktiviteler en fazla "Gizli" yapılabilir.'
        : 'Profil arkadaşlara açık — aktiviteler en fazla "Arkadaşlara açık" yapılabilir.';

    return Container(
      margin: EdgeInsets.fromLTRB(
        _TabletSizes.noteMarginLeft,
        _TabletSizes.noteMarginTop,
        _TabletSizes.noteMarginRight,
        _TabletSizes.noteMarginBottom,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.notePaddingHorizontal,
        vertical: _TabletSizes.notePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(_TabletSizes.noteBorderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
          width: _TabletSizes.noteBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: _TabletSizes.noteIconSize, color: color),
          SizedBox(width: _TabletSizes.noteIconSpacing),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: color,
                fontSize: _TabletSizes.noteFontSize,
                height: _TabletSizes.noteLineHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Visibility Tile (Tablet) ─────────────────────────────────────────────────

class _VisibilityTileTablet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VisibilityOption current;
  final VisibilityOption? ceiling;
  final Future<void> Function(VisibilityOption) onChanged;

  const _VisibilityTileTablet({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.ceiling,
    required this.onChanged,
  });

  bool _isAllowed(VisibilityOption option) {
    if (ceiling == null) return true;
    const order = [
      VisibilityOption.private,
      VisibilityOption.friends,
      VisibilityOption.public,
    ];
    return order.indexOf(option) <= order.indexOf(ceiling!);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: _TabletSizes.visIconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: _TabletSizes.visTitleFontSize,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _TabletSizes.visSubtitleFontSize,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VisibilityBadgeTablet(option: current),
          SizedBox(width: _TabletSizes.visTrailingSpacing),
          Icon(
            Icons.chevron_right,
            color: AppTheme.textSec(context),
            size: _TabletSizes.visTrailingChevronSize,
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.tileContentPaddingHorizontal,
      ),
      onTap: () => _showSheet(context),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_TabletSizes.sheetBorderRadius),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: _TabletSizes.sheetHandleSpacing),
            Container(
              width: _TabletSizes.sheetHandleWidth,
              height: _TabletSizes.sheetHandleHeight,
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(
                  _TabletSizes.sheetHandleBorderRadius,
                ),
              ),
            ),
            SizedBox(height: _TabletSizes.sheetHandleSpacing),
            Text(
              title,
              style: TextStyle(
                fontSize: _TabletSizes.sheetTitleFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPri(context),
              ),
            ),
            SizedBox(height: _TabletSizes.sheetHandleSpacing),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: _TabletSizes.sheetSubtitleFontSize,
                color: AppTheme.textSec(context),
              ),
            ),
            SizedBox(height: _TabletSizes.sheetOptionSpacing),
            for (final option in VisibilityOption.values)
              _VisibilityOptionRowTablet(
                option: option,
                isCurrent: option == current,
                isAllowed: _isAllowed(option),
                ceiling: ceiling,
                onTap: () {
                  if (!_isAllowed(option)) return;
                  Get.back();
                  onChanged(option);
                },
              ),
            SizedBox(height: _TabletSizes.sheetBottomPadding),
          ],
        ),
      ),
    );
  }
}

// ─── Visibility Badge (Tablet) ───────────────────────────────────────────────

class _VisibilityBadgeTablet extends StatelessWidget {
  final VisibilityOption option;
  const _VisibilityBadgeTablet({required this.option});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (option) {
      VisibilityOption.public => (
          Icons.public_outlined,
          Colors.green,
          'Herkese',
        ),
      VisibilityOption.friends => (
          Icons.people_outlined,
          Colors.blue,
          'Arkadaş',
        ),
      VisibilityOption.private => (Icons.lock_outline, Colors.orange, 'Gizli'),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.visBadgePaddingHorizontal,
        vertical: _TabletSizes.visBadgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_TabletSizes.visBadgeBorderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: _TabletSizes.visBadgeBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _TabletSizes.visBadgeIconSize, color: color),
          SizedBox(width: _TabletSizes.visTrailingSpacing),
          Text(
            label,
            style: TextStyle(
              fontSize: _TabletSizes.visBadgeFontSize,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Visibility Option Row (Tablet) ──────────────────────────────────────────

class _VisibilityOptionRowTablet extends StatelessWidget {
  final VisibilityOption option;
  final bool isCurrent;
  final bool isAllowed;
  final VisibilityOption? ceiling;
  final VoidCallback onTap;

  const _VisibilityOptionRowTablet({
    required this.option,
    required this.isCurrent,
    required this.isAllowed,
    required this.ceiling,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (iconData, color) = _iconAndColor(option);
    final dimmed = !isAllowed;

    return Opacity(
      opacity: dimmed ? _TabletSizes.disabledOpacity : 1.0,
      child: ListTile(
        enabled: isAllowed,
        onTap: isAllowed ? onTap : null,
        leading: Container(
          width: _TabletSizes.sheetOptionLeadingContainerSize,
          height: _TabletSizes.sheetOptionLeadingContainerSize,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              _TabletSizes.sheetOptionLeadingBorderRadius,
            ),
          ),
          child: Icon(
            iconData,
            color: color,
            size: _TabletSizes.sheetOptionLeadingIconSize,
          ),
        ),
        title: Text(
          option.label,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: _TabletSizes.sheetOptionTitleFontSize,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          dimmed
              ? 'Profil "${ceiling!.label}" olduğu için seçilemiyor'
              : option.sublabel,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _TabletSizes.sheetOptionSubtitleFontSize,
          ),
        ),
        trailing: isCurrent
            ? Icon(
                Icons.check_rounded,
                color: AppTheme.primaryColor,
                size: _TabletSizes.sheetOptionTrailingIconSize,
              )
            : dimmed
                ? Icon(
                    Icons.lock_outline,
                    color: AppTheme.textSec(context),
                    size: _TabletSizes.sheetOptionTrailingLockSize,
                  )
                : null,
      ),
    );
  }

  (IconData, Color) _iconAndColor(VisibilityOption o) {
    switch (o) {
      case VisibilityOption.public:
        return (Icons.public_outlined, Colors.green);
      case VisibilityOption.friends:
        return (Icons.people_outlined, Colors.blue);
      case VisibilityOption.private:
        return (Icons.lock_outline, Colors.orange);
    }
  }
}