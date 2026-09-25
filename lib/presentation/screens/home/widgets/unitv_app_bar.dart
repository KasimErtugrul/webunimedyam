// lib/presentation/screens/home/widgets/unitv_app_bar.dart
//
// "ÜniTV / KAMPÜS YAYINI" logosunu içeren üst bar.
//
// Önceden bu bar, yalnızca HomeTabWidget'ın (Ana Sayfa sekmesi) içindeki
// CustomScrollView'a bir SliverAppBar olarak ekleniyordu. Bu yüzden
// kullanıcı Keşfet / Üniversiteler / Ara / Profil sekmelerine geçtiğinde
// bar tamamen kayboluyordu.
//
// Çözüm: bar, normal bir AppBar (PreferredSizeWidget) haline getirilip
// HomeScreen'in Scaffold.appBar'ına taşındı. HomeScreen, bottomNavigationBar
// ile birlikte IndexedStack'i sarmalıyor; Scaffold.appBar tüm sekmelerde
// (IndexedStack'in index'i ne olursa olsun) SABİT kalır, çünkü artık
// sekmelere özel scroll view'ların bir parçası değil, en dıştaki Scaffold'a
// ait.
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

class _PhoneSizes {
  static const double titleIconSize = 30;
  static const double titleIconBorderRadius = 8;
  static const double titleIconInnerSize = 18;
  static const double titleSpacing = 8;
  static const double titleSpacingLarge = 16;
}

class _TabletSizes {
  static const double titleIconSize = 36;
  static const double titleIconBorderRadius = 10;
  static const double titleIconInnerSize = 22;
  static const double titleSpacing = 10;
  static const double titleSpacingLarge = 20;
}

/// Tüm bottom navigation sekmelerinde sabit kalan üst bar.
class UniTvAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UniTvAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isTablet = Responsive.isTablet(context);
    final sizes = isTablet
        ? _TabletSizes.titleIconSize
        : _PhoneSizes.titleIconSize;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppTheme.bg(context),
      automaticallyImplyLeading: false,
      titleSpacing: isTablet
          ? _TabletSizes.titleSpacingLarge
          : _PhoneSizes.titleSpacingLarge,
      toolbarHeight: kToolbarHeight,
      actions: [
        IconButton(
          tooltip: 'Canlı Yayınlar',
          icon: const Icon(Icons.sensors_rounded),
          color: scheme.onSurfaceVariant,
          onPressed: () => Get.toNamed(AppRoutes.radio),
        ),
        IconButton(
          tooltip: 'Bildirimler',
          icon: const Icon(Icons.notifications_outlined),
          color: scheme.onSurfaceVariant,
          onPressed: () => Get.toNamed(AppRoutes.notifications), //ProfileScreen
        ),
        IconButton(
          tooltip: 'Bildirimler',
          icon: const Icon(Icons.person_rounded),
          color: scheme.onSurfaceVariant,
          onPressed: () => Get.toNamed(AppRoutes.profile), //ProfileScreen
        ),
      ],
      title: Row(
        children: [
          Container(
            width: sizes,
            height: sizes,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(
                isTablet
                    ? _TabletSizes.titleIconBorderRadius
                    : _PhoneSizes.titleIconBorderRadius,
              ),
            ),
            child: Icon(
              Icons.play_circle_rounded,
              color: scheme.primary,
              size: isTablet
                  ? _TabletSizes.titleIconInnerSize
                  : _PhoneSizes.titleIconInnerSize,
            ),
          ),
          SizedBox(
            width: isTablet
                ? _TabletSizes.titleSpacing
                : _PhoneSizes.titleSpacing,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style:
                        (isTablet
                                ? Theme.of(context).textTheme.headlineMedium
                                : Theme.of(context).textTheme.headlineSmall)
                            ?.copyWith(color: scheme.onSurface),
                    children: [
                      const TextSpan(text: 'Üni'),
                      TextSpan(
                        text: 'TV',
                        style: TextStyle(color: scheme.primary),
                      ),
                    ],
                  ),
                ),
                Text(
                  'KAMPÜS YAYINI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
