import 'package:get/get.dart';

import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/supabase_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../services/session_service.dart';
import '../../presentation/controllers/auth/login_controller.dart';
import '../../presentation/controllers/auth/register_controller.dart';
import '../../presentation/controllers/auth/otp_verification_controller.dart';
import '../../presentation/controllers/auth/forgot_password_controller.dart';
import '../../presentation/controllers/auth/reset_password_controller.dart';
import '../../presentation/controllers/auth/change_password_controller.dart';
import '../../presentation/controllers/auth/session_controller.dart';

class AuthBinding extends Bindings {
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
    if (!Get.isRegistered<SessionService>()) {
      Get.lazyPut(() => SessionService(), fenix: true);
    }

    Get.lazyPut(
      () => LoginController(
        authRepository: Get.find(),
        sessionService: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => RegisterController(
        authRepository: Get.find(),
        sessionService: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => OtpVerificationController(
        authRepository: Get.find(),
        sessionService: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut(
      () => ForgotPasswordController(authRepository: Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => ResetPasswordController(authRepository: Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => ChangePasswordController(authRepository: Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => SessionController(
        authRepository: Get.find(),
        sessionService: Get.find(),
      ),
      fenix: true,
    );
  }
}