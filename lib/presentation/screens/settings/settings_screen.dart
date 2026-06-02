// lib/presentation/screens/settings/settings_screen.dart
// MEVCUT DOSYANIN ÜSTÜNE YAZAR
// Değişiklik: Gizlilik bölümü tamamen yenilendi — VisibilityOption dropdown'ları eklendi

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/user_settings_model.dart';
import '../../controllers/settings_controller.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Obx(() {
        final s         = _controller.settings.value;
        final isLoading = _controller.isLoading.value;

        if (isLoading && s == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.only(bottom: 32.h),
          children: [
            // ═══ GÖRÜNÜM ═══════════════════════════════════════
            _SectionHeader(title: 'Görünüm'),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Tema',
              subtitle: _themeLabel(s?.theme),
              onTap: () => _showThemeDialog(context),
            ),

            // ═══ OYNATMA ═══════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Oynatma'),
            SwitchListTile(
              value: s?.autoplay ?? true,
              onChanged: (_) => _controller.toggleAutoplay(),
              secondary: Icon(Icons.play_circle_outline,
                  color: AppTheme.textSec(context), size: 24.sp),
              title: Text('Otomatik Oynat',
                  style: TextStyle(
                      color: AppTheme.textPri(context), fontSize: 16.sp)),
              subtitle: Text('Sıradaki videoyu otomatik başlat',
                  style: TextStyle(
                      color: AppTheme.textSec(context), fontSize: 13.sp)),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            SwitchListTile(
              value: s?.showSubtitles ?? false,
              onChanged: (_) => _controller.toggleSubtitles(),
              secondary: Icon(Icons.subtitles_outlined,
                  color: AppTheme.textSec(context), size: 24.sp),
              title: Text('Altyazı',
                  style: TextStyle(
                      color: AppTheme.textPri(context), fontSize: 16.sp)),
              subtitle: Text('Altyazıyı varsayılan açık göster',
                  style: TextStyle(
                      color: AppTheme.textSec(context), fontSize: 13.sp)),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),

            // ═══ BİLDİRİMLER ════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Bildirimler'),
            SwitchListTile(
              value: s?.notificationsEnabled ?? true,
              onChanged: (_) => _controller.toggleNotifications(),
              secondary: Icon(Icons.notifications_outlined,
                  color: AppTheme.textSec(context), size: 24.sp),
              title: Text('Bildirimler',
                  style: TextStyle(
                      color: AppTheme.textPri(context), fontSize: 16.sp)),
              subtitle: Text('Tüm bildirimleri aç/kapat',
                  style: TextStyle(
                      color: AppTheme.textSec(context), fontSize: 13.sp)),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            if (s?.notificationsEnabled ?? true) ...[
              SwitchListTile(
                value: s?.notifyNewVideos ?? true,
                onChanged: (_) => _controller.toggleNotifyNewVideos(),
                secondary: Icon(Icons.ondemand_video_outlined,
                    color: AppTheme.textSec(context), size: 24.sp),
                title: Text('Yeni Video',
                    style: TextStyle(
                        color: AppTheme.textPri(context), fontSize: 16.sp)),
                subtitle: Text('Takip ettiğin kanalların yeni videoları',
                    style: TextStyle(
                        color: AppTheme.textSec(context), fontSize: 13.sp)),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              SwitchListTile(
                value: s?.notifyCommentReplies ?? true,
                onChanged: (_) => _controller.toggleNotifyCommentReplies(),
                secondary: Icon(Icons.comment_outlined,
                    color: AppTheme.textSec(context), size: 24.sp),
                title: Text('Yorum Yanıtları',
                    style: TextStyle(
                        color: AppTheme.textPri(context), fontSize: 16.sp)),
                subtitle: Text('Yorumlarına gelen yanıtlar',
                    style: TextStyle(
                        color: AppTheme.textSec(context), fontSize: 13.sp)),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              SwitchListTile(
                value: s?.notifyFollowRequests ?? true,
                onChanged: (_) => _controller.toggleNotifyFollowRequests(),
                secondary: Icon(Icons.person_add_outlined,
                    color: AppTheme.textSec(context), size: 24.sp),
                title: Text('Takip İstekleri',
                    style: TextStyle(
                        color: AppTheme.textPri(context), fontSize: 16.sp)),
                subtitle: Text('Yeni takip isteği geldiğinde bildir',
                    style: TextStyle(
                        color: AppTheme.textSec(context), fontSize: 13.sp)),
                activeColor: AppTheme.primaryColor,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
            ],

            // ═══ GİZLİLİK ═══════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Gizlilik'),

            // Profil Görünürlüğü — en önemli alan
            _VisibilityTile(
              icon: Icons.account_circle_outlined,
              title: 'Profil Görünürlüğü',
              subtitle: 'Profilini kimler görebilir?',
              current: VisibilityOption.public, // Profil tablosundan gelir
              // ProfileController'dan okumak için: Get.find<ProfileController>().profile.value?.profileVisibility
              onChanged: _controller.changeProfileVisibility,
            ),

            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Text(
                'Aktivite Görünürlüğü',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            _VisibilityTile(
              icon: Icons.history_outlined,
              title: 'İzleme Geçmişi',
              subtitle: 'İzlediğin videolar',
              current: s?.watchHistoryVisibility ?? VisibilityOption.public,
              onChanged: _controller.changeWatchHistoryVisibility,
            ),
            _VisibilityTile(
              icon: Icons.thumb_up_outlined,
              title: 'Beğeniler',
              subtitle: 'Beğendiğin videolar',
              current: s?.likesVisibility ?? VisibilityOption.public,
              onChanged: _controller.changeLikesVisibility,
            ),
            _VisibilityTile(
              icon: Icons.bookmark_border_outlined,
              title: 'Favoriler',
              subtitle: 'Favori listelerin',
              current: s?.favoritesVisibility ?? VisibilityOption.public,
              onChanged: _controller.changeFavoritesVisibility,
            ),
            _VisibilityTile(
              icon: Icons.chat_bubble_outline,
              title: 'Yorumlar',
              subtitle: 'Yaptığın yorumlar',
              current: s?.commentsVisibility ?? VisibilityOption.public,
              onChanged: _controller.changeCommentsVisibility,
            ),

            // ═══ ERİŞİLEBİLİRLİK ════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Erişilebilirlik'),
            SwitchListTile(
              value: s?.reducedMotion ?? false,
              onChanged: (_) => _controller.toggleReducedMotion(),
              secondary: Icon(Icons.animation_outlined,
                  color: AppTheme.textSec(context), size: 24.sp),
              title: Text('Animasyonları Azalt',
                  style: TextStyle(
                      color: AppTheme.textPri(context), fontSize: 16.sp)),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),

            // ═══ HESAP ══════════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Hesap'),
            _SettingsTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Cache Temizle',
              subtitle: 'Yerel verileri temizle',
              onTap: _controller.clearCache,
            ),
            _SettingsTile(
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

  // ─── Theme Dialog ──────────────────────────────────────────────────────────
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tema'),
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
      case 'dark':   return 'Koyu';
      case 'light':  return 'Açık';
      default:       return 'Sistem';
    }
  }
}

// ─── Yardımcı Widget'lar ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 8.h,
      thickness: 0.5,
      color: AppTheme.surface(context),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSec(context), size: 24.sp),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.textPri(context),
          fontSize: 16.sp,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                  color: AppTheme.textSec(context), fontSize: 13.sp),
            )
          : null,
      trailing: Icon(Icons.chevron_right,
          color: AppTheme.textSec(context), size: 20.sp),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
    );
  }
}

/// Görünürlük seçici tile — 3 seçenekli bottom sheet açar
class _VisibilityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VisibilityOption current;
  final Future<void> Function(VisibilityOption) onChanged;

  const _VisibilityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSec(context), size: 24.sp),
      title: Text(
        title,
        style:
            TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
      ),
      subtitle: Text(
        subtitle,
        style:
            TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VisibilityBadge(option: current),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right,
              color: AppTheme.textSec(context), size: 20.sp),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      onTap: () => _showVisibilitySheet(context),
    );
  }

  void _showVisibilitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPri(context),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.textSec(context),
              ),
            ),
            SizedBox(height: 12.h),
            for (final option in VisibilityOption.values)
              ListTile(
                leading: _visibilityIcon(option, context),
                title: Text(
                  option.label,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 15.sp,
                    fontWeight: option == current
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  option.sublabel,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 12.sp,
                  ),
                ),
                trailing: option == current
                    ? Icon(Icons.check_rounded,
                        color: AppTheme.primaryColor, size: 20.sp)
                    : null,
                onTap: () {
                  Get.back();
                  onChanged(option);
                },
              ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _visibilityIcon(VisibilityOption option, BuildContext context) {
    IconData icon;
    Color color;
    switch (option) {
      case VisibilityOption.public:
        icon  = Icons.public_outlined;
        color = Colors.green;
        break;
      case VisibilityOption.friends:
        icon  = Icons.people_outlined;
        color = Colors.blue;
        break;
      case VisibilityOption.private:
        icon  = Icons.lock_outline;
        color = Colors.orange;
        break;
    }
    return Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }
}

/// Mini badge — "Herkese", "Arkadaş", "Gizli"
class _VisibilityBadge extends StatelessWidget {
  final VisibilityOption option;
  const _VisibilityBadge({required this.option});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    late final IconData icon;

    switch (option) {
      case VisibilityOption.public:
        color = Colors.green;
        label = 'Herkese';
        icon  = Icons.public_outlined;
        break;
      case VisibilityOption.friends:
        color = Colors.blue;
        label = 'Arkadaş';
        icon  = Icons.people_outlined;
        break;
      case VisibilityOption.private:
        color = Colors.orange;
        label = 'Gizli';
        icon  = Icons.lock_outline;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}