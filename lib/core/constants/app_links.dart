// lib/core/constants/app_links.dart
//
// Uygulamanın derin bağlantı (deep link) ayarları TEK bir yerde toplanır.
// share_helper.dart (paylaşım linki üretir) ve deep_link_service.dart
// (gelen linki karşılar) aynı sabitleri kullanır — domain'i değiştirmen
// gerektiğinde tek dosya yeterli olsun diye.
//
// KURULUM NOTU:
// _webHost değerini kendi Firebase Hosting adresinle değiştir, örn.
// `firebase init hosting` sonrası sana verilen `unitv-xxxx.web.app`
// veya seçtiğin site adına göre `unitv.web.app`.
//
// Bu domain'de şunlar barındırılmalı (bkz. /hosting klasörü):
//   /.well-known/assetlinks.json            (Android App Links doğrulaması)
//   /.well-known/apple-app-site-association (iOS Universal Links doğrulaması)
//   /video/index.html                       (uygulama yoksa YouTube'a yönlendirir)
//
// Android tarafında AndroidManifest.xml'e bu domain için
// android:autoVerify="true" olan bir https intent-filter eklenmeli
// (bkz. android/app/src/main/AndroidManifest.xml güncellemesi).
// iOS tarafında Xcode'da "Associated Domains" capability'sine
// `applinks:SENIN-DOMAIN` eklenmeli.

class VideoLinkConfig {
  VideoLinkConfig._();

  /// Firebase Hosting (veya kullandığın başka bir statik hosting) domain'i.
  /// ÖRNEK: 'unitv.web.app' — www YOK, şema YOK, sondaki / YOK.
  static const String webHost = 'unitv.web.app'; // ← KENDİ DOMAIN'İNLE DEĞİŞTİR

  /// Eski / uygulama-içi kullanım için hâlâ desteklenen özel şema.
  /// WhatsApp gibi üçüncü parti uygulamalarda TIKLANABİLİR OLMADIĞI için
  /// artık paylaşım linki olarak KULLANILMIYOR, sadece geriye dönük
  /// uyumluluk ve uygulama-içi yönlendirmeler için deep_link_service.dart
  /// içinde dinlenmeye devam ediyor.
  static const String customScheme = 'unitv';

  /// Video linklerinin path prefix'i: /video/{videoId}
  static const String videoPathSegment = 'video';

  /// Paylaşımda kullanılacak, WhatsApp/Telegram/Instagram vb. tarafından
  /// otomatik tıklanabilir hale getirilen tam HTTPS video linki.
  /// Uygulama yüklüyse ve App/Universal Links doğrulanmışsa doğrudan
  /// UniTv'yi açar; değilse hosting'deki sayfa üzerinden YouTube'a düşer.
  static String videoWebLink(String videoId) =>
      'https://$webHost/$videoPathSegment/$videoId';

  /// Sadece uygulama-içi / test amaçlı: eski özel şema linki.
  static String videoCustomSchemeLink(String videoId) =>
      '$customScheme://$videoPathSegment/$videoId';
}
