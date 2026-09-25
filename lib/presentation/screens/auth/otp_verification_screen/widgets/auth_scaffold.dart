// lib/presentation/screens/auth/widgets/auth_scaffold.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';

/// Tüm auth ekranları için ortak iskelet:
///   • Arka plan rengi ve AppBar (geri butonu + başlık)
///   • SafeArea + Center + max-width kısıtı
///   • BouncingScrollPhysics'li SingleChildScrollView
///   • İçeriğin altına güvenli boşluk
class AuthScaffold extends StatelessWidget {
  final String title;
  final double maxContentWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double bottomPadding;
  final Widget child;
  final List<Widget>? actions;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.maxContentWidth,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.bottomPadding,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: 20,
          ),
          onPressed: Get.back,
        ),
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}