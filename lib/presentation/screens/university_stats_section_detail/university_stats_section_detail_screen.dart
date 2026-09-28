// lib/presentation/screens/university_stats_section_detail/university_stats_section_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/university_stats_section_detail_controller.dart';
import 'utils/university_stats_section_detail_sizes.dart';
import 'widgets/detail_card.dart';
import 'widgets/error_view.dart';


// ═══════════════════════════════════════════════════════════
// ANA WIDGET (TEK DALLANMA NOKTASI)
// ═══════════════════════════════════════════════════════════

class UniversityStatsSectionDetailScreen extends StatelessWidget {
  const UniversityStatsSectionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    final UniversityStatsSectionDetailSizes sizes = Responsive.isTablet(context)
        ? const UniversityStatsSectionDetailTabletSizes()
        : const UniversityStatsSectionDetailPhoneSizes();

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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: sizes.appBarTitleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        if (controller.errorMessage.value != null && controller.items.isEmpty) {
          return UniversityStatsSectionDetailErrorView(
            sizes: sizes,
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
                      padding: EdgeInsets.symmetric(
                        vertical: sizes.footerPaddingVertical,
                      ),
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
                  if (!controller.hasMore.value &&
                      controller.items.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: sizes.footerPaddingVertical,
                      ),
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

                return UniversityStatsSectionDetailCard(
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
// HATA GÖRÜNÜMÜ (TEK WIDGET)
// ═══════════════════════════════════════════════════════════