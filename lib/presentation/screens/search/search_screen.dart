// lib/presentation/screens/search/search_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/video_model.dart';
import '../../controllers/home/home_controller.dart';
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

  // Trend tag items from the Stitch design
  final List<Map<String, String>> _trendTags = const [
    {'emoji': '🔥', 'tag': '#FormulaStudent', 'count': '1.4B'},
    {'emoji': '🎓', 'tag': '#Tercih2025', 'count': '3.8B'},
    {'emoji': '⚡', 'tag': '#Teknofest', 'count': '2.1B'},
    {'emoji': '🧪', 'tag': '#KuantumFizik', 'count': '890'},
    {'emoji': '🏛', 'tag': '#HacettepeTip', 'count': '1.9B'},
  ];

  // University Spotlight Chips from design
  final List<Map<String, dynamic>> _spotlightUniversities = const [
    {
      'code': 'ODTÜ',
      'name': 'Orta Doğu Teknik',
      'color': Color(0xFF4EDEA3),
      'bgColor': Color(0xFF10382B),
    },
    {
      'code': 'İTÜ',
      'name': 'İstanbul Teknik',
      'color': Color(0xFF45DFA4),
      'bgColor': Color(0xFF0F3A2E),
    },
    {
      'code': 'BOUN',
      'name': 'Boğaziçi',
      'color': Color(0xFF6FFBBE),
      'bgColor': Color(0xFF133F31),
    },
    {
      'code': 'HACETTEPE',
      'name': 'Hacettepe',
      'color': Color(0xFFFFB3AD),
      'bgColor': Color(0xFF3F1918),
    },
  ];

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
            // Top App Bar Header (Brand & Icons)
            _buildTopAppBar(context, scheme),

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
                          spec.resultsPaddingH.w,
                          0,
                          spec.resultsPaddingH.w,
                          spec.resultsPaddingV.h + 20.h,
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
                              .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
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

  /// Top App Bar matching the HTML design (ÜniTV logo + Canlı Yayın, Bildirim, Profil)
  Widget _buildTopAppBar(BuildContext context, ColorScheme scheme) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Logo & Subtitle
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Color(0xFF4EDEA3),
                  size: 22,
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPri(context),
                      ),
                      children: const [
                        TextSpan(text: 'Üni'),
                        TextSpan(
                          text: 'TV',
                          style: TextStyle(color: Color(0xFF4EDEA3)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'KAMPÜS YAYINI',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),

          // Action Icons
          IconButton(
            onPressed: () {
              final homeCtrl = Get.find<HomeController>();
              homeCtrl.changeTab(1);
            },
            icon: Icon(
              Icons.sensors_rounded,
              color: AppTheme.textSec(context),
              size: 22.sp,
            ),
            tooltip: 'Canlı Yayınlar',
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.textSec(context),
              size: 22.sp,
            ),
            tooltip: 'Bildirimler',
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {
              final homeCtrl = Get.find<HomeController>();
              homeCtrl.changeTab(4);
            },
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: const BoxDecoration(
                color: Color(0xFF4EDEA3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF003824),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Search Input Bar
  Widget _buildSearchInputBar(BuildContext context, ColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0xFF222A3A),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                size: 22.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onChanged: _onChanged,
                onSubmitted: _onSubmit,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14.sp,
                  color: const Color(0xFFDBE2F7),
                ),
                decoration: InputDecoration(
                  hintText: 'Video, üniversite veya kanal ara...',
                  hintStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13.5.sp,
                    color: const Color(0xFF86948A),
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Obx(() {
              if (controller.query.value.isNotEmpty || _textController.text.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF86948A),
                    size: 18.sp,
                  ),
                  onPressed: _clearQuery,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                );
              }
              return const SizedBox.shrink();
            }),
            Container(
              width: 32.w,
              height: 32.w,
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  // Mic search action
                },
                icon: Icon(
                  Icons.mic_rounded,
                  color: const Color(0xFF86948A),
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            SizedBox(width: 4.w),
            Container(
              width: 32.w,
              height: 32.w,
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
                  size: 18.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        // 1. Live Pulse Search Ticker / Mini Banner
        _buildLivePulseTicker(context),
        SizedBox(height: 18.h),

        // 2. Section 1: Son Aramalar (Recent Searches)
        _buildRecentSearchesSection(context),
        SizedBox(height: 22.h),

        // 3. Section 2: Trend Başlıklar (Trending Topics)
        _buildTrendingSection(context),
        SizedBox(height: 22.h),

        // 4. Section 3: Kategori Keşfi (Bento Grid)
        _buildCategoryBentoGrid(context),
        SizedBox(height: 22.h),

        // 5. Section 4: Öne Çıkan Üniversiteler (Spotlight Chips)
        _buildSpotlightUniversitiesSection(context),
        SizedBox(height: 32.h),
      ],
    );
  }

  /// Live Pulse Search Ticker / Mini Banner
  Widget _buildLivePulseTicker(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2B),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFF4EDEA3).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Glowing Pulse Dot
          Container(
            width: 9.w,
            height: 9.w,
            margin: EdgeInsets.only(right: 8.w),
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
                  fontSize: 12.sp,
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
          const Icon(
            Icons.bolt_rounded,
            color: Color(0xFF4EDEA3),
            size: 20,
          ),
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
              Row(
                children: [
                  const Icon(
                    Icons.history_rounded,
                    color: Color(0xFF4EDEA3),
                    size: 20,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Son Aramalar',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPri(context),
                    ),
                  ),
                ],
              ),
              if (history.isNotEmpty)
                TextButton(
                  onPressed: controller.clearHistory,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Tümünü Temizle',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF7A73),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          if (history.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF141C2B),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.manage_search_rounded,
                    color: Color(0xFF86948A),
                    size: 32,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Henüz son arama bulunmuyor.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12.sp,
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
                    margin: EdgeInsets.only(bottom: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onSelectQuery(item),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 8.h,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: Color(0xFF86948A),
                                size: 18,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14.sp,
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
  Widget _buildTrendingSection(BuildContext context) {
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
            SizedBox(width: 6.w),
            Text(
              'Trend Başlıklar',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPri(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _trendTags.map((item) {
            return Material(
              color: const Color(0xFF18202F),
              borderRadius: BorderRadius.circular(9999.r),
              child: InkWell(
                onTap: () => _onSelectQuery(item['tag']!),
                borderRadius: BorderRadius.circular(9999.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['emoji']!,
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        item['tag']!,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDBE2F7),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        item['count']!,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11.sp,
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
  }

  /// Section 3: Kategori Keşfi (Bento Grid)
  Widget _buildCategoryBentoGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.category_rounded,
                  color: Color(0xFF4EDEA3),
                  size: 20,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Kategori Keşfi',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPri(context),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                final homeCtrl = Get.find<HomeController>();
                homeCtrl.changeTab(1); // switch to Keşfet
              },
              child: Row(
                children: [
                  Text(
                    'Tümü',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4EDEA3),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF4EDEA3),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Grid Layout: 1 Full-width banner + 4 Grid tiles (2x2)
        _buildBentoHeroCard(
          title: 'Mühendislik & Teknoloji',
          subtitle: 'Robotik, kodlama, yapay zekâ',
          icon: Icons.precision_manufacturing_rounded,
          largeIcon: Icons.memory_rounded,
          onTap: () => _onSelectQuery('Mühendislik'),
        ),
        SizedBox(height: 10.h),

        // 2x2 Grid for the other 4 categories
        Row(
          children: [
            Expanded(
              child: _buildBentoSquareCard(
                title: 'Tıp & Sağlık',
                subtitle: 'Klinik & Anatomi',
                icon: Icons.monitor_heart_rounded,
                iconColor: const Color(0xFFFF7A73),
                iconBgColor: const Color(0xFFFF7A73).withValues(alpha: 0.15),
                onTap: () => _onSelectQuery('Tıp'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildBentoSquareCard(
                title: 'Sosyal Bilimler',
                subtitle: 'Hukuk & İktisat',
                icon: Icons.public_rounded,
                iconColor: const Color(0xFF45DFA4),
                iconBgColor: const Color(0xFF45DFA4).withValues(alpha: 0.15),
                onTap: () => _onSelectQuery('Sosyal'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildBentoSquareCard(
                title: 'Sanat & Tasarım',
                subtitle: 'Mimarlık & Müzik',
                icon: Icons.palette_rounded,
                iconColor: const Color(0xFF4EDEA3),
                iconBgColor: const Color(0xFF4EDEA3).withValues(alpha: 0.15),
                onTap: () => _onSelectQuery('Sanat'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildBentoSquareCard(
                title: 'Kampüs Yaşamı',
                subtitle: 'Kulüpler & Festivaller',
                icon: Icons.celebration_rounded,
                iconColor: const Color(0xFF68FCBF),
                iconBgColor: const Color(0xFF68FCBF).withValues(alpha: 0.15),
                onTap: () => _onSelectQuery('Kampüs'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Full-width Bento Hero Card
  Widget _buildBentoHeroCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required IconData largeIcon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF18202F),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF4EDEA3),
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDBE2F7),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12.sp,
                        color: const Color(0xFF86948A),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 54.w,
                height: 54.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF4EDEA3).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  largeIcon,
                  color: const Color(0xFF4EDEA3),
                  size: 32.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2x2 Bento Square Card
  Widget _buildBentoSquareCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF18202F),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          height: 110.h,
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDBE2F7),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10.5.sp,
                      color: const Color(0xFF86948A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section 4: Öne Çıkan Üniversiteler (Spotlight Chips)
  Widget _buildSpotlightUniversitiesSection(BuildContext context) {
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
            SizedBox(width: 6.w),
            Text(
              'Öne Çıkan Üniversiteler',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPri(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: _spotlightUniversities.map((uni) {
              return Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: Material(
                  color: const Color(0xFF222A3A),
                  borderRadius: BorderRadius.circular(9999.r),
                  child: InkWell(
                    onTap: () => _onSelectQuery(uni['name'] as String),
                    borderRadius: BorderRadius.circular(9999.r),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(6.w, 4.h, 12.w, 4.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: uni['bgColor'] as Color,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              (uni['code'] as String).substring(
                                0,
                                (uni['code'] as String).length > 4 ? 4 : (uni['code'] as String).length,
                              ),
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: uni['color'] as Color,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            uni['name'] as String,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDBE2F7),
                            ),
                          ),
                          SizedBox(width: 4.w),
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
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141C2B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(20.w),
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
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDBE2F7),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF86948A)),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Sıralama',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF86948A),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  FilterChip(
                    label: const Text('En Yeniler'),
                    selected: true,
                    onSelected: (_) => Navigator.pop(ctx),
                    selectedColor: const Color(0xFF4EDEA3).withValues(alpha: 0.2),
                    labelStyle: const TextStyle(color: Color(0xFF4EDEA3)),
                  ),
                  FilterChip(
                    label: const Text('En Çok İzlenenler'),
                    selected: false,
                    onSelected: (_) => Navigator.pop(ctx),
                  ),
                  FilterChip(
                    label: const Text('Canlı Yayınlar'),
                    selected: false,
                    onSelected: (_) => Navigator.pop(ctx),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }
}