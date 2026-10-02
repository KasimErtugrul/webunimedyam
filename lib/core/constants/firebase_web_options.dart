// lib/core/constants/firebase_web_options.dart
//
// Web (tarayıcı) platformu için Firebase yapılandırması.
//
// Android tarafında bu değerlere gerek yoktur: `google-services.json`
// derleme sırasında SDK tarafından otomatik okunur. Web'de ise Firebase
// options kod içinden ZORUNLU olarak verilmelidir; aksi halde
// `Firebase.initializeApp()` tarayıcıda patlar.
//
// Değerler `android/app/google-services.json` içinden alındı:
//   apiKey            → client[0].api_key[0].current_key
//   projectId         → project_info.project_id
//   messagingSenderId → project_info.project_number
//   appId             → client[0].mobilesdk_app_id
//   authDomain        → Firebase standardı: {projectId}.firebaseapp.com
//   storageBucket     → project_info.storage_bucket
//
// NOT: `appId` şu an Android uygulamasının id'si. Firebase Console →
// Proje ayarları → "Web uygulaması ekleyin" adımını gerçekleştirirseniz
// orada üretilen (1:67433845227:web:... formatındaki) appId ile
// değiştirmeniz önerilir; çekirdek servisler (Messaging/Analytics init)
// mevcut haliyle de çalışır.

import 'package:firebase_core/firebase_core.dart';

class FirebaseWebOptions {
  FirebaseWebOptions._();

  static const FirebaseOptions current = FirebaseOptions(
    apiKey: 'AIzaSyBOhOjoSpDeXDcu4DEYxNrU7qKJZ7hSCwk',
    authDomain: 'unitv-33f05.firebaseapp.com',
    projectId: 'unitv-33f05',
    storageBucket: 'unitv-33f05.firebasestorage.app',
    messagingSenderId: '67433845227',
    appId: '1:67433845227:android:11396a22a5093a5207c9ae',
  );
}
