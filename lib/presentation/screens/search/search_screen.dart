// lib/presentation/screens/search/search_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/video_model.dart';
import '../../controllers/video_search_controller.dart';
import 'search_layout_spec.dart';
import 'widgets/search_empty_view.dart';
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
    _textController = TextEditingController(text: controller.query.value);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      controller.onQueryChanged(q);
    });
  }

  void _onSelectQuery(String q) {
    _debounce?.cancel();
    _textController.text = q;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: q.length),
    );
    controller.submitQuery(q);
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

  void _openVideo(VideoModel video, String q) {
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // "ÜniTV / KAMPÜS YAYINI" barı artık HomeScreen'in Scaffold.appBar'ında
            // sabit (bkz. presentation/screens/home/widgets/unitv_app_bar.dart);
            // burada tekrar gösterilmiyor.

            // Search Bar Area (Sticky style inside main Column)
            _buildSearchInputBar(context, scheme),

            // Main Body Content
            Expanded(
              child: Obx(() {
                final q = controller.query.value.trim();

                // 1) Query is empty -> Show rich Discovery / History view
                if (q.isEmpty) {
                  return _buildDiscoveryAndHistoryView(context, scheme, spec);
                }

                // 2) Loading state -> Show skeleton
                if (controller.isLoading.value) {
                  return SearchLoadingSkeleton(spec: spec);
                }

                // 3) Empty Results -> Show empty view
                if (controller.results.isEmpty) {
                  return SearchEmptyView(
                    spec: spec,
                    query: q,
                    onClear: _clearQuery,
                  );
                }

                // 4) Results List -> Show count and video result cards
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchResultsHeader(
                      spec: spec,
                      count: controller.results.length,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          spec.resultsPaddingH,
                          0,
                          spec.resultsPaddingH,
                          spec.resultsPaddingV + 20,
                        ),
                        itemCount: controller.results.length,
                        itemBuilder: (_, i) {
                          final video = controller.results[i];
                          return VideoResultCardWidget(
                                spec: spec,
                                video: video,
                                query: q,
                                onTap: () => _openVideo(video, q),
                              )
                              .animate(delay: (i * 30).ms)
                              .fadeIn(duration: 250.ms)
                              .slideY(
                                begin: 0.1,
                                end: 0,
                                curve: Curves.easeOut,
                              );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Sticky Search Input Bar
  Widget _buildSearchInputBar(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF222A3A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _onSubmit(_textController.text.trim());
                }
              },
              icon: Icon(
                Icons.search_rounded,
                color: const Color(0xFF86948A),
                size: 22,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onChanged: _onChanged,
                onSubmitted: _onSubmit,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: const Color(0xFFDBE2F7),
                ),
                decoration: InputDecoration(
                  hintText: 'Video, üniversite veya kanal ara...',
                  hintStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13.5,
                    color: const Color(0xFF86948A),
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Obx(() {
              if (controller.query.value.isNotEmpty ||
                  _textController.text.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF86948A),
                    size: 18,
                  ),
                  onPressed: _clearQuery,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2D3545).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  _showFilterBottomSheet(context);
                },
                icon: Icon(
                  Icons.tune_rounded,
                  color: const Color(0xFF86948A),
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full Discovery & History View (When search query is empty)
  Widget _buildDiscoveryAndHistoryView(
    BuildContext context,
    ColorScheme scheme,
    SearchLayoutSpec spec,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        // 1. Live Pulse Search Ticker / Mini Banner
        _buildLivePulseTicker(context),
        SizedBox(height: 18),

        // 2. Section 1: Son Aramalar (Recent Searches)
        _buildRecentSearchesSection(context),
        SizedBox(height: 22),

        // 3. Section 2: Trend Başlıklar (gerçek arama verisinden — bkz. VideoSearchController.trendingSearches)
        _buildTrendingSection(context),
        SizedBox(height: 22),

        // 4. Section 3: Popüler Üniversiteler (gerçek favori/izlenme verisinden)
        // NOT: Eskiden burada içerik kategorisi (Mühendislik, Tıp, Sanat...)
        // olan "Kategori Keşfi" bölümü vardı; videolarımızda gerçek bir
        // kategori/tag alanı olmadığı için o veriler tamamen uydurmaydı.
        // Onun yerine gerçek verisi olan (universities_list_view) bir bölüm
        // koyduk ve eski sabit "Öne Çıkan Üniversiteler" chip'leriyle
        // birleştirdik.
        _buildPopularUniversitiesSection(context),
        SizedBox(height: 32),
      ],
    );
  }

  /// Live Pulse Search Ticker / Mini Banner
  Widget _buildLivePulseTicker(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4EDEA3).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Glowing Pulse Dot
          Container(
            width: 9,
            height: 9,
            margin: EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF4EDEA3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4EDEA3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: const Color(0xFF86948A),
                ),
                children: const [
                  TextSpan(text: 'Şu an canlı: '),
                  TextSpan(
                    text: '14 Üniversiteden 32 Canlı Yayın',
                    style: TextStyle(
                      color: Color(0xFFDBE2F7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.bolt_rounded, color: Color(0xFF4EDEA3), size: 20),
        ],
      ),
    );
  }

  /// Section 1: Son Aramalar (Recent Searches)
  Widget _buildRecentSearchesSection(BuildContext context) {
    return Obx(() {
      final history = controller.history;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: Color(0xFF4EDEA3),
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Son Aramalar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPri(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (history.isNotEmpty)
                TextButton(
                  onPressed: controller.clearHistory,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Tümünü Temizle',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF7A73),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          if (history.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF141C2B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.manage_search_rounded,
                    color: Color(0xFF86948A),
                    size: 32,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Henüz son arama bulunmuyor.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: const Color(0xFF86948A),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                for (final item in history.take(6))
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onSelectQuery(item),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: Color(0xFF86948A),
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    color: const Color(0xFFDBE2F7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () => controller.removeHistory(item),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF86948A),
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      );
    });
  }

  /// Section 2: Popüler & Trend Başlıklar
  ///
  /// FIX: Bu bölüm eskiden #FormulaStudent, #Tercih2025 gibi uydurma
  /// etiketler + uydurma "1.4B" sayaçları gösteriyordu; bunlara dokununca
  /// gerçek videolarda hiç eşleşme çıkmadığı için "arama aktifleşmiyor"
  /// gibi görünüyordu. Artık `search_logs` tablosuna loglanan gerçek
  /// kullanıcı aramalarından (get_trending_searches RPC) besleniyor.
  Widget _buildTrendingSection(BuildContext context) {
    return Obx(() {
      final trends = controller.trendingSearches;
      final loading = controller.isTrendingLoading.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF45DFA4),
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'Trend Başlıklar',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPri(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (loading)
            SizedBox(
              height: 32,
              child: Row(
                children: List.generate(
                  3,
                  (i) => Flexible(
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF18202F),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (trends.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF141C2B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Henüz yeterli arama verisi yok. Aramalar arttıkça burada gerçek trendler görünecek.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.5,
                  color: const Color(0xFF86948A),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trends.map((item) {
                final term = (item['query'] as String?) ?? '';
                final count = (item['search_count'] as num?)?.toInt() ?? 0;
                if (term.isEmpty) return const SizedBox.shrink();
                return Material(
                  color: const Color(0xFF18202F),
                  borderRadius: BorderRadius.circular(9999),
                  child: InkWell(
                    onTap: () => _onSelectQuery(term),
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFF45DFA4),
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            term,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDBE2F7),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: const Color(0xFF86948A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      );
    });
  }

  /// Section 3: Popüler Üniversiteler
  ///
  /// FIX: Bu bölüm eskiden iki ayrı sahte veri seti içeriyordu:
  ///  1) "Kategori Keşfi" — Mühendislik/Tıp/Sanat gibi sabit kategoriler.
  ///     Videolarımızda gerçek bir kategori/konu alanı olmadığından bunlar
  ///     tamamen uydurmaydı ve dokunulduğunda gerçek içerikle eşleşmiyordu.
  ///  2) "Öne Çıkan Üniversiteler" — ODTÜ/İTÜ/Boğaziçi/Hacettepe sabit 4 chip.
  /// İkisinin yerine, gerçek verisi olan `universities_list_view`'dan
  /// (favori sayısına göre) gelen tek bir "Popüler Üniversiteler" bölümü
  /// kullanılıyor; karta dokunulunca üniversitenin gerçek detay sayfası
  /// açılıyor.
  Widget _buildPopularUniversitiesSection(BuildContext context) {
    return Obx(() {
      final universities = controller.popularUniversities;
      final loading = controller.isPopularUniversitiesLoading.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school_rounded,
                color: Color(0xFF4EDEA3),
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'Popüler Üniversiteler',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPri(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (loading)
            SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (universities.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF141C2B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Üniversiteler yüklenemedi.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.5,
                  color: const Color(0xFF86948A),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: universities.map((uni) {
                  final initials = (uni.name ?? '?')
                      .trim()
                      .split(RegExp(r'\s+'))
                      .where((w) => w.isNotEmpty)
                      .take(2)
                      .map((w) => w[0].toUpperCase())
                      .join();
                  return Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Material(
                      color: const Color(0xFF222A3A),
                      borderRadius: BorderRadius.circular(9999),
                      child: InkWell(
                        onTap: () => Get.toNamed(
                          AppRoutes.universityDetail,
                          arguments: uni,
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(6, 4, 12, 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10382B),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                clipBehavior: Clip.hardEdge,
                                child:
                                    (uni.logoUrl != null &&
                                        uni.logoUrl!.isNotEmpty)
                                    ? ClipOval(
                                        child: Image.network(
                                          uni.logoUrl!,
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Text(
                                            initials,
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF4EDEA3),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        initials,
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF4EDEA3),
                                        ),
                                      ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                uni.name ?? 'Üniversite',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFDBE2F7),
                                ),
                              ),
                              SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF4EDEA3),
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      );
    });
  }

  // FIX: Bu sheet'teki FilterChip'ler daha önce onSelected içinde sadece
  // Navigator.pop(ctx) çağırıyordu — seçim hiçbir yere kaydedilmiyor, arama
  // sonuçları hiç sıralanmıyordu ("çalışmayan buton"). Artık:
  //  - Seçili chip, controller.sortMode'dan okunuyor (Obx ile canlı).
  //  - Bir chip'e dokununca controller.setSortMode(...) çağrılıp sonuç
  //    listesi gerçekten yeniden sıralanıyor/filtreleniyor.
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141C2B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Arama Filtreleri',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDBE2F7),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF86948A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Sıralama',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF86948A),
                ),
              ),
              SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('En Yeniler'),
                      selected:
                          controller.sortMode.value == SearchSortMode.newest,
                      onSelected: (_) {
                        controller.setSortMode(SearchSortMode.newest);
                        Navigator.pop(ctx);
                      },
                      selectedColor: const Color(
                        0xFF4EDEA3,
                      ).withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: Color(0xFF4EDEA3)),
                    ),
                    FilterChip(
                      label: const Text('En Çok İzlenenler'),
                      selected:
                          controller.sortMode.value ==
                          SearchSortMode.mostViewed,
                      onSelected: (_) {
                        controller.setSortMode(SearchSortMode.mostViewed);
                        Navigator.pop(ctx);
                      },
                      selectedColor: const Color(
                        0xFF4EDEA3,
                      ).withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: Color(0xFF4EDEA3)),
                    ),
                    FilterChip(
                      label: const Text('Canlı Yayınlar'),
                      selected:
                          controller.sortMode.value == SearchSortMode.liveOnly,
                      onSelected: (_) {
                        controller.setSortMode(SearchSortMode.liveOnly);
                        Navigator.pop(ctx);
                      },
                      selectedColor: const Color(
                        0xFF4EDEA3,
                      ).withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: Color(0xFF4EDEA3)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}