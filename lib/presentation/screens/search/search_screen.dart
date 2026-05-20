import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../controllers/search_controller.dart' as sc;
import 'widgets/video_result_card_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final sc.SearchController controller;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    controller = Get.find<sc.SearchController>();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    // Ekran açılınca klavye otomatik aç
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
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
          icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPri(context)),
          onPressed: () => Get.back(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: controller.onQueryChanged,
            onSubmitted: _onSubmit,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: AppTheme.textPri(context), fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Video ara...',
              hintStyle: TextStyle(color: AppTheme.textSec(context), fontSize: 16),
              filled: true,
              fillColor: AppTheme.card(context),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Obx(() => controller.query.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, color: AppTheme.textSec(context), size: 20),
                      onPressed: () {
                        _textController.clear();
                        controller.onQueryChanged('');
                        _focusNode.requestFocus();
                      },
                    )
                  : const SizedBox.shrink()),
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
            ),
          );
        }

        // ── Sonuç yok ───────────────────────────────────────────────────────
        if (controller.results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, color: AppTheme.textSec(context), size: 64),
                const SizedBox(height: 16),
                Text(
                  '"$q" için sonuç bulunamadı',
                  style: TextStyle(color: AppTheme.textSec(context), fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // ── Sonuçlar ────────────────────────────────────────────────────────
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.results.length,
          itemBuilder: (_, i) => VideoResultCardWidget(
            video: controller.results[i],
            query: q,
            onTap: () {
              controller.submitQuery(q); // geçmişe ekle
              Get.toNamed(AppRoutes.player, arguments: controller.results[i]);
            },
          ),
        );
      }),
    );
  }
}

// ── Geçmiş paneli ─────────────────────────────────────────────────────────────

class _HistoryView extends StatelessWidget {
  final sc.SearchController controller;
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
              Icon(Icons.history_rounded, color: AppTheme.textSec(context), size: 56),
              const SizedBox(height: 12),
              Text(
                'Arama geçmişi yok',
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 15),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Son Aramalar',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearHistory,
                  child: Text(
                    'Temizle',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13),
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
                  leading: Icon(Icons.history_rounded, color: AppTheme.textSec(context), size: 20),
                  title: Text(q, style: TextStyle(color: AppTheme.textPri(context), fontSize: 14)),
                  trailing: IconButton(
                    icon: Icon(Icons.close_rounded, color: AppTheme.textSec(context), size: 18),
                    onPressed: () => controller.removeHistory(q),
                  ),
                  onTap: () => onTap(q),
                  dense: true,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}



