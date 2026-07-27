// lib/core/errors/username_taken_exception.dart
//
// `profiles.username` UNIQUE kısıtı ihlal edildiğinde (Postgrest hata kodu
// '23505') fırlatılır. Genel "bir şeyler ters gitti" mesajından ayrı
// tutulmasının sebebi: bu hatayı yakalayan tarafın (örn. otomatik
// kullanıcı adı üretimi, ya da manuel kullanıcı adı değiştirme ekranı)
// farklı davranması gerekir — biri sessizce yeni bir aday deneyip tekrar
// dener, diğeri kullanıcıya "bu isim alınmış" diye net bir mesaj gösterir.

class UsernameTakenException implements Exception {
  final String message;
  const UsernameTakenException([
    this.message = 'Bu kullanıcı adı zaten alınmış.',
  ]);

  @override
  String toString() => message;
}