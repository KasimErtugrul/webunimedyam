// lib/data/utils/turkish_alphabet_sort_util.dart
// (Mevcut UniversityAzItem dosyanızın mantığını bu dosyaya taşıyabilirsiniz)

/// Türk alfabesi sıralaması (Q, W, X yok; Ç, Ğ, İ, Ö, Ş, Ü dahil).
const String kTurkishAlphabet = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';

/// İsmin ilk harfinden A-Z (Türkçe karakterler dahil) etiket üretir.
/// Harf değilse (rakam, boşluk vb.) "#" döner.
String getTurkishInitialTag(String? name) {
  if (name == null || name.trim().isEmpty) return '#';
  final first = name.trim()[0].toUpperCase();
  return kTurkishAlphabet.contains(first) ? first : '#';
}

/// İki ismi Türkçe alfabe sırasına göre karşılaştırır.
int turkishAlphabetCompare(String a, String b) {
  final upperA = a.toUpperCase();
  final upperB = b.toUpperCase();
  final len = upperA.length < upperB.length ? upperA.length : upperB.length;
  for (var i = 0; i < len; i++) {
    final ca = upperA[i];
    final cb = upperB[i];
    if (ca == cb) continue;
    final ia = kTurkishAlphabet.indexOf(ca);
    final ib = kTurkishAlphabet.indexOf(cb);
    if (ia != -1 && ib != -1) return ia.compareTo(ib);
    return ca.compareTo(cb);
  }
  return upperA.length.compareTo(upperB.length);
}