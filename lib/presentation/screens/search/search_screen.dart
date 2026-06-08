import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../controllers/video_search_controller.dart';
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

  @override
  void initState() {
    super.initState();
    controller = Get.find<VideoSearchController>();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    // Ekran açılınca klavye otomatik aç
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
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: controller.onQueryChanged,
            onSubmitted: _onSubmit,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: AppTheme.textPri(context), fontSize: 16.sp),
            decoration: InputDecoration(
              hintText: 'Video ara...',
              hintStyle: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 16.sp,
              ),
              filled: true,
              fillColor: AppTheme.card(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Obx(
                () => controller.query.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSec(context),
                          size: 20.sp,
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

        // ── Boş sorgu → Geçmiş göster ──────────────────────────────────────
        if (q.trim().isEmpty) {
          return _HistoryView(controller: controller, onTap: _onHistoryTap);
        }

        // ── Yükleniyor ──────────────────────────────────────────────────────
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3.w,
            ),
          );
        }

        // ── Sonuç yok ───────────────────────────────────────────────────────
        if (controller.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  color: AppTheme.textSec(context),
                  size: 64.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  '"$q" için sonuç bulunamadı',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 15.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // ── Sonuçlar ────────────────────────────────────────────────────────
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: controller.results.length,
          itemBuilder: (_, i) => VideoResultCardWidget(
            video: controller.results[i],
            query: q,
            onTap: () {
              controller.submitQuery(q); // geçmişe ekle
              Get.toNamed(AppRoutes.player, arguments: controller.results[i],parameters: {'videoId': controller.results[i].videoId},);
            },
          ),
        );
      }),
    );
  }
}

// ── Geçmiş paneli ─────────────────────────────────────────────────────────────

class _HistoryView extends StatelessWidget {
  final VideoSearchController controller;
  final void Function(String) onTap;

  const _HistoryView({required this.controller, required this.onTap});

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
                size: 56.sp,
              ),
              SizedBox(height: 12.h),
              Text(
                'Arama geçmişi yok',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 15.sp,
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
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Aramalar',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearHistory,
                  style: TextButton.styleFrom(
                    minimumSize: Size(60.w, 36.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                  ),
                  child: Text(
                    'Temizle',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13.sp,
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
                    size: 20.sp,
                  ),
                  title: Text(
                    q,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 14.sp,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSec(context),
                      size: 18.sp,
                    ),
                    onPressed: () => controller.removeHistory(q),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 32.w,
                      minHeight: 32.h,
                    ),
                  ),
                  onTap: () => onTap(q),
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
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
