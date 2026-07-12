// lib/services/connectivity_service.dart

import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'notification_service.dart';

/// Ağ bağlantısı durumunu tek noktadan takip eden servis.
///
/// Sorumlulukları:
///   1) `connectivity_plus` ile arayüz seviyesinde (wifi/mobil/yok)
///      bağlantı değişikliklerini dinlemek.
///   2) `isOnline` reaktif değerini (RxBool) tüm uygulamaya sunmak —
///      GetX ile Obx() kullanan her widget otomatik güncellenir.
///   3) İnternet OFF → ON geçişini yakalayıp, bağlantı yokken başarısız
///      olmuş olabilecek kritik senkronizasyonları (örn. FCM token)
///      otomatik olarak yeniden tetiklemek.
class ConnectivityService extends GetxService {
  ConnectivityService._();

  /// NOT: `init()` çağrılıp `Get.put` yapılmadan bu getter kullanılırsa
  /// "ConnectivityService not found" hatası fırlatır. main() içinde
  /// `await ConnectivityService.init();` satırının çalıştığından emin olun.
  static ConnectivityService get instance => Get.find<ConnectivityService>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// true: en az bir ağ arayüzü aktif. false: hiç bağlantı yok.
  final RxBool isOnline = true.obs;

  /// Son bilinen durumun offline olup olmadığını tutar; OFF → ON
  /// geçişini (yani "internet az önce geri geldi" anını) tespit
  /// etmek için kullanılır.
  bool _wasOffline = false;

  static Future<ConnectivityService> init() async {
    final service = ConnectivityService._();
    await service._initialize();
    return Get.put<ConnectivityService>(service, permanent: true);
  }

  Future<void> _initialize() async {
    try {
      final initial = await _connectivity.checkConnectivity();
      isOnline.value = _hasConnection(initial);
      _wasOffline = !isOnline.value;

      _subscription = _connectivity.onConnectivityChanged.listen((result) {
        final nowOnline = _hasConnection(result);
        isOnline.value = nowOnline;

        // İnternet OFF → ON geçişinde, bağlantı yokken başarısız
        // olabilecek kritik senkronizasyonları tetikle.
        if (nowOnline && _wasOffline) {
          _onReconnected();
        }
        _wasOffline = !nowOnline;
      });
    } catch (e, stacktrace) {
      log(
        'Connectivity servisi başlatılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  /// İnternet geri geldiğinde tetiklenecek işler burada toplanır.
  /// Yeni bir "bağlantı gelince şunu da yap" ihtiyacı çıkarsa,
  /// tek eklenmesi gereken yer burasıdır.
  void _onReconnected() {
    NotificationService.instance.retryTokenSyncIfNeeded();
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.contains(ConnectivityResult.none);

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}