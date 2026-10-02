import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../controllers/followed_universities_list_controller.dart';
import 'utils/followed_universities_list_sizes.dart';
import 'widgets/list_card.dart';
import 'widgets/list_empty_view.dart';

class FollowedUniversitiesListScreen extends StatelessWidget {
  const FollowedUniversitiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI (üçlü ölçek: web → tablet → telefon)
    final FollowedUniversitiesListSizes sizes = Responsive.isWeb(context)
        ? const FollowedUniversitiesListWebSizes()
        : Responsive.isTablet(context)
        ? const FollowedUniversitiesListTabletSizes()
        : const FollowedUniversitiesListPhoneSizes();

    final controller = Get.find<FollowedUniversitiesListController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takip Edilen Üniversiteler'),
        surfaceTintColor: Colors.transparent,
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

        if (controller.universities.isEmpty) {
          return FollowedUniversitiesListEmptyView(
            sizes: sizes,
            isOwnProfile: controller.isOwnProfile,
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.load,
          // WEB: liste çok geniş ekranlarda kenarlara yayılmasın.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: sizes.listPaddingHorizontal,
                  vertical: sizes.listPaddingVertical,
                ),
                itemCount: controller.universities.length,
                itemBuilder: (context, index) => FollowedUniversitiesListCard(
                  sizes: sizes,
                  university: controller.universities[index],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
