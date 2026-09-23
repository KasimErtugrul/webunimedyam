// lib/presentation/screens/signup_preferences/utils/signup_universities.dart

/// Üniversite seçim adımının görüntüleme modeli.
/// Gerçek veri kaynağınız (repository/API) bu sınıfa eşlenir;
/// widget'lar yalnızca bu sınıfa bağımlıdır.
class SignupUniversity {
  final String id;
  final String shortName;   // "İTÜ", "ODTÜ", "Boğaziçi"...
  final String fullName;    // "İstanbul Teknik Üniversitesi"
  final String city;        // "İstanbul"
  final bool isPrivate;     // Vakıf müessesesi mi?
  final String? emblemUrl;  // Varsa amblem görseli (network); yoksa baş harf avatarı

  const SignupUniversity({
    required this.id,
    required this.shortName,
    required this.fullName,
    required this.city,
    required this.isPrivate,
    this.emblemUrl,
  });

  /// Avatar için baş harfler: "Boğaziçi Üniversitesi" → "BÜ",
  /// tek kelimelik kısa ad ≤3 karakterse aynen ("İTÜ").
  String get avatarLabel {
    final sn = shortName.trim();
    if (sn.length <= 3) return sn.toUpperCase();
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return sn.substring(0, 2).toUpperCase();
  }
}

// ─── Türkçe duyarlı yardımcılar ─────────────────────────────
// Arama ve sıralamada 'Çanakkale' == 'canakkale' eşleşsin.

String normalizeTr(String input) {
  var s = input.toLowerCase();
  const from = ['ç', 'ğ', 'ı', 'ö', 'ş', 'ü', 'â', 'î', 'û'];
  const to = ['c', 'g', 'i', 'o', 's', 'u', 'a', 'i', 'u'];
  for (var i = 0; i < from.length; i++) {
    s = s.replaceAll(from[i], to[i]);
  }
  return s;
}

int compareTr(String a, String b) =>
    normalizeTr(a).compareTo(normalizeTr(b));

// ─── Demo/fallback liste (yalnızca veri kaynağı bağlanmadan önce) ──
const List<SignupUniversity> kSignupUniversities = [
  SignupUniversity(
      id: 'itu',
      shortName: 'İTÜ',
      fullName: 'İstanbul Teknik Üniversitesi',
      city: 'İstanbul',
      isPrivate: false),
  SignupUniversity(
      id: 'odtu',
      shortName: 'ODTÜ',
      fullName: 'Orta Doğu Teknik Üniversitesi',
      city: 'Ankara',
      isPrivate: false),
  SignupUniversity(
      id: 'bogazici',
      shortName: 'Boğaziçi',
      fullName: 'Boğaziçi Üniversitesi',
      city: 'İstanbul',
      isPrivate: false),
  SignupUniversity(
      id: 'koc',
      shortName: 'Koç Üni',
      fullName: 'Koç Üniversitesi',
      city: 'İstanbul',
      isPrivate: true),
  SignupUniversity(
      id: 'bilkent',
      shortName: 'Bilkent',
      fullName: 'Bilkent Üniversitesi',
      city: 'Ankara',
      isPrivate: true),
  SignupUniversity(
      id: 'ytu',
      shortName: 'YTÜ',
      fullName: 'Yıldız Teknik Üniversitesi',
      city: 'İstanbul',
      isPrivate: false),
  SignupUniversity(
      id: 'comu',
      shortName: 'ÇOMÜ',
      fullName: 'Çanakkale 18 Mart Üniversitesi',
      city: 'Çanakkale',
      isPrivate: false),
  SignupUniversity(
      id: 'hacettepe',
      shortName: 'Hacettepe',
      fullName: 'Hacettepe Üniversitesi',
      city: 'Ankara',
      isPrivate: false),
];