package com.developfly.unitv

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // BUG FIX: Uygulama bir deep link (https://unitv-33f05.web.app/video/{id}
    // veya unitv://video/{id}) ile SIFIRDAN (cold start) açıldığında, Android'in
    // FlutterActivity'si intent'in data URI'sinin path kısmını ("/video/{id}")
    // OTOMATİK OLARAK Flutter'ın "initial route"u olarak engine'e iletiyordu.
    //
    // GetMaterialApp (GetX), bu route'u kendi getPages listesindeki tanımlı
    // route'larla eşleştirmeye çalışırken (PageRedirect.page,
    // route_middleware.dart:200) eşleşme bulamıyor ve içeride bir null-check
    // operatörü ("!") null bir değer üzerinde patlıyordu:
    //
    //   "Null check operator used on a null value"
    //   #0 PageRedirect.page (route_middleware.dart:200)
    //   #1 GetMaterialApp.initialRoutesGenerate (...)
    //
    // Bu exception ilk frame çizilmeden önce oluştuğundan, kullanıcı native
    // splash kaybolduktan sonra KAPKARA bir ekranla karşılaşıyordu —
    // DeepLinkService (app_links) hiç devreye girmeden.
    //
    // Warm start'ta (uygulama zaten açıkken linke tıklanınca) bu sorun hiç
    // yaşanmıyordu çünkü o durumda initialRoute zaten normal (home/onboarding)
    // olarak ayarlanmış oluyor ve deep link ayrıca, düzgün şekilde
    // DeepLinkService.uriLinkStream üzerinden işleniyor.
    //
    // Çözüm: Flutter'a HER ZAMAN "/" (varsayılan) initial route'u kullanmasını
    // söylüyoruz — deep link URI'sini biz zaten Dart tarafında
    // (DeepLinkService.init() → getInitialLink()) ayrıca, kendi kontrolümüzde
    // okuyup yönlendiriyoruz. Böylece Android'in otomatik enjekte ettiği route
    // hiçbir zaman GetX'e ulaşmıyor.
    override fun getInitialRoute(): String? {
        return "/"
    }
}