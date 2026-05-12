import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (!controller.isLoggedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    color: AppTheme.textSecondary,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Giriş yapın',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Profilinizi görüntülemek ve favorilerinizi kaydetmek için giriş yapın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      child: const Text('Giriş Yap'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: const BorderSide(color: AppTheme.textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: const Text('Kayıt Ol'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = controller.profile.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  (profile?.username ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile?.username ?? 'Kullanıcı',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.fullName ?? '',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              const Divider(color: AppTheme.surfaceColor),
              const SizedBox(height: 16),
              _ProfileMenuItem(
                icon: Icons.edit_outlined,
                title: 'Profili Düzenle',
                onTap: () => _showEditProfileDialog(context, controller),
              ),
              _ProfileMenuItem(
                icon: Icons.favorite_outline_rounded,
                title: 'Favorilerim',
                onTap: () => controller.changeTab(1),
              ),
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Ayarlar',
                onTap: () => controller.changeTab(3),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, ProfileController controller) {
    final usernameController =
        TextEditingController(text: controller.profile.value?.username ?? '');
    final fullNameController =
        TextEditingController(text: controller.profile.value?.fullName ?? '');

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Kullanıcı Adı'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fullNameController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
            ),
          ],
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
            onPressed: () {
              controller.updateProfile(
                username: usernameController.text,
                fullName: fullNameController.text,
              );
              Get.back();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}