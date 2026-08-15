// lib/services/deep_link_service.dart
//
// unitv://video/{videoId} şeklindeki derin bağlantıları (deep link) dinler
// ve uygulamayı doğrudan ilgili videonun player ekranına yönlendirir.
//
// Davranış: her zaman önce ANA SAYFA'ya, sonra üstüne PLAYER ekranına
// gidilir (Get.offAllNamed + Get.toNamed). Böylece player ekranındayken
// geri tuşuna basıldığında kullanıcı ana sayfaya döner.

import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    // Uygulama bir link ile SIFIRDAN açıldıysa (cold start).
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handle(initial);
    } catch (e, st) {
      log('Deep link (initial) okunurken hata: $e', error: e, stackTrace: st);
    }

    // Uygulama zaten açıkken bir link ile tetiklenirse (warm start).
    _sub = _appLinks.uriLinkStream.listen(
      _handle,
      onError: (e, st) => log('Deep link stream hatası: $e', error: e),
    );
  }

  void dispose() => _sub?.cancel();

  void _handle(Uri uri) {
    // Beklenen format: unitv://video/{videoId}
    if (uri.scheme != 'unitv' || uri.host != 'video') return;

    final videoId =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    if (videoId == null || videoId.isEmpty) return;

    _navigateToPlayer(videoId);
  }

  void _navigateToPlayer(String videoId, {int attempt = 0}) {
    // GetMaterialApp'in navigator'ı henüz hazır değilse (uygulama daha
    // yeni açılıyorsa) birkaç kez kısa aralıklarla tekrar dener.
    if (Get.key.currentState == null) {
      if (attempt >= 20) return; // ~4 saniye sonra vazgeç
      Future.delayed(
        const Duration(milliseconds: 200),
        () => _navigateToPlayer(videoId, attempt: attempt + 1),
      );
      return;
    }

    // Önce ana sayfa, üstüne player — geri tuşu ana sayfaya dönsün diye.
    Get.offAllNamed(AppRoutes.home);
    Get.toNamed(AppRoutes.player, parameters: {'videoId': videoId});
  }
}