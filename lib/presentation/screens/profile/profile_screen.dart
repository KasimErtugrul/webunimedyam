import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../controllers/profile_controller.dart';
import 'widgets/profile_view_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      }

      if (!controller.isLoggedIn) {
        return _NotLoggedInView();
      }

      return ProfileViewWidget(controller: controller);
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Giriş yapılmamış ekranı
// ═══════════════════════════════════════════════════════════════════════════

class _NotLoggedInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Hesabına Giriş Yap',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Favorilerini, izleme geçmişini ve tüm aktivitelerini\ngörmek için giriş yap.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
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
                    foregroundColor: AppTheme.textPri(context),
                    side: BorderSide(color: AppTheme.surface(context)),
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
      ),
    );
  }
}
