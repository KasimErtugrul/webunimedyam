// lib/presentation/screens/search/search_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/responsive.dart';
import '../../controllers/video_search_controller.dart';
import 'widgets/video_result_card_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double backIconSize = 24;
  static const double titlePaddingRight = 16;
  static const double searchFontSize = 16;
  static const double searchPaddingHorizontal = 16;
  static const double searchPaddingVertical = 10;
  static const double searchBorderRadius = 12;
  static const double clearIconSize = 20;
  
  // Loading
  static const double loadingStrokeWidth = 3;
  
  // Empty
  static const double emptyIconSize = 64;
  static const double emptySpacing = 16;
  static const double emptyFontSize = 15;
  
  // History
  static const double historyIconSize = 56;
  static const double historySpacing = 12;
  static const double historyFontSize = 15;
  static const double historyTitleFontSize = 14;
  static const double historyTitleSpacing = 16;
  static const double historyClearButtonWidth = 60;
  static const double historyClearButtonHeight = 36;
  static const double historyClearButtonPadding = 8;
  static const double historyClearFontSize = 13;
  static const double historyListItemIconSize = 20;
  static const double historyListItemFontSize = 14;
  static const double historyListItemCloseSize = 18;
  static const double historyListItemMinWidth = 32;
  static const double historyListItemMinHeight = 32;
  static const double historyListItemPaddingHorizontal = 16;
  static const double historyListItemPaddingVertical = 4;
  
  // Results
  static const double resultsPaddingHorizontal = 16;
  static const double resultsPaddingVertical = 8;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double backIconSize = 28;
  static const double titlePaddingRight = 20;
  static const double searchFontSize = 18;
  static const double searchPaddingHorizontal = 20;
  static const double searchPaddingVertical = 12;
  static const double searchBorderRadius = 14;
  static const double clearIconSize = 22;
  
  // Loading - tablet için daha büyük
  static const double loadingStrokeWidth = 3.5;
  
  // Empty - tablet için daha büyük
  static const double emptyIconSize = 72;
  static const double emptySpacing = 20;
  static const double emptyFontSize = 17;
  
  // History - tablet için daha büyük
  static const double historyIconSize = 64;
  static const double historySpacing = 14;
  static const double historyFontSize = 17;
  static const double historyTitleFontSize = 16;
  static const double historyTitleSpacing = 20;
  static const double historyClearButtonWidth = 70;
  static const double historyClearButtonHeight = 40;
  static const double historyClearButtonPadding = 10;
  static const double historyClearFontSize = 15;
  static const double historyListItemIconSize = 22;
  static const double historyListItemFontSize = 16;
  static const double historyListItemCloseSize = 20;
  static const double historyListItemMinWidth = 36;
  static const double historyListItemMinHeight = 36;
  static const double historyListItemPaddingHorizontal = 20;
  static const double historyListItemPaddingVertical = 6;
  
  // Results - tablet için daha büyük
  static const double resultsPaddingHorizontal = 24;
  static const double resultsPaddingVertical = 12;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final VideoSearchController controller;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    controller = Get.find<VideoSearchController>();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onHistoryTap(String q) {
    _textController.text = q;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: q.length),
    );
    controller.onQueryChanged(q);
  }

  void _onSubmit(String q) {
    controller.submitQuery(q);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPri(context),
            size: _PhoneSizes.backIconSize.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Padding(
          padding: EdgeInsets.only(right: _PhoneSizes.titlePaddingRight.w),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: controller.onQueryChanged,
            onSubmitted: _onSubmit,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _PhoneSizes.searchFontSize.sp,
            ),
            decoration: InputDecoration(
              hintText: 'Video ara...',
              hintStyle: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.searchFontSize.sp,
              ),
              filled: true,
              fillColor: AppTheme.card(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _PhoneSizes.searchPaddingHorizontal.w,
                vertical: _PhoneSizes.searchPaddingVertical.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_PhoneSizes.searchBorderRadius.r),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Obx(
                () => controller.query.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSec(context),
                          size: _PhoneSizes.clearIconSize.sp,
                        ),
                        onPressed: () {
                          _textController.clear();
                          controller.onQueryChanged('');
                          _focusNode.requestFocus();
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final q = controller.query.value;

        if (q.trim().isEmpty) {
          return _HistoryViewPhone(controller: controller, onTap: _onHistoryTap);
        }

        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
            ),
          );
        }

        if (controller.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  color: AppTheme.textSec(context),
                  size: _PhoneSizes.emptyIconSize.sp,
                ),
                SizedBox(height: _PhoneSizes.emptySpacing.h),
                Text(
                  '"$q" için sonuç bulunamadı',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.emptyFontSize.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: _PhoneSizes.resultsPaddingHorizontal.w,
            vertical: _PhoneSizes.resultsPaddingVertical.h,
          ),
          itemCount: controller.results.length,
          itemBuilder: (_, i) => VideoResultCardWidget(
            video: controller.results[i],
            query: q,
            onTap: () {
              controller.submitQuery(q);
              Get.toNamed(
                AppRoutes.player,
                arguments: controller.results[i],
                parameters: {'videoId': controller.results[i].videoId},
              );
            },
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPri(context),
            size: _TabletSizes.backIconSize,
          ),
          onPressed: () => Get.back(),
        ),
        title: Padding(
          padding: EdgeInsets.only(right: _TabletSizes.titlePaddingRight),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: controller.onQueryChanged,
            onSubmitted: _onSubmit,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _TabletSizes.searchFontSize,
            ),
            decoration: InputDecoration(
              hintText: 'Video ara...',
              hintStyle: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.searchFontSize,
              ),
              filled: true,
              fillColor: AppTheme.card(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _TabletSizes.searchPaddingHorizontal,
                vertical: _TabletSizes.searchPaddingVertical,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_TabletSizes.searchBorderRadius),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Obx(
                () => controller.query.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSec(context),
                          size: _TabletSizes.clearIconSize,
                        ),
                        onPressed: () {
                          _textController.clear();
                          controller.onQueryChanged('');
                          _focusNode.requestFocus();
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final q = controller.query.value;

        if (q.trim().isEmpty) {
          return _HistoryViewTablet(controller: controller, onTap: _onHistoryTap);
        }

        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: _TabletSizes.loadingStrokeWidth,
            ),
          );
        }

        if (controller.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  color: AppTheme.textSec(context),
                  size: _TabletSizes.emptyIconSize,
                ),
                SizedBox(height: _TabletSizes.emptySpacing),
                Text(
                  '"$q" için sonuç bulunamadı',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.emptyFontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: _TabletSizes.resultsPaddingHorizontal,
            vertical: _TabletSizes.resultsPaddingVertical,
          ),
          itemCount: controller.results.length,
          itemBuilder: (_, i) => VideoResultCardWidget(
            video: controller.results[i],
            query: q,
            onTap: () {
              controller.submitQuery(q);
              Get.toNamed(
                AppRoutes.player,
                arguments: controller.results[i],
                parameters: {'videoId': controller.results[i].videoId},
              );
            },
          ),
        );
      }),
    );
  }
}

// ── Geçmiş paneli (PHONE) ────────────────────────────────────────────────────

class _HistoryViewPhone extends StatelessWidget {
  final VideoSearchController controller;
  final void Function(String) onTap;

  const _HistoryViewPhone({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.history.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                color: AppTheme.textSec(context),
                size: _PhoneSizes.historyIconSize.sp,
              ),
              SizedBox(height: _PhoneSizes.historySpacing.h),
              Text(
                'Arama geçmişi yok',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.historyFontSize.sp,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              _PhoneSizes.historyTitleSpacing.w,
              _PhoneSizes.historyTitleSpacing.h,
              _PhoneSizes.historyClearButtonPadding.w,
              _PhoneSizes.historySpacing.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Aramalar',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.historyTitleFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearHistory,
                  style: TextButton.styleFrom(
                    minimumSize: Size(
                      _PhoneSizes.historyClearButtonWidth.w,
                      _PhoneSizes.historyClearButtonHeight.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _PhoneSizes.historyClearButtonPadding.w,
                    ),
                  ),
                  child: Text(
                    'Temizle',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: _PhoneSizes.historyClearFontSize.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.history.length,
              itemBuilder: (_, i) {
                final q = controller.history[i];
                return ListTile(
                  leading: Icon(
                    Icons.history_rounded,
                    color: AppTheme.textSec(context),
                    size: _PhoneSizes.historyListItemIconSize.sp,
                  ),
                  title: Text(
                    q,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _PhoneSizes.historyListItemFontSize.sp,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSec(context),
                      size: _PhoneSizes.historyListItemCloseSize.sp,
                    ),
                    onPressed: () => controller.removeHistory(q),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: _PhoneSizes.historyListItemMinWidth.w,
                      minHeight: _PhoneSizes.historyListItemMinHeight.h,
                    ),
                  ),
                  onTap: () => onTap(q),
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: _PhoneSizes.historyListItemPaddingHorizontal.w,
                    vertical: _PhoneSizes.historyListItemPaddingVertical.h,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ── Geçmiş paneli (TABLET) ────────────────────────────────────────────────────

class _HistoryViewTablet extends StatelessWidget {
  final VideoSearchController controller;
  final void Function(String) onTap;

  const _HistoryViewTablet({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.history.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                color: AppTheme.textSec(context),
                size: _TabletSizes.historyIconSize,
              ),
              SizedBox(height: _TabletSizes.historySpacing),
              Text(
                'Arama geçmişi yok',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.historyFontSize,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              _TabletSizes.historyTitleSpacing,
              _TabletSizes.historyTitleSpacing,
              _TabletSizes.historyClearButtonPadding,
              _TabletSizes.historySpacing,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Aramalar',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.historyTitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearHistory,
                  style: TextButton.styleFrom(
                    minimumSize: Size(
                      _TabletSizes.historyClearButtonWidth,
                      _TabletSizes.historyClearButtonHeight,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _TabletSizes.historyClearButtonPadding,
                    ),
                  ),
                  child: Text(
                    'Temizle',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: _TabletSizes.historyClearFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.history.length,
              itemBuilder: (_, i) {
                final q = controller.history[i];
                return ListTile(
                  leading: Icon(
                    Icons.history_rounded,
                    color: AppTheme.textSec(context),
                    size: _TabletSizes.historyListItemIconSize,
                  ),
                  title: Text(
                    q,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _TabletSizes.historyListItemFontSize,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSec(context),
                      size: _TabletSizes.historyListItemCloseSize,
                    ),
                    onPressed: () => controller.removeHistory(q),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: _TabletSizes.historyListItemMinWidth,
                      minHeight: _TabletSizes.historyListItemMinHeight,
                    ),
                  ),
                  onTap: () => onTap(q),
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: _TabletSizes.historyListItemPaddingHorizontal,
                    vertical: _TabletSizes.historyListItemPaddingVertical,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}