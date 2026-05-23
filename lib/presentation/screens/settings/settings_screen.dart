import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(fontSize: 20.sp)),
      ),
      body: Obx(() {
        final settings = controller.settings.value;

        return ListView(
          children: [
            _SectionHeader(title: 'Uygulama'),
            SwitchListTile(
              value: settings?.notificationsEnabled ?? true,
              onChanged: (_) => controller.toggleNotifications(),
              title: Text(
                'Bildirimler',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                ),
              ),
              subtitle: Text(
                'Yeni video bildirimlerini al',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                ),
              ),
              activeThumbColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              dense: false,
            ),
            SwitchListTile(
              value: settings?.autoplay ?? true,
              onChanged: (_) => controller.toggleAutoplay(),
              title: Text(
                'Otomatik Oynat',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                ),
              ),
              subtitle: Text(
                'Videoları otomatik başlat',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                ),
              ),
              activeThumbColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              dense: false,
            ),
            Divider(
              color: AppTheme.surface(context),
              height: 1.h,
              thickness: 1.h,
            ),
            _SectionHeader(title: 'Görünüm'),
            ListTile(
              leading: Icon(
                Icons.dark_mode_outlined,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                'Tema',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                ),
              ),
              subtitle: Text(
                settings?.theme == 'dark' ? 'Koyu' : 'Açık',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: 20.sp,
              ),
              onTap: () => _showThemeDialog(context, controller),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              dense: false,
            ),
            ListTile(
              leading: Icon(
                Icons.language_outlined,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              title: Text(
                'Dil',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                ),
              ),
              subtitle: Text(
                settings?.language == 'tr' ? 'Türkçe' : 'English',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: 20.sp,
              ),
              onTap: () => _showLanguageDialog(context, controller),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              dense: false,
            ),
            Divider(
              color: AppTheme.surface(context),
              height: 1.h,
              thickness: 1.h,
            ),
            _SectionHeader(title: 'Hesap'),
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 24.sp,
              ),
              title: Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red, fontSize: 16.sp),
              ),
              onTap: () => _showSignOutDialog(context, controller),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              dense: false,
            ),
            SizedBox(height: 32.h),
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

  void _showThemeDialog(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'Tema Seç',
          style: TextStyle(color: AppTheme.textPri(context), fontSize: 20.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Koyu',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                ),
              ),
              leading: Icon(
                Icons.dark_mode_rounded,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              onTap: () {
                controller.changeTheme('dark');
                Get.changeThemeMode(ThemeMode.dark); // UI katmanına taşındı ✅
                Get.back();
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              dense: true,
            ),
            ListTile(
              title: Text(
                'Açık',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                ),
              ),
              leading: Icon(
                Icons.light_mode_rounded,
                color: AppTheme.textSec(context),
                size: 24.sp,
              ),
              onTap: () {
                controller.changeTheme('light');
                Get.back();
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              dense: true,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'Dil Seç',
          style: TextStyle(color: AppTheme.textPri(context), fontSize: 20.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Türkçe',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                ),
              ),
              onTap: () {
                controller.changeLanguage('tr');
                Get.back();
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              dense: true,
            ),
            ListTile(
              title: Text(
                'English',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                ),
              ),
              onTap: () {
                controller.changeLanguage('en');
                Get.back();
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              dense: true,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, SettingsController controller) {
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
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: Size(80.w, 36.h),
            ),
            onPressed: () {
              Get.back();
              controller.signOut();
            },
            child: Text('Çıkış Yap', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.w,
        ),
      ),
    );
  }
}
