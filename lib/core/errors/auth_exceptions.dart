// lib/core/errors/auth_exceptions.dart
//
// Auth akışında kullanıcıya FARKLI bir şey söylememiz / FARKLI bir yere
// yönlendirmemiz gereken durumlar için ayrı hata tipleri. Hepsini tek bir
// genel Exception'a çevirmek, "neden giremedim?" sorusunu cevapsız bırakıyordu.

/// E-posta OTP ile doğrulanmamış hesap giriş yapmaya çalıştı.
/// Çağıran taraf yeni kod gönderip OTP ekranına yönlendirmeli.
class EmailNotConfirmedException implements Exception {
  const EmailNotConfirmedException();
  @override
  String toString() => 'E-posta adresi henüz doğrulanmamış.';
}

/// Email/şifre yanlış.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
  @override
  String toString() => 'E-posta veya şifre hatalı.';
}

/// Çok fazla deneme / e-posta gönderimi (Supabase rate limit).
class AuthRateLimitException implements Exception {
  const AuthRateLimitException();
  @override
  String toString() =>
      'Çok fazla deneme yapıldı. Lütfen birkaç dakika sonra tekrar deneyin.';
}

/// İnternet / sunucuya ulaşılamadı.
class AuthNetworkException implements Exception {
  const AuthNetworkException();
  @override
  String toString() =>
      'Bağlantı kurulamadı. İnternetinizi kontrol edip tekrar deneyin.';
}

/// Kullanıcıya olduğu gibi gösterilebilecek mesajlı genel auth hatası.
class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);
  @override
  String toString() => message;
}

/// Şifre sıfırlamada kod doğru ama YENİ ŞİFRE reddedildi (zayıf / eskiyle aynı).
/// Kod artık tüketildi; kullanıcı sadece yeni şifreyi düzeltip tekrar denemeli.
class PasswordRejectedException extends AuthFailure {
  const PasswordRejectedException(super.message);
}
