// lib/presentation/screens/profile/profile_activity_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/profile_activity_list_controller.dart';
import 'utils/sizes.dart';
import 'widgets/empty_view.dart';
import 'widgets/flat_content.dart';
import 'widgets/no_results_view.dart';

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (TEK DALLANMA NOKTASI)
// ═══════════════════════════════════════════════════════════

class ProfileActivityListScreen extends StatefulWidget {
  const ProfileActivityListScreen({super.key});

  @override
  State<ProfileActivityListScreen> createState() =>
      _ProfileActivityListScreenState();
}

class _ProfileActivityListScreenState extends State<ProfileActivityListScreen> {
  late final ProfileActivityListController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileActivityListController>();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    final ProfileActivityListSizes sizes = Responsive.isTablet(context)
        ? const ProfileActivityListTabletSizes()
        : const ProfileActivityListPhoneSizes();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.pageTitle,
          style: TextStyle(
            fontSize: sizes.appBarTitleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        actions: [
          Obx(() {
            final isGrid = controller.viewMode.value == ActivityViewMode.grid;
            return IconButton(
              tooltip: isGrid ? 'Liste Görünümü' : 'Izgara Görünümü',
              icon: Icon(
                isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                size: sizes.appBarIconSize,
                color: AppTheme.textPri(context),
              ),
              onPressed: () => controller.changeViewMode(
                isGrid ? ActivityViewMode.list : ActivityViewMode.grid,
              ),
            );
          }),
          SizedBox(width: sizes.appBarIconPadding),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: sizes.loadingStrokeWidth,
                  ),
                );
              }

              if (controller.videos.isEmpty) {
                return ProfileActivityListEmptyView(
                  sizes: sizes,
                  emptyText: controller.emptyText,
                  emptySubtext: controller.emptySubtext,
                  activityType: controller.activityType,
                );
              }

              final displayVideos = controller.filteredVideos;

              if (displayVideos.isEmpty) {
                return ProfileActivityListNoResultsView(
                  sizes: sizes,
                  query: controller.searchQuery.value,
                );
              }

              final isGrid = controller.viewMode.value == ActivityViewMode.grid;

              return RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: controller.loadInitial,
                child: ProfileActivityListFlatContent(
                  sizes: sizes,
                  controller: controller,
                  videos: displayVideos,
                  scrollController: _scrollController,
                  isGrid: isGrid,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
