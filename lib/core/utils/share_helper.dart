// lib/core/utils/share_helper.dart
//
// Uygulama genelinde video paylaşımı için TEK, merkezi yardımcı sınıf.
// Home tab, Shorts Player ve Player ekranı artık aynı paylaşım metnini,
// aynı deep link + web fallback mantığını kullanır.
//
// NEDEN GEREKLİYDİ?
// - ShortsPlayerScreen içinde `unitv://video/...` deep link'i yanlışlıkla
//   ShareParams.title alanına konuyordu. share_plus'ta `title`, paylaşılan
//   İÇERİK değil; sadece Android'in chooser dialog başlığı / EXTRA_TITLE
//   alanıdır (bkz. share_plus dokümantasyonu). Sonuç: paylaşılan mesajda
//   video linki HİÇ yer almıyordu, kullanıcı sadece boş bir başlık metni
//   paylaşıyordu.
// - Home ve Player ekranlarında ise deep link hiç kullanılmıyor, sadece
//   YouTube web linki paylaşılıyordu. Bu da uygulaması zaten yüklü olan
//   kullanıcıları YouTube'a yönlendirip UniTv içinde açılmasını engelliyordu.
//
// ÇÖZÜM:
// - Paylaşılan metin hem `unitv://video/{videoId}` uygulama içi derin
//   bağlantısını (uygulama yüklüyse doğrudan player'ı açar) HEM DE
//   YouTube web linkini (uygulama yüklü değilse / masaüstünde açan
//   kişi için) içerir.
// - `text` alanına yazılır (gerçekten paylaşılan içerik budur),
//   `subject` e-posta gibi kanallarda konu satırı olarak kullanılır.
// - Video kapak görseli (`bestThumbnail`) de indirilip paylaşım
//   sayfasına dosya olarak eklenir (`ShareParams.files`), böylece
//   WhatsApp/Instagram gibi uygulamalarda mesajla birlikte görsel de
//   gider. Görsel indirilemezse (ağ hatası, zaman aşımı vb.) sessizce
//   sadece metinle paylaşıma devam edilir; kullanıcı hiçbir zaman
//   paylaşımı yapamama durumunda kalmaz.
//
// NOT (pubspec.yaml): `flutter_cache_manager` burada import ediliyor.
// `cached_network_image` paketi zaten bunu transitive bağımlılık
// olarak getiriyor, bu yüzden ek bir kurulum gerekmez; yine de analyzer
// "depend_on_referenced_packages" uyarısı verirse pubspec.yaml'a
// `flutter_cache_manager: ^3.4.1` satırını eklemeniz yeterli.

import 'dart:developer';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  /// Uygulamanın AndroidManifest.xml / deep_link_service.dart içinde
  /// tanımlı özel şeması. Formatı: unitv://video/{videoId}
  static const String _appScheme = 'unitv://video/';

  /// Uygulama yüklü değilse veya masaüstünde açılırsa çalışacak web
  /// fallback linki.
  static const String _webFallbackBase = 'https://www.youtube.com/watch?v=';

  /// Görsel indirme için üst sınır. Bu süre aşılırsa görsel olmadan,
  /// sadece metinle paylaşıma devam edilir — kullanıcı yavaş bir
  /// bağlantı yüzünden paylaşım ekranında beklemesin diye.
  static const Duration _thumbnailTimeout = Duration(seconds: 6);

  /// unitv://video/{videoId} formatında uygulama içi derin bağlantı üretir.
  static String buildDeepLink(String videoId) => '$_appScheme$videoId';

  /// Uygulama yüklü değilse açılacak YouTube web linkini üretir.
  static String buildWebFallback(String videoId) =>
      '$_webFallbackBase$videoId';

  /// Paylaşım mesajının gövdesini oluşturur. Hem deep link hem de web
  /// fallback linkini içerir, böylece mesajı alan kişi UniTv'yi
  /// kullanıyorsa uygulama içinde, kullanmıyorsa tarayıcıda videoyu
  /// açabilir.
  static String buildShareText({
    required String videoId,
    required String title,
    String? universityName,
  }) {
    final headline = (universityName != null && universityName.isNotEmpty)
        ? '$universityName - $title'
        : title;

    return '$headline\n\n'
        'UniTv\'de izle:\n'
        '${buildDeepLink(videoId)}\n\n'
        'Uygulama yüklü değilse:\n'
        '${buildWebFallback(videoId)}';
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
  /// `sharePositionOrigin`, iPad'de popover'ın nereden açılacağını
  /// belirlemek için opsiyonel olarak verilebilir.
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

