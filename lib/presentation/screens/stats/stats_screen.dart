// lib/presentation/screens/stats/stats_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/stats_controller.dart';
import 'utils/stats_sizes.dart';
import 'widgets/error_view.dart';
import 'widgets/stats_body.dart';


// ═══════════════════════════════════════════════════════════
// ANA WIDGET (TEK DALLANMA NOKTASI)
// ═══════════════════════════════════════════════════════════

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StatsSizes sizes = Responsive.isTablet(context)
        ? const StatsTabletSizes()
        : const StatsPhoneSizes();

    final controller = Get.find<StatsController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'İstatistiklerim',
          style: TextStyle(
            fontSize: sizes.appBarTitleSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPri(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: sizes.backIconSize,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textSec(context),
                      size: sizes.refreshIconSize,
                    ),
                    tooltip: 'Yenile',
                    onPressed: controller.refresh,
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: sizes.loadingStrokeWidth,
            ),
          );
        }

        if (controller.errorMessage.value != null ||
            controller.stats.value == null) {
          return StatsErrorView(sizes: sizes, onRetry: controller.refresh);
        }

        return StatsBody(sizes: sizes, stats: controller.stats.value!);
      }),
    );
  }
}