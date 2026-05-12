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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Obx(() {
        final settings = controller.settings.value;

        return ListView(
          children: [
            _SectionHeader(title: 'Uygulama'),
            SwitchListTile(
              value: settings?.notificationsEnabled ?? true,
              onChanged: (_) => controller.toggleNotifications(),
              title: const Text(
                'Bildirimler',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: const Text(
                'Yeni video bildirimlerini al',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              activeColor: AppTheme.primaryColor,
            ),
            SwitchListTile(
              value: settings?.autoplay ?? true,
              onChanged: (_) => controller.toggleAutoplay(),
              title: const Text(
                'Otomatik Oynat',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: const Text(
                'Videoları otomatik başlat',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              activeColor: AppTheme.primaryColor,
            ),
            const Divider(color: AppTheme.surfaceColor),
            _SectionHeader(title: 'Görünüm'),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined,
                  color: AppTheme.textSecondary),
              title: const Text(
                'Tema',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: Text(
                settings?.theme == 'dark' ? 'Koyu' : 'Açık',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
              onTap: () => _showThemeDialog(controller),
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined,
                  color: AppTheme.textSecondary),
              title: const Text(
                'Dil',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: Text(
                settings?.language == 'tr' ? 'Türkçe' : 'English',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
              onTap: () => _showLanguageDialog(controller),
            ),
            const Divider(color: AppTheme.surfaceColor),
            _SectionHeader(title: 'Hesap'),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _showSignOutDialog(controller),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'ÇOMÜ TV v1.0.0',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  void _showThemeDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Tema Seç',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Koyu',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              leading: const Icon(Icons.dark_mode_rounded,
                  color: AppTheme.textSecondary),
              onTap: () {
                controller.changeTheme('dark');
                Get.back();
              },
            ),
            ListTile(
              title: const Text(
                'Açık',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              leading: const Icon(Icons.light_mode_rounded,
                  color: AppTheme.textSecondary),
              onTap: () {
                controller.changeTheme('light');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Dil Seç',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Türkçe',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                controller.changeLanguage('tr');
                Get.back();
              },
            ),
            ListTile(
              title: const Text(
                'English',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                controller.changeLanguage('en');
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.signOut();
            },
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