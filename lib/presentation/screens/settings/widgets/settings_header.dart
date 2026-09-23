// lib/presentation/screens/settings/widgets/settings_header.dart
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../settings_layout_spec.dart';

/// Tasarımdaki sabit (pinned) blur'lu üst bar:
/// [← Geri]  Başlık  ................  [paylaş] [avatar]
///
/// Not: Tasarım dosyasında bu başlık "Yayın Detay" yazıyor; ancak içerik
/// Ayarlar ekranına ait (şablon devralınmış görünüyor). Başlık aşağıdaki
/// sabitten tek satırda değiştirilebilir.
class SettingsHeader extends StatelessWidget {
  final SettingsLayoutSpec spec;
  const SettingsHeader({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: spec.headerHeight.h,
      titleSpacing: 12.w,
      flexibleSpace: ClipRect(
        // bg-surface/85 backdrop-blur-xl
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: ColoredBox(
            color: scheme.surface.withValues(alpha: 0.85),
            child: const SizedBox.expand(),
          ),
        ),
      ),
      title: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            tooltip: 'Geri Dön',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: spec.headerTouchSize.w,
              minHeight: spec.headerTouchSize.h,
            ),
            icon: Icon(
              Icons.arrow_back_rounded,
              size: spec.headerIconSize.sp,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(width: spec.headerGap.w),
          Expanded(
            child: Text(
              'Ayarlar',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: spec.headerTitleFontSize.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01 * spec.headerTitleFontSize,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: paylaşma aksiyonu (share_plus vb.)
            },
            tooltip: 'Paylaş',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: spec.headerTouchSize.w,
              minHeight: spec.headerTouchSize.h,
            ),
            icon: Icon(
              Icons.share_rounded,
              size: spec.headerShareIconSize.sp,
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            width: spec.headerAvatarSize.w,
            height: spec.headerAvatarSize.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary,
            ),
            child: Icon(
              Icons.person_rounded,
              size: spec.headerAvatarIconSize.sp,
              color: scheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}