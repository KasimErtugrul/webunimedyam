// lib/core/utils/share_helper.dart
//
// Uygulama genelinde video paylaşımı için TEK, merkezi yardımcı sınıf.
// Home tab, Shorts Player ve Player ekranı artık aynı paylaşım metnini,
// aynı link mantığını kullanır.
//
// GEÇMİŞ SORUNLAR VE ÇÖZÜMLERİ:
//
// 1) ShortsPlayerScreen içinde `unitv://video/...` deep link'i yanlışlıkla
//    ShareParams.title alanına konuyordu. share_plus'ta `title`, paylaşılan
//    İÇERİK değil; sadece Android'in chooser dialog başlığı / EXTRA_TITLE
//    alanıdır. Sonuç: paylaşılan mesajda video linki HİÇ yer almıyordu.
//    → DÜZELTİLDİ: link artık her zaman `text` alanında.
//
// 2) `unitv://video/{videoId}` gibi özel (custom) URI şemaları WhatsApp,
//    Telegram, Instagram DM gibi üçüncü parti uygulamalar tarafından
//    OTOMATİK TIKLANABİLİR hale getirilmiyor — bu uygulamaların linkify
//    motorları sadece http:// ve https:// şemalarını tanıyor. Bu yüzden
//    mesajdaki "unitv://..." satırı hep düz, pasif metin olarak kalıyordu.
//    → DÜZELTİLDİ: artık `https://{VideoLinkConfig.webHost}/video/{videoId}`
//      formatında GERÇEK bir HTTPS linki paylaşılıyor. Bu link:
//        - Android App Links / iOS Universal Links doğrulaması
//          tamamlanmışsa VE uygulama yüklüyse → doğrudan UniTv'yi açar
//          (tarayıcıya hiç uğramadan).
//        - Uygulama yüklü değilse → hosting'deki (/hosting klasörü)
//          basit yönlendirme sayfası açılır, o da otomatik olarak
//          YouTube'a yönlendirir.
//      Kurulum adımları için bkz. /hosting/README.md ve
//      lib/core/constants/app_links.dart içindeki yorumlar.
//
// 3) Video kapak görseli (`bestThumbnail`) indirilip paylaşım sayfasına
//    dosya olarak eklenir (`ShareParams.files`), böylece WhatsApp/
//    Instagram gibi uygulamalarda mesajla birlikte görsel de gider.
//    Görsel indirilemezse (ağ hatası, zaman aşımı vb.) sessizce sadece
//    metinle paylaşıma devam edilir; kullanıcı hiçbir zaman paylaşımı
//    yapamama durumunda kalmaz.
//
// NOT (pubspec.yaml): `flutter_cache_manager` burada import ediliyor.
// `cached_network_image` paketi zaten bunu transitive bağımlılık
// olarak getiriyor, bu yüzden ek bir kurulum gerekmez; yine de analyzer
// "depend_on_referenced_packages" uyarısı verirse pubspec.yaml'a
// `flutter_cache_manager: ^3.4.1` satırını eklemeniz yeterli.

import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/app_links.dart';

class ShareHelper {
  ShareHelper._();

  /// Uygulama yüklü değilse veya paylaşım sırasında bir hata olursa
  /// (bkz. controller'lardaki clipboard fallback) kullanılacak, her
  /// zaman çalışan YouTube web linki.
  static const String _youtubeFallbackBase = 'https://www.youtube.com/watch?v=';

  /// Görsel indirme için üst sınır. Bu süre aşılırsa görsel olmadan,
  /// sadece metinle paylaşıma devam edilir — kullanıcı yavaş bir
  /// bağlantı yüzünden paylaşım ekranında beklemesin diye.
  static const Duration _thumbnailTimeout = Duration(seconds: 6);

  /// WhatsApp/Telegram/Instagram gibi uygulamalarda TIKLANABİLİR olan,
  /// paylaşımda kullanılacak asıl HTTPS linki. Uygulama yüklüyse
  /// doğrudan UniTv'yi, değilse hosting'deki yönlendirme sayfası
  /// üzerinden YouTube'u açar.
  static String buildDeepLink(String videoId) =>
      VideoLinkConfig.videoWebLink(videoId);

  /// Sadece clipboard fallback / hata durumları için: doğrudan YouTube
  /// linki (App Links doğrulamasına bağlı değil, her zaman çalışır).
  static String buildWebFallback(String videoId) =>
      '$_youtubeFallbackBase$videoId';

  /// Paylaşım mesajının gövdesini oluşturur. Tek, tıklanabilir HTTPS
  /// linki içerir — ayrı bir "uygulama yüklü değilse" satırına gerek
  /// yok, çünkü fallback zaten linkin kendisinde (hosting sayfası
  /// üzerinden) gerçekleşiyor.
  static String buildShareText({
    required String videoId,
    required String title,
    String? universityName,
  }) {
    final headline = (universityName != null && universityName.isNotEmpty)
        ? '$universityName - $title'
        : title;

    return '$headline\n\n${buildDeepLink(videoId)}';
  }

  /// Verilen thumbnail linkini indirip paylaşım ekranına eklenecek bir
  /// [XFile]'a çevirir. `cached_network_image` zaten aynı URL'i
  /// gösterirken bu görseli diske indirip önbelleğe aldığı için,
  /// burada da aynı `DefaultCacheManager`'ı kullanmak var olan
  /// önbellekten faydalanır ve ekstra network trafiğini önler.
  ///
  /// İndirme başarısız olursa veya zaman aşımına uğrarsa `null` döner;
  /// bu durumda paylaşım görsel olmadan, sadece metinle devam eder.
  static Future<XFile?> _resolveThumbnailFile(String? thumbnailUrl) async {
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) return null;
    try {
      final file = await DefaultCacheManager()
          .getSingleFile(thumbnailUrl)
          .timeout(_thumbnailTimeout);
      return XFile(file.path);
    } catch (e, stacktrace) {
      log(
        'Paylaşım için thumbnail indirilemedi, görsel olmadan devam ediliyor: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  /// Sistem paylaşım sayfasını (share sheet) açar ve sonucu döner.
  /// [thumbnailUrl] verilirse video kapak görseli, metinle birlikte
  /// paylaşım sayfasına eklenir (görsel indirilemezse sessizce
  /// metin-only paylaşıma düşer).
  static Future<ShareResult> shareVideo({
    required String videoId,
    required String title,
    String? universityName,
    String? thumbnailUrl,
  }) async {
    final text = buildShareText(
      videoId: videoId,
      title: title,
      universityName: universityName,
    );

    final thumbnailFile = await _resolveThumbnailFile(thumbnailUrl);

    return SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: title,
        files: thumbnailFile != null ? [thumbnailFile] : null,
      ),
    );
  }
}
