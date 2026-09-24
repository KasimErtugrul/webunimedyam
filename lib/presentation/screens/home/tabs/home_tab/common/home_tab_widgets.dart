// lib/presentation/screens/home/tabs/home_tab/common/home_tab_widgets.dart
//
// Phone/tablet arasında yalnızca boyut kaynağı farklı olan ortak widget'lar.
// Hepsi ölçülerini HomeTabSizes'tan alır; kendileri ScreenUtil'e kör.
//
// HomeContentHeader, kendisini sarmalayan Obx içinde kullanılmalı
// (feedFilter.value'u build'de okur — orijinaldekiyle aynı reaktivite).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/repositories/video_repository.dart'
    show HomeFeedFilter;
import '../../../../../controllers/home/home_controller.dart';
import '../widgets/continue_watching_section_widget.dart';
import 'home_tab_sizes.dart';

// ═══════════════════════════════════════════════════════════
// HomeFeedFilter yardımcıları (iki kopyada birebir aynıydı)
// ═══════════════════════════════════════════════════════════

extension HomeFeedFilterX on HomeFeedFilter {
  IconData get icon => switch (this) {
        HomeFeedFilter.latest => Icons.new_releases_rounded,
        HomeFeedFilter.followed => Icons.favorite_rounded,
        HomeFeedFilter.notFollowed => Icons.explore_outlined,
        HomeFeedFilter.live => Icons.sensors_rounded,
      };

  String get label => switch (this) {
        HomeFeedFilter.latest => 'En Yeniler',
        HomeFeedFilter.followed => 'Takip Ettiklerim',
        HomeFeedFilter.notFollowed => 'Takip Etmediklerim',
        HomeFeedFilter.live => 'Canlı Yayın',
      };

  String get subtitle => switch (this) {
        HomeFeedFilter.latest =>
          'Takip ettiğin ve diğer üniversitelerden en yeni paylaşımlar burada.',
        HomeFeedFilter.followed =>
          'Sadece takip ettiğin üniversitelerin en yeni videoları.',
        HomeFeedFilter.notFollowed =>
          'Henüz takip etmediğin üniversitelerden en yeni paylaşımlar.',
        HomeFeedFilter.live => 'Şu anda canlı yayında olan üniversiteler.',
      };

  // Filtre sonucu boşsa filtreye özgü mesaj (kullanıcı bunu "hata" olarak
  // değil, bilgi olarak görsün).
  String emptyMessage({required bool isLoggedIn}) => switch (this) {
        HomeFeedFilter.latest => 'Henüz video yok.',
        HomeFeedFilter.followed => isLoggedIn
            ? 'Henüz hiçbir üniversiteyi takip etmiyorsun.\nÜniversiteler sekmesinden takip etmeye başlayabilirsin.'
            : 'Takip ettiğin üniversitelerin videolarını görmek için giriş yapman gerekiyor.',
        HomeFeedFilter.notFollowed => 'Takip etmediğin üniversite kalmamış 🎉',
        HomeFeedFilter.live => 'Şu anda canlı yayında olan üniversite yok.',
      };
}

PopupMenuItem<HomeFeedFilter> _feedFilterMenuItem(
  HomeFeedFilter filter,
  HomeFeedFilter activeFilter,
) {
  final selected = filter == activeFilter;
  return PopupMenuItem<HomeFeedFilter>(
    value: filter,
    child: Row(
      children: [
        Icon(
          filter.icon,
          size: 18,
          color: selected ? AppTheme.primaryColor : null,
        ),
        const SizedBox(width: 10),
        Text(
          filter.label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppTheme.primaryColor : null,
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// "Üniversitelerin Son Videoları" bölüm başlığı + filtre seçici
// ═══════════════════════════════════════════════════════════

class HomeContentHeader extends StatelessWidget {
  const HomeContentHeader({
    super.key,
    required this.controller,
    required this.sizes,
  });

  final HomeController controller;
  final HomeTabSizes sizes;

  @override
  Widget build(BuildContext context) {
    final activeFilter = controller.feedFilter.value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.video_library_rounded,
                    size: sizes.contentTitleIconSize,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: sizes.contentTitleIconSpacing),
                  Flexible(
                    child: Text(
                      'Üniversitelerin Son Videoları',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: sizes.contentTitleFontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sizes.contentTitleSubSpacing),
              Text(
                activeFilter.subtitle,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: sizes.contentSubtitleFontSize,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<HomeFeedFilter>(
          initialValue: activeFilter,
          tooltip: 'Videoları filtrele',
          onSelected: controller.setFeedFilter,
          itemBuilder: (context) => HomeFeedFilter.values
              .map((f) => _feedFilterMenuItem(f, activeFilter))
              .toList(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.sortPadH,
              vertical: sizes.sortPadV,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activeFilter.label,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.sortFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: sizes.sortIconSize,
                  color: AppTheme.textSec(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Utility bar: "Kampüs FM Canlı" pili + Liste/Çark görünüm anahtarı
// ═══════════════════════════════════════════════════════════

class HomeUtilityBar extends StatelessWidget {
  const HomeUtilityBar({
    super.key,
    required this.controller,
    required this.sizes,
  });

  final HomeController controller;
  final HomeTabSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = sizes.titleSpacingLarge;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: sizes.utilityBarPadV),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Canlı Kampüs Radyosu Düğmesi
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            onTap: () => Get.toNamed(AppRoutes.radio),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sizes.radioPadH,
                vertical: sizes.radioPadV,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: sizes.radioDotSize,
                    height: sizes.radioDotSize,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: sizes.radioGapSmall),
                  Icon(
                    Icons.radio_rounded,
                    color: scheme.primary,
                    size: sizes.radioIconSize,
                  ),
                  SizedBox(width: sizes.radioGapSmall),
                  Text(
                    'Kampüs FM Canlı',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: scheme.onSurface),
                  ),
                  SizedBox(width: sizes.radioGapTiny),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizes.radioBadgePadH,
                      vertical: sizes.radioBadgePadV,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(sizes.radioBadgeRadius),
                    ),
                    child: Text(
                      'YAYINDA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Görünüm Modu Seçici (Liste vs Çark)
          Obx(
            () => Container(
              padding: EdgeInsets.all(sizes.viewToggleOuterPad),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(sizes.viewToggleOuterRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewModeButton(
                    icon: Icons.view_agenda_rounded,
                    tooltip: 'Liste Görünümü',
                    selected: !controller.isWheelView.value,
                    size: sizes.viewToggleButtonSize,
                    iconSize: sizes.viewToggleIconSize,
                    onTap: () {
                      if (controller.isWheelView.value) {
                        controller.toggleWheelView();
                      }
                    },
                  ),
                  _ViewModeButton(
                    icon: Icons.grid_view_rounded,
                    tooltip: 'Çark / Grid Görünümü',
                    selected: controller.isWheelView.value,
                    size: sizes.viewToggleButtonSize,
                    iconSize: sizes.viewToggleIconSize,
                    onTap: () {
                      if (!controller.isWheelView.value) {
                        controller.toggleWheelView();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Görünüm modu anahtarı içindeki tek düğme (Liste / Çark).
// Seçili → bg-primary + on-primary; değil → şeffaf + on-surface-variant.
class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// İzlemeye Devam Et bölümü (Obx sarmalı orijinaldeki gibi içeride)
// ═══════════════════════════════════════════════════════════

class HomeContinueWatchingSection extends StatelessWidget {
  const HomeContinueWatchingSection({
    super.key,
    required this.controller,
    required this.sizes,
  });

  final HomeController controller;
  final HomeTabSizes sizes;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.continueWatching.toList();
      // Çark görünümünde bu bölüm gösterilmez.
      final showSection =
          !controller.isWheelView.value && items.isNotEmpty;
      if (!showSection) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(top: sizes.continueWatchingTopPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContinueWatchingSectionWidget(
              items: items,
              onRemove: controller.removeFromContinueWatching,
            ),
            // Bir sonraki bölümle ("Üniversitelerin Son Videoları")
            // arada nefes alan bir boşluk.
            SizedBox(height: sizes.continueWatchingExtraSpacing),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════
// "Yaklaşan Canlı Yayın" alt şeridi
// DÜRÜST NOT (orijinalden korunmuştur): Backend'de henüz "yaklaşan canlı
// yayın" verisi yok — metinler SABİT (placeholder). Gerçek veri gelince
// bağlanmalı; "Hatırlat" butonunun onTap'i bu yüzden boş.
// ═══════════════════════════════════════════════════════════

class HomeUpcomingLiveBanner extends StatelessWidget {
  const HomeUpcomingLiveBanner({super.key, required this.sizes});

  final HomeTabSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = sizes.titleSpacingLarge;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        hPad,
        sizes.bannerVerticalGap,
        hPad,
        sizes.bannerBottomGap,
      ),
      child: Container(
        padding: EdgeInsets.all(sizes.bannerPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [scheme.surfaceContainerHigh, scheme.surfaceContainer],
          ),
          borderRadius: BorderRadius.circular(sizes.bannerContainerRadius),
        ),
        child: Row(
          children: [
            Container(
              width: sizes.bannerIconBox,
              height: sizes.bannerIconBox,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(sizes.bannerIconRadius),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.live_tv_rounded,
                color: scheme.primary,
                size: sizes.bannerIconSize,
              ),
            ),
            SizedBox(width: sizes.bannerIconTextGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yaklaşan Canlı Yayın',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: sizes.bannerTitleFontSize,
                    ),
                  ),
                  Text(
                    'Yarın 14:00 • ODTÜ Mezuniyet Töreni',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: sizes.bannerSubtitleFontSize,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: sizes.bannerActionGap),
            InkWell(
              borderRadius: BorderRadius.circular(sizes.bannerButtonRadius),
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sizes.bannerButtonPadH,
                  vertical: sizes.bannerButtonPadV,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(sizes.bannerButtonRadius),
                ),
                child: Text(
                  'Hatırlat',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: sizes.bannerButtonFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Error / Empty / Shimmer
// ═══════════════════════════════════════════════════════════

class HomeErrorWidget extends StatelessWidget {
  const HomeErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    required this.sizes,
  });

  final String message;
  final VoidCallback onRetry;
  final HomeTabSizes sizes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sizes.errorPadding),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.textSec(context),
            size: sizes.errorIconSize,
          ),
          SizedBox(height: sizes.errorSpacing),
          // DÜRÜST NOT: Orijinal phone kopyasında textAlign yoktu, tablet'te
          // center vardı — çok satırlı mesajda hizalama için center seçildi.
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: sizes.errorFontSize,
            ),
          ),
          SizedBox(height: sizes.errorSpacing),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(sizes.errorButtonWidth, sizes.errorButtonHeight),
            ),
            onPressed: onRetry,
            child: Text(
              'Tekrar Dene',
              style: TextStyle(fontSize: sizes.errorFontSize),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeEmptyWidget extends StatelessWidget {
  const HomeEmptyWidget({
    super.key,
    required this.message,
    required this.sizes,
  });

  final String message;
  final HomeTabSizes sizes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(sizes.emptyPadding),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: sizes.emptyFontSize,
          ),
        ),
      ),
    );
  }
}

// Video listesi yüklenirken gösterilen shimmer bloğu
// (phone/tablet tek yapı — boyutlar sizes'tan).
class HomeVideoShimmer extends StatelessWidget {
  const HomeVideoShimmer({super.key, required this.sizes});

  final HomeTabSizes sizes;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(
          sizes.shimmerCount,
          (_) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.shimmerItemSpacingHorizontal,
              vertical: sizes.shimmerItemSpacingVertical,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(sizes.shimmerBorderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: sizes.shimmerImageHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(sizes.shimmerBorderRadius),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      sizes.shimmerPaddingLeft,
                      sizes.shimmerPaddingTop,
                      sizes.shimmerPaddingRight,
                      sizes.shimmerPaddingBottom,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: sizes.shimmerAvatarSize,
                          height: sizes.shimmerAvatarSize,
                          margin: EdgeInsets.only(
                            right: sizes.shimmerAvatarSpacing,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(
                              sizes.shimmerAvatarRadius,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: sizes.shimmerTitleHeight,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(height: sizes.shimmerSpacingSmall),
                              Container(
                                height: sizes.shimmerTitleHeight,
                                width: sizes.shimmerTitleWidth,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(height: sizes.shimmerSpacingMedium),
                              Container(
                                height: sizes.shimmerSubtitleHeight,
                                width: sizes.shimmerSubtitleWidth,
                                color: AppTheme.surface(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}