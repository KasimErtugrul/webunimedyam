import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/user_settings_model.dart';
import 'home_controller.dart';

class ProfileController extends GetxController {
  final AuthRepository authRepository;

  ProfileController({required this.authRepository});

  final profile = Rxn<ProfileModel>();
  final settings = Rxn<UserSettingsModel>();
  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      profile.value = await authRepository.getProfile();
      settings.value = await authRepository.getUserSettings();
    } catch (_) {} finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    final current = profile.value;
    if (current == null) return;

    try {
      final updated = ProfileModel(
        id: current.id,
        username: username ?? current.username,
        fullName: fullName ?? current.fullName,
        avatarUrl: avatarUrl ?? current.avatarUrl,
        createdAt: current.createdAt,
      );
      await authRepository.updateProfile(updated);
      profile.value = updated;
      Get.snackbar('Başarılı', 'Profil güncellendi.');
    } catch (_) {
      Get.snackbar('Hata', 'Profil güncellenemedi.');
    }
  }

  void changeTab(int index) {
  // HomeController üzerinden tab değiştir
  Get.find<HomeController>().changeTab(index);
}

  bool get isLoggedIn => authRepository.isLoggedIn;
}