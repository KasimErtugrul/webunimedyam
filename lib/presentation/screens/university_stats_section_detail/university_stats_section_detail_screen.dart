// lib/presentation/screens/university_stats_section_detail/university_stats_section_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/university_stats_model.dart';
import '../home/tabs/home_tab/universities/university_sections_config.dart';
import 'university_stats_section_detail_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  const _PhoneSizes();

  final double appBarIconSize = 24;
  final double appBarTitleSize = 18;
  final double scrollLoadThreshold = 400;
  final double listVerticalPadding = 12;
  final double footerPaddingVertical = 20;
  final double footerLoaderWidth = 24;
  final double footerLoaderHeight = 24;
  final double footerLoaderStrokeWidth = 2.5;
  final double footerTextFontSize = 13;

  final double cardMarginHorizontal = 16;
  final double cardMarginVertical = 6;
  final double cardPadding = 12;
  final double cardBorderRadius = 14;
  final double logoSize = 56;
  final double logoBorderRadius = 10;
  final double logoSpacing = 12;
  final double titleFontSize = 14;
  final double citySpacing = 3;
  final double citySpacingTop = 4;
  final double cityIconSize = 13;
  final double cityFontSize = 12;
  final double statSpacing = 4;
  final double statIconSize = 14;
  final double statFontSize = 12.5;
  final double placeholderIconSize = 26;
}

class _TabletSizes {
  const _TabletSizes();

  final double appBarIconSize = 28;
  final double appBarTitleSize = 22;
  final double scrollLoadThreshold = 500;
  final double listVerticalPadding = 16;
  final double footerPaddingVertical = 24;
  final double footerLoaderWidth = 28;
  final double footerLoaderHeight = 28;
  final double footerLoaderStrokeWidth = 3;
  final double footerTextFontSize = 15;

  final double cardMarginHorizontal = 20;
  final double cardMarginVertical = 8;
  final double cardPadding = 16;
  final double cardBorderRadius = 16;
  final double logoSize = 64;
  final double logoBorderRadius = 12;
  final double logoSpacing = 14;
  final double titleFontSize = 16;
  final double citySpacing = 4;
  final double citySpacingTop = 5;
  final double cityIconSize = 15;
  final double cityFontSize = 14;
  final double statSpacing = 5;
  final double statIconSize = 16;
  final double statFontSize = 14;
  final double placeholderIconSize = 30;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class UniversityStatsSectionDetailScreen extends StatelessWidget {
  const UniversityStatsSectionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _build(context, const _TabletSizes())
        : _build(context, const _PhoneSizes());
  }

  Widget _build(BuildContext context, dynamic sizes) {
    final controller = Get.find<UniversityStatsSectionDetailController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: sizes.appBarIconSize),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.sectionTitle,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: sizes.appBarTitleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (controller.errorMessage.value != null && controller.items.isEmpty) {
          return _ErrorView(
            message: controller.errorMessage.value!,
            onRetry: controller.retry,
          );
        }

        if (controller.items.isEmpty) {
          return Center(
            child: Text(
              'Bu listede henüz kanal yok.',
              style: TextStyle(color: AppTheme.textSec(context)),
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.loadFirstPage,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >=
                  scroll.metrics.maxScrollExtent - sizes.scrollLoadThreshold) {
                controller.loadNextPage();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: sizes.listVerticalPadding),
              itemCount: controller.items.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.items.length) {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: sizes.footerPaddingVertical),
                      child: Center(
                        child: SizedBox(
                          width: sizes.footerLoaderWidth,
                          height: sizes.footerLoaderHeight,
                          child: CircularProgressIndicator(
                            strokeWidth: sizes.footerLoaderStrokeWidth,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  if (!controller.hasMore.value && controller.items.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: sizes.footerPaddingVertical),
                      child: Center(
                        child: Text(
                          'Tüm kanallar gösterildi',
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: sizes.footerTextFontSize,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return _StatCard(
                  item: controller.items[index],
                  sectionType: controller.sectionType,
                  sizes: sizes,
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// KART
// ═══════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.item,
    required this.sectionType,
    required this.sizes,
  });

  final UniversityStatsModel item;
  final UniversityStatsSectionType sectionType;
  final dynamic sizes;

  @override
  Widget build(BuildContext context) {
    // İlgili konfigi bulup aynı statLabel/ikon mantığını (ana sayfadaki ile
    // birebir aynı) burada da kullanıyoruz — tek kaynak, çift yazım yok.
    final cfg = uniSectionConfigs.firstWhere((c) => c.type == sectionType);
    final hasLogo = item.logoUrl != null && item.logoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.universityDetail, arguments: item.universityId),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: sizes.cardMarginHorizontal,
          vertical: sizes.cardMarginVertical,
        ),
        padding: EdgeInsets.all(sizes.cardPadding),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(sizes.cardBorderRadius),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(sizes.logoBorderRadius),
              child: hasLogo
                  ? CachedNetworkImage(
                      imageUrl: item.logoUrl!,
                      width: sizes.logoSize,
                      height: sizes.logoSize,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholder(context),
                      placeholder: (_, _) => Container(
                        width: sizes.logoSize,
                        height: sizes.logoSize,
                        color: AppTheme.surface(context),
                      ),
                    )
                  : _placeholder(context),
            ),
            SizedBox(width: sizes.logoSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: sizes.titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.city != null && item.city!.isNotEmpty) ...[
                    SizedBox(height: sizes.citySpacingTop),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: sizes.cityIconSize,
                          color: AppTheme.textSec(context),
                        ),
                        SizedBox(width: sizes.citySpacing),
                        Text(
                          item.city!,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: sizes.cityFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: sizes.citySpacingTop),
                  Row(
                    children: [
                      Icon(
                        cfg.statIcon,
                        size: sizes.statIconSize,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: sizes.statSpacing),
                      Text(
                        cfg.statLabelBuilder(item),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: sizes.statFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        width: sizes.logoSize,
        height: sizes.logoSize,
        color: AppTheme.surface(context),
        child: Icon(
          Icons.account_balance_rounded,
          color: AppTheme.textSec(context),
          size: sizes.placeholderIconSize,
        ),
      );
}

// ═══════════════════════════════════════════════════════════
// HATA GÖRÜNÜMÜ
// ═══════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.textSec(context),
              size: 48.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSec(context)),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => onRetry(),
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
