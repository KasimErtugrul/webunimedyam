// lib/core/utils/debug_snack.dart
//
// GEÇİCİ DEBUG ARACI — Deep link akışını (WhatsApp linkinden player
// ekranına gidiş) adb/logcat'e bağımlı kalmadan, doğrudan cihaz
// ekranında görmek için eklendi.
//
// SORUN ÇÖZÜLDÜKTEN SONRA: bu dosyayı ve tüm debugSnack(...)
// çağrılarını (deep_link_service.dart ve player_controller.dart
// içinde) kaldır — production'da kalıcı olmaması gereken bir araç.
//
// Navigator/overlay henüz hazır değilse (ör. uygulama daha yeni
// açılıyorsa) kısa aralıklarla kendini tekrar dener, tıpkı
// DeepLinkService._navigateToPlayer içindeki retry mantığı gibi.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> debugSnack(String message, {int attempt = 0}) async {
  // Her zaman logcat'e de yaz — adb bağlıyken de görülebilsin diye.
  log('[DEEPLINK DEBUG] $message');

  if (Get.key.currentState == null) {
    if (attempt >= 30) return; // ~6 saniye sonra vazgeç, sonsuza kadar denemesin
    await Future.delayed(const Duration(milliseconds: 200));
    return debugSnack(message, attempt: attempt + 1);
  }

  Get.snackbar(
    'DEEP LINK DEBUG',
    message,
    duration: const Duration(seconds: 10),
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.black87,
    colorText: Colors.white,
    isDismissible: true,
    margin: const EdgeInsets.all(8),
  );
}