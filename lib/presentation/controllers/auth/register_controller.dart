import 'dart:developer';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/errors/auth_exceptions.dart';
import '../../../core/errors/username_taken_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/session_service.dart';

class RegisterController extends GetxController {
  RegisterController({
    required AuthRepository authRepository,
    required SessionService sessionService,
  }) : _repo = authRepository,
       _session = sessionService;

  final AuthRepository _repo;
  final SessionService _session;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Kayıt formundaki canlı kullanıcı adı kontrolü için.
  Future<bool> isUsernameAvailable(String username, {String? email}) =>
      _repo.isUsernameAvailable(username, email: email);

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final needsVerification = await _repo.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (needsVerification) {
        Get.toNamed(AppRoutes.otpVerification, arguments: {'email': email});
        return;
      }

      await _session.onLogin();

      Get.offAllNamed(AppRoutes.home);
    } on UsernameTakenException {
      errorMessage.value =
          'Bu kullanıcı adı zaten alınmış. Lütfen başka bir tane deneyin.';
    } on AuthFailure catch (e) {
      // Ör. "Bu e-posta ile zaten hesap var"
      errorMessage.value = e.message;
    } on AuthRateLimitException catch (e) {
      errorMessage.value = e.toString();
    } on AuthNetworkException catch (e) {
      errorMessage.value = e.toString();
    } catch (e, st) {
      log('signUp failed: $e', error: e, stackTrace: st);
      errorMessage.value = 'Kayıt başarısız. Bilgilerinizi kontrol edin.';
    } finally {
      isLoading.value = false;
    }
  }
}
