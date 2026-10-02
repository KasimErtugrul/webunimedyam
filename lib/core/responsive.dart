// lib/core/responsive.dart
//
// PROJENİN TEK RESPONSIVE KURAL KAYNAĞI.
// "Phone mu tablet mi" sorusu SADECE burada cevaplanır.
// Başka hiçbir dosyada MediaQuery.size.width > X gibi elle yazılmış
// bir eşik olmayacak — her yerde Responsive.isTablet(context) kullanılır.
//
// Not: shortestSide kullanıyoruz, width değil. Böylece bir telefon yatay
// çevrildiğinde (genişliği 700-900'e çıkabilir) yanlışlıkla "tablet"
// sanılmaz — çünkü telefonun kısa kenarı yön değiştirmekle değişmez.
//
// WEB: Tarayıcı (masaüstü) ölçüsü için width tabanlı üçüncü bir eşik
// vardır (isWeb). shortestSide yerine width kullanılır, çünkü bir
// masaüstü tarayıcı penceresi (ör. 1280x720) shortestSide'a göre
// "tablet" olurdu — web düzeni için YATAY alan belirleyicidir.

import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  /// Tablet eşiği. iPad mini (768) ve küçük Android tabletler (600-720)
  /// bu değerin üstünde kalacak şekilde seçildi.
  static const double tabletBreakpoint = 600;

  /// Web (masaüstü tarayıcı) eşiği. Pencere genişliği bu değerin
  /// üstündeyse web düzeni uygulanır: üst navigasyon barı, içeriğin
  /// maksimum genişlikle ortalanması vb.
  static const double webBreakpoint = 1024;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;
  }

  static bool isPhone(BuildContext context) => !isTablet(context);

  /// Masaüstü tarayıcı ölçüsü: pencere genişliği [webBreakpoint] ve üstü.
  /// Dikey alandan bağımsızdır; dar bir tarayıcı penceresi (ör. 800px)
  /// tablet düzenine düşer.
  static bool isWeb(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= webBreakpoint;
  }

  /// Cihaz sınıfına göre iki farklı değerden birini döndürür.
  /// Sadece basit sabit/renk/boşluk gibi tekil değerler için kullanılır.
  /// Layout kararları (kaç kolon vs.) için bunu KULLANMA —
  /// onun yerine tablet() gövdesi içinde LayoutBuilder kullan.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
  }) {
    return isTablet(context) ? tablet : mobile;
  }

  /// ÜÇLÜ ölçek seçimi: web (masaüstü tarayıcı) → tablet → telefon.
  ///
  /// Ölçü katmanları artık üçlüdür: her ekranın Phone/Tablet/Web ölçü
  /// setleri vardır (ör. PhoneHomeTabSizes / TabletHomeTabSizes /
  /// WebHomeTabSizes). Dal sırası ÖNEMLİDİR: isWeb önce kontrol edilir,
  /// çünkü masaüstü tarayıcı penceresi shortestSide'a göre genellikle
  /// "tablet" de olur — web kontrolü tabletin önünde olmazsa hiç
  /// yakalanamaz.
  static T value3<T>(
    BuildContext context, {
    required T web,
    required T tablet,
    required T mobile,
  }) {
    if (isWeb(context)) return web;
    return isTablet(context) ? tablet : mobile;
  }

  /// TEK ORTAK "oranlı ama taşmaz" genişlik/yükseklik hesaplayıcısı.
  ///
  /// [availableExtent] genelde LayoutBuilder'ın constraints.maxWidth'i
  /// (ya da maxHeight'i) — ekranın TAMAMI değil, o widget'a o an
  /// gerçekten ayrılan alan. ScreenUtil'in designSize'ı gibi sabit bir
  /// referansa göre DEĞİL, doğrudan bu değere göre ölçekler.
  ///
  /// [fraction] bu alanın kaçta kaçının isteneceği (0.22 = %22).
  /// [min]/[max] sonucun asla çıkamayacağı alt/üst sınır — burada verilen
  /// iki sayı "gerçek değer" değil, güvenlik sınırı: küçük ekranda çok
  /// dar, büyük ekranda çok geniş olmasını önler.
  ///
  /// Kullanım (herhangi bir dosyada):
  ///   final sidebarWidth = Responsive.clampedFraction(
  ///     constraints.maxWidth,
  ///     fraction: 0.22,
  ///     min: 220,
  ///     max: 300,
  ///   );
  static double clampedFraction(
    double availableExtent, {
    required double fraction,
    required double min,
    required double max,
  }) {
    return (availableExtent * fraction).clamp(min, max);
  }
}
