// lib/presentation/screens/interest_selection/interest_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/interest_selection_controller.dart';
import 'utils/sizes.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/error_state.dart';
import 'widgets/header.dart';
import 'widgets/university_chip.dart';


// ═══════════════════════════════════════════════════════════
// ANA WIDGET (TEK DALLANMA NOKTASI)
// ═══════════════════════════════════════════════════════════

class InterestSelectionScreen extends StatelessWidget {
  const InterestSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InterestSelectionSizes sizes = Responsive.isTablet(context)
        ? const InterestSelectionTabletSizes()
        : const InterestSelectionPhoneSizes();

    final controller = Get.find<InterestSelectionController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            InterestSelectionHeader(sizes: sizes, controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.errorMessage.value.isNotEmpty) {
                  return InterestSelectionErrorState(
                    sizes: sizes,
                    controller: controller,
                  );
                }
                final list = controller.filteredUniversities;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'Sonuç bulunamadı',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: sizes.emptyFontSize,
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    sizes.gridPaddingLeft,
                    sizes.gridPaddingTop,
                    sizes.gridPaddingRight,
                    sizes.gridPaddingBottom,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: sizes.isTablet ? 3 : 2,
                    mainAxisSpacing: sizes.gridMainAxisSpacing,
                    crossAxisSpacing: sizes.gridCrossAxisSpacing,
                    childAspectRatio: sizes.gridChildAspectRatio,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final uni = list[index];
                    return Obx(() {
                      final selected = uni.id != null &&
                          controller.isSelected(uni.id!);
                      return InterestSelectionUniversityChip(
                        sizes: sizes,
                        name: uni.name ?? '',
                        logoUrl: uni.logoUrl,
                        selected: selected,
                        onTap: uni.id == null
                            ? null
                            : () => controller.toggleUniversity(uni.id!),
                      );
                    });
                  },
                );
              }),
            ),
            InterestSelectionBottomBar(
              sizes: sizes,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}

