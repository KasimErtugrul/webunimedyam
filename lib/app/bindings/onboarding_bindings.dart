// app/bindings/onboarding_binding.dart (YENİ DOSYA)
import 'package:get/get.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/controllers/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SupabaseDataSource>()) {
      Get.lazyPut(() => SupabaseDataSource(), fenix: true);
    }
    if (!Get.isRegistered<LocalDataSource>()) {
      Get.lazyPut(() => LocalDataSource(), fenix: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut(
        () => AuthRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }
    Get.lazyPut(() => OnboardingController(authRepository: Get.find()), fenix: true);

  }
  
}