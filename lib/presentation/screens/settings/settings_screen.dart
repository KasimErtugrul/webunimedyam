import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
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
        final s = _controller.settings.value;
        final isLoading = _controller.isLoading.value;

        if (isLoading && s == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.only(bottom: 32.h),
          children: [
            // ═══════════════════════════════════════════════════════
            // GÖRÜNÜM
            // ═══════════════════════════════════════════════════════
            _SectionHeader(title: 'Görünüm'),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Tema',
              subtitle: _themeLabel(s?.theme),
              onTap: () => _showThemeDialog(context),
            ),

            // ═══════════════════════════════════════════════════════
            // OYNATMA
            // ═══════════════════════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Oynatma'),
            SwitchListTile(
              value: s?.autoplay ?? true,
              onChanged: (_) => _controller.toggleAutoplay(),
              secondary: Icon(
                Icons.play_circle_outline,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                'Otomatik Oynat',
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
              ),
              subtitle: Text(
                'Sıradaki videoyu otomatik başlat',
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
              ),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            SwitchListTile(
              value: s?.showSubtitles ?? false,
              onChanged: (_) => _controller.toggleSubtitles(),
              secondary: Icon(
                Icons.subtitles_outlined,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                'Altyazı',
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
              ),
              subtitle: Text(
                'Varsayılan olarak altyazıyı aç',
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
              ),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            _SettingsTile(
              icon: Icons.hd_outlined,
              title: 'Video Kalitesi',
              subtitle: _qualityLabel(s?.videoQuality),
              onTap: () => _showQualityDialog(context),
            ),

            // ═══════════════════════════════════════════════════════
            // BİLDİRİMLER
            // ═══════════════════════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Bildirimler'),
            SwitchListTile(
              value: s?.notificationsEnabled ?? true,
              onChanged: (_) => _controller.toggleNotifications(),
              secondary: Icon(
                Icons.notifications_outlined,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                'Bildirimler',
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
              ),
              subtitle: Text(
                'Tüm bildirimleri aç / kapat',
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
              ),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            // Alt bildirimler sadece ana bildirim açıksa etkin
            AnimatedOpacity(
              opacity: (s?.notificationsEnabled ?? true) ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  SwitchListTile(
                    value: (s?.notificationsEnabled ?? true) && (s?.notifyNewVideos ?? true),
                    onChanged: (s?.notificationsEnabled ?? true)
                        ? (_) => _controller.toggleNotifyNewVideos()
                        : null,
                    secondary: Icon(
                      Icons.video_library_outlined,
                      color: AppTheme.textSec(context),
                      size: 24.sp,
                    ),
                    title: Text(
                      'Yeni Videolar',
                      style: TextStyle(color: AppTheme.textPri(context), fontSize: 15.sp),
                    ),
                    subtitle: Text(
                      'Üniversiteler yeni video yüklediğinde bildir',
                      style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
                    ),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.only(left: 32.w, right: 16.w),
                  ),
                  SwitchListTile(
                    value: (s?.notificationsEnabled ?? true) && (s?.notifyCommentReplies ?? true),
                    onChanged: (s?.notificationsEnabled ?? true)
                        ? (_) => _controller.toggleNotifyCommentReplies()
                        : null,
                    secondary: Icon(
                      Icons.comment_outlined,
                      color: AppTheme.textSec(context),
                      size: 24.sp,
                    ),
                    title: Text(
                      'Yorum Cevapları',
                      style: TextStyle(color: AppTheme.textPri(context), fontSize: 15.sp),
                    ),
                    subtitle: Text(
                      'Yorumuna cevap geldiğinde bildir',
                      style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
                    ),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.only(left: 32.w, right: 16.w),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════
            // GİZLİLİK
            // ═══════════════════════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Gizlilik'),
            SwitchListTile(
              value: s?.showWatchHistory ?? true,
              onChanged: (_) => _controller.toggleWatchHistory(),
              secondary: Icon(
                Icons.history,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                'İzleme Geçmişi',
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
              ),
              subtitle: Text(
                'İzlediğin videoları geçmişe kaydet',
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
              ),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            SwitchListTile(
              value: s?.showFavoritesPublic ?? false,
              onChanged: (_) => _controller.toggleFavoritesPublic(),
              secondary: Icon(
                Icons.favorite_border,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                'Herkese Açık Favoriler',
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
              ),
              subtitle: Text(
                'Favori videolarını profilinde göster',
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
              ),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),

            // ═══════════════════════════════════════════════════════
            // ERİŞİLEBİLİRLİK
            // ═══════════════════════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Erişilebilirlik'),
            SwitchListTile(
              value: s?.reducedMotion ?? false,
              onChanged: (_) => _controller.toggleReducedMotion(),
              secondary: Icon(
                Icons.animation,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                'Azaltılmış Hareket',
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
              ),
              subtitle: Text(
                'Geçiş animasyonlarını azalt',
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
              ),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            _SettingsTile(
              icon: Icons.text_fields,
              title: 'Yazı Boyutu',
              subtitle: _textScaleLabel(s?.textScaleFactor),
              onTap: () => _showTextScaleDialog(context),
            ),

            // ═══════════════════════════════════════════════════════
            // VERİ & DEPOLAMA
            // ═══════════════════════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Veri & Depolama'),
            _SettingsTile(
              icon: Icons.cleaning_services_outlined,
              title: 'Cache Temizle',
              subtitle: 'Geçici verileri ve video önbelleğini sil',
              onTap: () => _showClearCacheDialog(context),
            ),

            // ═══════════════════════════════════════════════════════
            // HESAP
            // ═══════════════════════════════════════════════════════
            _Divider(),
            _SectionHeader(title: 'Hesap'),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Çıkış Yap',
              subtitle: 'Hesabından güvenli çıkış yap',
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _showSignOutDialog(context),
            ),

            // ─── Versiyon ─────────────────────────────────────────
            SizedBox(height: 24.h),
            Center(
              child: Text(
                'ÇOMÜ TV v1.0.0',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 12.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        );
      }),
    );
  }

  // ─── Diyaloglar ─────────────────────────────────────────────────────────────

  void _showThemeDialog(BuildContext context) {
    final options = [
      (value: 'system', label: 'Sistem', icon: Icons.brightness_auto_rounded),
      (value: 'dark',   label: 'Koyu',   icon: Icons.dark_mode_rounded),
      (value: 'light',  label: 'Açık',   icon: Icons.light_mode_rounded),
    ];

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'Tema Seç',
          style: TextStyle(color: AppTheme.textPri(context), fontSize: 20.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final isSelected = (_controller.settings.value?.theme ?? 'system') == opt.value;
            return ListTile(
              leading: Icon(
                opt.icon,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                opt.label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPri(context),
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppTheme.primaryColor, size: 20.sp)
                  : null,
              onTap: () {
                _controller.changeTheme(opt.value);
                Get.back();
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              dense: true,
            );
          }).toList(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _showQualityDialog(BuildContext context) {
    final options = [
      (value: 'auto',  label: 'Otomatik',  sub: 'Bağlantı hızına göre'),
      (value: '1080p', label: '1080p HD',  sub: 'En yüksek kalite'),
      (value: '720p',  label: '720p HD',   sub: 'Yüksek kalite'),
      (value: '480p',  label: '480p',      sub: 'Orta kalite'),
      (value: '360p',  label: '360p',      sub: 'Düşük veri kullanımı'),
    ];

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'Video Kalitesi',
          style: TextStyle(color: AppTheme.textPri(context), fontSize: 20.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final isSelected =
                (_controller.settings.value?.videoQuality ?? 'auto') == opt.value;
            return ListTile(
              title: Text(
                opt.label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPri(context),
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                opt.sub,
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 12.sp),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppTheme.primaryColor, size: 20.sp)
                  : null,
              onTap: () {
                _controller.changeVideoQuality(opt.value);
                Get.back();
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              dense: true,
            );
          }).toList(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _showTextScaleDialog(BuildContext context) {
    final options = [
      (value: 0.8,  label: 'Küçük'),
      (value: 1.0,  label: 'Normal'),
      (value: 1.2,  label: 'Büyük'),
      (value: 1.4,  label: 'Çok Büyük'),
    ];

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'Yazı Boyutu',
          style: TextStyle(color: AppTheme.textPri(context), fontSize: 20.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final current = _controller.settings.value?.textScaleFactor ?? 1.0;
            final isSelected = (current - opt.value).abs() < 0.05;
            return ListTile(
              title: Text(
                opt.label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPri(context),
                  fontSize: 16.sp * opt.value,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppTheme.primaryColor, size: 20.sp)
                  : null,
              onTap: () {
                _controller.changeTextScale(opt.value);
                Get.back();
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              dense: true,
            );
          }).toList(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'Cache Temizle',
          style: TextStyle(color: AppTheme.textPri(context), fontSize: 20.sp),
        ),
        content: Text(
          'Video önbelleği ve geçici veriler silinecek. Kullanıcı bilgilerin ve favorilerin korunur.',
          style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: Size(80.w, 36.h),
            ),
            onPressed: () {
              Get.back();
              _controller.clearCache();
            },
            child: Text('Temizle', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'Çıkış Yap',
          style: TextStyle(color: AppTheme.textPri(context), fontSize: 20.sp),
        ),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(80.w, 36.h),
            ),
            onPressed: () {
              Get.back();
              _controller.signOut();
            },
            child: Text('Çıkış Yap', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  // ─── Label Yardımcıları ───────────────────────────────────────────────────

  String _themeLabel(String? theme) {
    switch (theme) {
      case 'dark':   return 'Koyu';
      case 'light':  return 'Açık';
      default:       return 'Sistem';
    }
  }

  String _qualityLabel(String? quality) {
    switch (quality) {
      case '1080p': return '1080p HD';
      case '720p':  return '720p HD';
      case '480p':  return '480p';
      case '360p':  return '360p';
      default:      return 'Otomatik';
    }
  }

  String _textScaleLabel(double? scale) {
    if (scale == null || (scale - 1.0).abs() < 0.05) return 'Normal';
    if (scale < 0.9) return 'Küçük';
    if (scale < 1.15) return 'Büyük';
    return 'Çok Büyük';
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
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
      color: AppTheme.surface(context),
      height: 1.h,
      thickness: 1.h,
      indent: 16.w,
      endIndent: 16.w,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppTheme.textSec(context),
        size: 24.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.textPri(context),
          fontSize: 16.sp,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textSec(context),
        size: 20.sp,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      dense: false,
    );
  }
}