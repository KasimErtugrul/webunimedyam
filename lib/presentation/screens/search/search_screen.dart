// lib/presentation/screens/search/search_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/video_search_controller.dart';
import 'search_layout_spec.dart';
import 'widgets/search_empty_view.dart';
import 'widgets/search_field.dart';
import 'widgets/search_history_view.dart';
import 'widgets/search_loading_skeleton.dart';
import 'widgets/search_results_header.dart';
import 'widgets/video_result_card_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final VideoSearchController controller;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  Timer? _debounce;

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
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Her tuşta değil, kullanıcı durunca arama yap (250 ms).
  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      controller.onQueryChanged(q);
    });
  }

  void _onHistoryTap(String q) {
    _debounce?.cancel();
    _textController.text = q;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: q.length),
    );
    controller.onQueryChanged(q);
    _focusNode.requestFocus();
  }

  void _onSubmit(String q) {
    _debounce?.cancel();
    controller.submitQuery(q);
    _focusNode.unfocus();
  }

  void _clearQuery() {
    _debounce?.cancel();
    _textController.clear();
    controller.onQueryChanged('');
    _focusNode.requestFocus();
  }

  void _openVideo(int index, String q) {
    final video = controller.results[index];
    controller.submitQuery(q);
    Get.toNamed(
      AppRoutes.player,
      arguments: video,
      parameters: {'videoId': video.videoId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final spec = SearchLayoutSpec.of(context);

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPri(context),
            size: 24.sp,
          ),
          onPressed: Get.back,
        ),
        title: Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: SearchField(
            spec: spec,
            textController: _textController,
            focusNode: _focusNode,
            controller: controller,
            onChanged: _onChanged,
            onSubmitted: _onSubmit,
          ),
        ),
      ),
      body: Obx(() {
        final q = controller.query.value.trim();

        // 1) Sorgu yok → geçmiş
        if (q.isEmpty) {
          return SearchHistoryView(
            spec: spec,
            controller: controller,
            onTap: _onHistoryTap,
          );
        }

        // 2) Yükleniyor → skeleton
        if (controller.isLoading.value) {
          return SearchLoadingSkeleton(spec: spec);
        }

        // 3) Sonuç yok → empty
        if (controller.results.isEmpty) {
          return SearchEmptyView(
            spec: spec,
            query: q,
            onClear: _clearQuery,
          );
        }

        // 4) Sonuç var → liste + başlık
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchResultsHeader(spec: spec, count: controller.results.length),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  spec.resultsPaddingH.w,
                  0,
                  spec.resultsPaddingH.w,
                  spec.resultsPaddingV.h,
                ),
                itemCount: controller.results.length,
                itemBuilder: (_, i) => VideoResultCardWidget(
                  spec: spec,
                  video: controller.results[i],
                  query: q,
                  onTap: () => _openVideo(i, q),
                )
                    .animate(delay: (i * 30).ms)
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
              ),
            ),
          ],
        );
      }),
    );
  }
}