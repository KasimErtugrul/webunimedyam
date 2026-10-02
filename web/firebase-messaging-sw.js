/* firebase-messaging-sw.js
 *
 * Firebase Cloud Messaging — web arka plan (background) bildirim service
 * worker'ı. Sayfa kapalıyken/arka plandayken gelen FCM mesajlarını tarayıcı
 * bu worker üzerinden sistem bildirimi olarak gösterir.
 *
 * Uygulama web'de push bildirimlerini ancak NotificationService içindeki
 * `_webVapidKey` tanımlıysa kullanır; bu worker'ın burada bulunması
 * zorunluluğu FCM web entegrasyonunun ön koşuludur (bkz. Flutter dokümanı:
 * "Add a web service worker" — firebase-messaging-sw.js web/ klasöründe
 * olmak zorundadır, flutter build web bu dosyayı build çıktısına kopyalar).
 */

importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBOhOjoSpDeXDcu4DEYxNrU7qKJZ7hSCwk',
  authDomain: 'unitv-33f05.firebaseapp.com',
  projectId: 'unitv-33f05',
  storageBucket: 'unitv-33f05.firebasestorage.app',
  messagingSenderId: '67433845227',
  appId: '1:67433845227:android:11396a22a5093a5207c9ae',
});

try {
  const messaging = firebase.messaging();

  // Arka planda gelen bildirimleri sistem bildirimi olarak göster.
  // (Bildirime tıklanınca açılacak URL, FCM payload'ındaki fcmOptions.link
  // veya data.link alanından gelir; tanımlıysa odaklı sekmeyi öne getirir.)
  messaging.onBackgroundMessage((payload) => {
    const title = (payload.notification && payload.notification.title) || 'ÇOMÜ TV';
    const body = (payload.notification && payload.notification.body) || '';
    const link = (payload.fcmOptions && payload.fcmOptions.link) ||
        (payload.data && payload.data.link) || '/';

    self.registration.showNotification(title, {
      body: body,
      data: { link: link },
    });
  });

  self.addEventListener('notificationclick', (event) => {
    event.notification.close();
    const target = (event.notification.data && event.notification.data.link) || '/';
    event.waitUntil(
      self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
        for (const client of clientList) {
          if ('focus' in client) {
            client.navigate(target);
            return client.focus();
          }
        }
        return self.clients.openWindow(target);
      })
    );
  });
} catch (e) {
  // SDK yüklenemezse worker sessizce no-op olur; site çalışmaya devam eder.
}
