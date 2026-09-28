import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../controllers/video_section_detail_controller.dart';
import '../util/video_section_detail_screen_sizes.dart';
import 'video_section_detail_screen_card.dart';
import 'video_section_detail_tablet.dart';

/// Ekranın Scaffold + liste + pagination gövdesi. Eskiden phone/tablet için
/// birebir aynı ağacı tekrar eden iki dosya vardı (tek fark: boyutlar ve
/// scroll eşiği); artık tek widget + `sizes` parametresi.
///
/// TABLET: liste, Keşfet tasarım diliyle uyumlu ortalı grid gövdesine
/// yönlendirilir (bkz. video_section_detail_tablet.dart). Telefon yolu
/// aynen korunur.
class VideoSectionDetailScreenBuild extends StatelessWidget {
  const VideoSectionDetailScreenBuild({
    super.key,
    required this.sizes,
  });

  final VideoSectionDetailSizes sizes;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoSectionDetailController>();
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: sizes.appBarIconSize,
          ),
          onPressed: Get.back,
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
          // TABLET: iskelet grid; TELEFON: mevcut spinner.
          if (isTablet) {
            return const VideoSectionDetailTabletSkeleton();
          }
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.loadFirstPage,
          child: isTablet
              ? NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (scroll.metrics.pixels >=
                        scroll.metrics.maxScrollExtent -
                            sizes.scrollLoadThreshold) {
                      controller.loadNextPage();
                    }
                    return false;
                  },
                  child: VideoSectionDetailTabletGrid(sizes: sizes),
                )
              : NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >=
                  scroll.metrics.maxScrollExtent - sizes.scrollLoadThreshold) {
                controller.loadNextPage();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: sizes.listVerticalPadding,
              ),
              // NOT: eski kodda burada `(controller.hasMore.value ? 1 : 1)`
              // gibi her zaman +1 dönen anlamsız bir ternary vardı; asıl karar
              // zaten itemBuilder içinde veriliyordu. Davranış birebir aynı,
              // sadece niyet artık net: her zaman bir "footer slotu" var.
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
                          'Tüm videolar gösterildi',
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

                return VideoSectionDetailScreenCard(
                  item: controller.items[index],
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