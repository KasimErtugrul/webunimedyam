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

import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  /// Tablet eşiği. iPad mini (768) ve küçük Android tabletler (600-720)
  /// bu değerin üstünde kalacak şekilde seçildi.
  static const double tabletBreakpoint = 600;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= tabletBreakpoint;
  }

  static bool isPhone(BuildContext context) => !isTablet(context);

  /// Cihaz sınıfına göre iki farklı değerden birini döndürür.
  /// Sadece basit sabit/renk/boşluk gibi tekil değerler için kullanılır.
  /// Layout kararları (kaç kolon vs.) için bunu KULLANMA —
  /// onun yerine tablet() gövdesi içinde LayoutBuilder kullan.
  static T value<T>(BuildContext context, {required T mobile, required T tablet}) {
    return isTablet(context) ? tablet : mobile;
  }
}