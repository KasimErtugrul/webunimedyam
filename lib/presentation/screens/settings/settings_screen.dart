import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Obx(() {
        final settings = controller.settings.value;

        return ListView(
          children: [
            _SectionHeader(title: 'Uygulama'),
            SwitchListTile(
              value: settings?.notificationsEnabled ?? true,
              onChanged: (_) => controller.toggleNotifications(),
              title: Text('Bildirimler', style: TextStyle(color: AppTheme.textPri(context))),
              subtitle: Text('Yeni video bildirimlerini al', style: TextStyle(color: AppTheme.textSec(context))),
              activeColor: AppTheme.primaryColor,
            ),
            SwitchListTile(
              value: settings?.autoplay ?? true,
              onChanged: (_) => controller.toggleAutoplay(),
              title: Text('Otomatik Oynat', style: TextStyle(color: AppTheme.textPri(context))),
              subtitle: Text('Videoları otomatik başlat', style: TextStyle(color: AppTheme.textSec(context))),
              activeColor: AppTheme.primaryColor,
            ),
            Divider(color: AppTheme.surface(context)),
            _SectionHeader(title: 'Görünüm'),
            ListTile(
              leading: Icon(Icons.dark_mode_outlined, color: AppTheme.textSec(context)),
              title: Text('Tema', style: TextStyle(color: AppTheme.textPri(context))),
              subtitle: Text(
                settings?.theme == 'dark' ? 'Koyu' : 'Açık',
                style: TextStyle(color: AppTheme.textSec(context)),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSec(context)),
              onTap: () => _showThemeDialog(context, controller),
            ),
            ListTile(
              leading: Icon(Icons.language_outlined, color: AppTheme.textSec(context)),
              title: Text('Dil', style: TextStyle(color: AppTheme.textPri(context))),
              subtitle: Text(
                settings?.language == 'tr' ? 'Türkçe' : 'English',
                style: TextStyle(color: AppTheme.textSec(context)),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSec(context)),
              onTap: () => _showLanguageDialog(context, controller),
            ),
            Divider(color: AppTheme.surface(context)),
            _SectionHeader(title: 'Hesap'),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
              onTap: () => _showSignOutDialog(context, controller),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'ÇOMÜ TV v1.0.0',
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text('Tema Seç', style: TextStyle(color: AppTheme.textPri(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Koyu', style: TextStyle(color: AppTheme.textPri(context))),
              leading: Icon(Icons.dark_mode_rounded, color: AppTheme.textSec(context)),
              onTap: () { controller.changeTheme('dark'); Get.back(); },
            ),
            ListTile(
              title: Text('Açık', style: TextStyle(color: AppTheme.textPri(context))),
              leading: Icon(Icons.light_mode_rounded, color: AppTheme.textSec(context)),
              onTap: () { controller.changeTheme('light'); Get.back(); },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text('Dil Seç', style: TextStyle(color: AppTheme.textPri(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Türkçe', style: TextStyle(color: AppTheme.textPri(context))),
              onTap: () { controller.changeLanguage('tr'); Get.back(); },
            ),
            ListTile(
              title: Text('English', style: TextStyle(color: AppTheme.textPri(context))),
              onTap: () { controller.changeLanguage('en'); Get.back(); },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, SettingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text('Çıkış Yap', style: TextStyle(color: AppTheme.textPri(context))),
        content: Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: AppTheme.textSec(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal', style: TextStyle(color: AppTheme.textSec(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { Get.back(); controller.signOut(); },
            child: const Text('Çıkış Yap'),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
