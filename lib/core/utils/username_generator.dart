// lib/core/utils/username_generator.dart
//
// Google gibi username bilgisi sağlamayan giriş yöntemleriyle kayıt olan
// kullanıcılar için, ad-soyaddan ("Zeynep Öztürk") + rastgele 6 haneli
// sayıdan ("zeynepozturk482913") oluşan aday kullanıcı adları üretir.
//
// NOT: Bu sınıf sadece ADAY üretir, benzersizliği GARANTİ ETMEZ.
// Gerçek benzersizlik garantisi veritabanındaki `profiles.username`
// UNIQUE kısıtından gelir. Çağıran taraf (bkz. AuthRepository)
// üretilen adayı Supabase'e yazmayı dener; çakışma olursa (Postgrest
// hata kodu 23505) yeni bir aday üretip tekrar dener.

import 'dart:math';

class UsernameGenerator {
  UsernameGenerator._();

  static const Map<String, String> _trMap = {
    'ç': 'c', 'Ç': 'c',
    'ğ': 'g', 'Ğ': 'g',
    'ı': 'i', 'İ': 'i',
    'ö': 'o', 'Ö': 'o',
    'ş': 's', 'Ş': 's',
    'ü': 'u', 'Ü': 'u',
  };

  /// "Zeynep Öztürk" -> "zeynepozturk"
  /// Boş/eksik isim durumunda güvenli bir varsayılana ("kullanici") düşer.
  static String slugifyBase(String? fullName) {
    final source = (fullName == null || fullName.trim().isEmpty)
        ? 'kullanici'
        : fullName;

    final buffer = StringBuffer();
    for (final rune in source.runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_trMap[ch] ?? ch);
    }

    var slug = buffer.toString().toLowerCase();
    // Sadece a-z ve 0-9 kalsın; boşluk, tire, apostrof vb. atılır.
    slug = slug.replaceAll(RegExp(r'[^a-z0-9]'), '');

    if (slug.isEmpty) slug = 'kullanici';

    // profiles.username sütununda sabit bir uzunluk sınırı yok, ama
    // makul bir üst sınır tutuyoruz (6 haneli sayı + biraz pay için).
    const maxBaseLength = 20;
    if (slug.length > maxBaseLength) {
      slug = slug.substring(0, maxBaseLength);
    }

    return slug;
  }

  /// "zeynepozturk" -> "zeynepozturk482913" (rastgele 6 haneli sayı ekler)
  static String nextCandidate(String base) {
    final rnd = Random.secure();
    // 100000-999999 arası: her zaman tam 6 haneli, baştan sıfır olmaz.
    final suffix = (100000 + rnd.nextInt(900000)).toString();
    return '$base$suffix';
  }
}