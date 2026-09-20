// lib/presentation/screens/home/tabs/universities_tab/universities_tab_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../app/utils/turkish_alphabet_sort_util.dart';
import '../../../../../core/responsive.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../data/models/university_model.dart';
import '../../../../controllers/home/home_controller.dart';

class UniversitiesTabWidget extends StatefulWidget {
  const UniversitiesTabWidget({super.key});

  @override
  State<UniversitiesTabWidget> createState() => _UniversitiesTabWidgetState();
}

class _UniversitiesTabWidgetState extends State<UniversitiesTabWidget> {
  final HomeController controller = Get.find<HomeController>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Filtre Hapları (Tümü, Devlet, Vakıf, KKTC)
  String _selectedTypeFilter = 'all'; // all, devlet, vakif, kktc

  // Sıralama Seçimi (alpha: Alfabetik A-Z, followers: Takipçi Sayısı, videos: Video Sayısı)
  String _currentSort = 'alpha';

  // HUD Harf Göstergesi için State
  String _activeHUDLetter = '';
  bool _showHUD = false;

  // Harf index anahtarları (A-Z zıplama için)
  final Map<String, GlobalKey> _letterKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.universities.isEmpty) {
        controller.loadUniversitiesAndPlaylists();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _triggerHUD(String letter) {
    setState(() {
      _activeHUDLetter = letter;
      _showHUD = true;
    });

    // Harfe Scroll Et
    final key = _letterKeys[letter];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _showHUD = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            RefreshIndicator(
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainerHigh,
              onRefresh: controller.loadUniversitiesAndPlaylists,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // ── 1. ÜST HEADER BAR (Logo, Canlı Odalar, Bildirim, Avatar) ──
                  SliverToBoxAdapter(
                    child: _buildTopHeader(context, scheme, isTablet: isTablet),
                  ),

                  // ── 2. BAŞLIK, CANLI ODALAR VE ARAMA KUTUSU ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Başlık ve Canlı Odalar Rozeti
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Üniversiteler',
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: isTablet ? 24.sp : 20.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    'Türkiye & KKTC akademik yayın ağları',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: isTablet ? 13.sp : 11.5.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6.w,
                                      height: 6.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: scheme.primary,
                                      ),
                                    )
                                        .animate(onPlay: (c) => c.repeat(reverse: true))
                                        .scale(
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1.4, 1.4),
                                          duration: 800.ms,
                                        ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      'Canlı Odalar',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontSize: isTablet ? 11.sp : 9.5.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Arama Giriş Kutusu (Temizle Butonlu)
                          Container(
                            height: isTablet ? 46.h : 42.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: scheme.outline,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: isTablet ? 14.sp : 12.5.sp,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Üniversite veya şehir ara...',
                                      hintStyle: TextStyle(
                                        color: scheme.outline,
                                        fontSize: isTablet ? 13.5.sp : 12.sp,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.cancel_rounded,
                                      color: scheme.outline,
                                      size: 18.sp,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 3. YATAY FİLTRE HAPLARI (Tümü, Devlet, Vakıf, KKTC) ──
                  SliverToBoxAdapter(
                    child: _buildFilterPills(context, scheme, isTablet: isTablet),
                  ),

                  // ── 4. SAYAÇ VE SIRALAMA MENÜSÜ SATIRI ──
                  SliverToBoxAdapter(
                    child: Obx(() {
                      final filtered = _getFilteredUniversities();
                      return Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  color: scheme.primary,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  '${filtered.length} Üniversite',
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: isTablet ? 13.5.sp : 12.5.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),

                            // Sırala Dropdown Butonu
                            _buildSortDropdown(context, scheme, isTablet: isTablet),
                          ],
                        ),
                      );
                    }),
                  ),

                  // ── 5. ÜNİVERSİTE KARTLARI LİSTESİ ──
                  Obx(() {
                    final isLoading = controller.isUniversitiesLoading.value;
                    final filtered = _getFilteredUniversities();

                    if (isLoading) {
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 38.w, 24.h),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, _) => _buildCardShimmer(context, scheme),
                            childCount: 6,
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(context, scheme, isTablet: isTablet),
                      );
                    }

                    return _buildUniversityStream(context, scheme, filtered, isTablet: isTablet);
                  }),

                  // Alt güvenli boşluk
                  SliverToBoxAdapter(
                    child: SizedBox(height: 32.h),
                  ),
                ],
              ),
            ),

            // ── SAĞ SABİT A-Z HIZLI İNDEKS ŞERİDİ ──
            Positioned(
              right: 2.w,
              top: 130.h,
              bottom: 40.h,
              child: _buildAlphabetIndexSidebar(scheme, isTablet: isTablet),
            ),

            // ── MICRO-TOAST / HUD HARF GÖSTERGESİ ──
            if (_showHUD)
              Center(
                child: Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _activeHUDLetter,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ).animate().scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 150.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. ÜST HEADER (Tasarım: h-16, logo, sensör canlı, bildirim, avatar)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopHeader(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, topInset + 8.h, 16.w, 8.h),
      color: AppTheme.bg(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol: Logo & Marka
          Row(
            children: [
              Container(
                width: isTablet ? 42.w : 36.w,
                height: isTablet ? 42.w : 36.w,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  color: scheme.primary,
                  size: isTablet ? 26.sp : 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Üni',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: isTablet ? 20.sp : 17.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'TV',
                          style: TextStyle(color: scheme.primary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'KAMPÜS YAYINI',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: isTablet ? 11.sp : 9.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Sağ: Aksiyon İkonları
          Row(
            children: [
              IconButton(
                tooltip: 'Canlı Yayınlar',
                icon: const Icon(Icons.sensors_rounded),
                color: scheme.onSurfaceVariant,
                iconSize: isTablet ? 26.sp : 22.sp,
                onPressed: () => Get.toNamed(AppRoutes.radio),
              ),
              IconButton(
                tooltip: 'Bildirimler',
                icon: const Icon(Icons.notifications_outlined),
                color: scheme.onSurfaceVariant,
                iconSize: isTablet ? 26.sp : 22.sp,
                onPressed: () => Get.toNamed(AppRoutes.notifications),
              ),
              SizedBox(width: 4.w),
              GestureDetector(
                onTap: () => controller.changeTab(4),
                child: CircleAvatar(
                  radius: isTablet ? 18.r : 15.r,
                  backgroundColor: scheme.primary,
                  child: Icon(
                    Icons.person_rounded,
                    color: scheme.onPrimary,
                    size: isTablet ? 20.sp : 17.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. FILTER PILLS (Tümü, Devlet, Vakıf, KKTC)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterPills(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    final universities = controller.universities;
    final devletCount = universities
        .where((u) => u.universityType?.toLowerCase() == 'devlet')
        .length;
    final vakifCount = universities
        .where((u) =>
            u.universityType?.toLowerCase() == 'ozel' ||
            u.universityType?.toLowerCase() == 'özel' ||
            u.universityType?.toLowerCase() == 'vakif')
        .length;
    final kktcCount = universities
        .where((u) => u.universityType?.toLowerCase() == 'kktc')
        .length;

    final pills = [
      {'key': 'all', 'label': 'Tümü', 'count': universities.length},
      {'key': 'devlet', 'label': 'Devlet', 'count': devletCount},
      {'key': 'vakif', 'label': 'Vakıf', 'count': vakifCount},
      {'key': 'kktc', 'label': 'KKTC', 'count': kktcCount},
    ];

    return SizedBox(
      height: isTablet ? 38.h : 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: pills.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final p = pills[index];
          final isSelected = _selectedTypeFilter == p['key'];
          final count = p['count'] as int;

          return GestureDetector(
            onTap: () => setState(() => _selectedTypeFilter = p['key'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 14.w : 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary.withValues(alpha: 0.2)
                    : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: 0.4)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p['label'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontSize: isTablet ? 12.5.sp : 11.5.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (count > 0 && p['key'] != 'all') ...[
                    SizedBox(width: 3.w),
                    Text(
                      '($count)',
                      style: TextStyle(
                        color: (isSelected
                                ? scheme.primary
                                : scheme.onSurfaceVariant)
                            .withValues(alpha: 0.6),
                        fontSize: isTablet ? 10.5.sp : 9.5.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SORT DROPDOWN MENÜ
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSortDropdown(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    String currentSortLabel = 'Alfabetik';
    if (_currentSort == 'followers') currentSortLabel = 'Takipçi';
    if (_currentSort == 'videos') currentSortLabel = 'Video Sayısı';

    return PopupMenuButton<String>(
      onSelected: (val) => setState(() => _currentSort = val),
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 'alpha',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alfabetik (A-Z)',
                style: TextStyle(
                  color: _currentSort == 'alpha'
                      ? scheme.primary
                      : scheme.onSurface,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentSort == 'alpha')
                Icon(Icons.check_rounded, color: scheme.primary, size: 16.sp),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'followers',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Takipçi Sayısı',
                style: TextStyle(
                  color: _currentSort == 'followers'
                      ? scheme.primary
                      : scheme.onSurface,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentSort == 'followers')
                Icon(Icons.check_rounded, color: scheme.primary, size: 16.sp),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'videos',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Video Sayısı',
                style: TextStyle(
                  color: _currentSort == 'videos'
                      ? scheme.primary
                      : scheme.onSurface,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentSort == 'videos')
                Icon(Icons.check_rounded, color: scheme.primary, size: 16.sp),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.5.h),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sırala: ',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: isTablet ? 11.5.sp : 10.5.sp,
              ),
            ),
            Text(
              currentSortLabel,
              style: TextStyle(
                color: scheme.primary,
                fontSize: isTablet ? 12.5.sp : 11.5.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.expand_more_rounded,
              color: scheme.onSurfaceVariant,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. ALPHABET INDEX SIDEBAR (A-Z)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAlphabetIndexSidebar(
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    const letters = [
      'A', 'B', 'C', 'Ç', 'D', 'E', 'F', 'G', 'H',
      'İ', 'K', 'M', 'O', 'P', 'S', 'T', 'Y', 'Z'
    ];

    return Container(
      width: 24.w,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: letters.map((l) {
          final hasKey = _letterKeys.containsKey(l);
          return GestureDetector(
            onTap: () => _triggerHUD(l),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                l,
                style: TextStyle(
                  color: hasKey ? scheme.primary : scheme.outline.withValues(alpha: 0.6),
                  fontSize: isTablet ? 11.sp : 9.sp,
                  fontWeight: hasKey ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. UNIVERSITY CARDS STREAM & SECTION ANCHORS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildUniversityStream(
    BuildContext context,
    ColorScheme scheme,
    List<UniversityModel> list, {
    required bool isTablet,
  }) {
    _letterKeys.clear();

    // Alfabetik sıralıysa harf başlıklarıyla grupla
    if (_currentSort == 'alpha') {
      final groups = <String, List<UniversityModel>>{};
      for (final u in list) {
        final initial = getTurkishInitialTag(u.name);
        groups.putIfAbsent(initial, () => []).add(u);
      }

      final keys = groups.keys.toList()
        ..sort((a, b) => turkishAlphabetCompare(a, b));

      return SliverPadding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 32.w, 24.h),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final letter = keys[index];
              final items = groups[letter]!;
              final groupKey = GlobalKey();
              _letterKeys[letter] = groupKey;

              return Column(
                key: groupKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Harf Başlığı Anchor Çizgisi
                  Padding(
                    padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
                    child: Row(
                      children: [
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bu harfe ait üniversite kartları
                  for (final uni in items) ...[
                    _buildUniversityCard(context, scheme, uni, isTablet: isTablet),
                    SizedBox(height: 8.h),
                  ],
                ],
              );
            },
            childCount: keys.length,
          ),
        ),
      );
    }

    // Takipçi veya video sayısına göre sıralıysa direkt düz liste
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 32.w, 24.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _buildUniversityCard(
                context,
                scheme,
                list[index],
                isTablet: isTablet,
              ),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. SINGLE UNIVERSITY CARD (Tasarım: Logo, Başlık, Meta, Metrikler, Takip)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildUniversityCard(
    BuildContext context,
    ColorScheme scheme,
    UniversityModel uni, {
    required bool isTablet,
  }) {
    final initials = (uni.name ?? 'ÜN').length > 3
        ? (uni.name ?? 'ÜN').substring(0, 3).toUpperCase()
        : (uni.name ?? 'ÜN').toUpperCase();

    final hasLogo = uni.logoUrl != null && uni.logoUrl!.isNotEmpty;
    final isPopuler = (uni.subscriberCount ?? 0) > 50000;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.universityDetail,
        arguments: uni,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Stack(
          children: [
            // Popüler Şeridi (Ribbon)
            if (isPopuler)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14.r),
                      bottomLeft: Radius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'POPÜLER',
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                children: [
                  // Üst Satır: Logo + İsim + Takip Butonu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: isTablet ? 48.w : 42.w,
                            height: isTablet ? 48.w : 42.w,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            alignment: Alignment.center,
                            child: hasLogo
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: CachedNetworkImage(
                                      imageUrl: uni.logoUrl!,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : Text(
                                    initials,
                                    style: TextStyle(
                                      color: scheme.primary,
                                      fontSize: isTablet ? 15.sp : 13.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: -2.h,
                            right: -2.w,
                            child: Container(
                              width: 13.w,
                              height: 13.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scheme.primary,
                              ),
                              child: Icon(
                                Icons.check,
                                color: scheme.onPrimary,
                                size: 8.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 10.w),

                      // İsim & Meta Satırı
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    uni.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: isTablet ? 14.5.sp : 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if ((uni.subscriberCount ?? 0) > 30000) ...[
                                  SizedBox(width: 3.w),
                                  Icon(
                                    Icons.verified_rounded,
                                    color: scheme.primary,
                                    size: 13.sp,
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _buildMetaText(uni),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: isTablet ? 12.sp : 10.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 6.w),

                      // Takip Et / Takipte Butonu
                      Obx(() {
                        final isFav =
                            controller.favoriteUniversityIds.contains(uni.id);

                        return GestureDetector(
                          onTap: () => controller.toggleUniversityFavorite(uni),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9.w,
                              vertical: 5.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: isFav
                                  ? scheme.primary
                                  : scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFav ? Icons.done : Icons.add,
                                  size: 13.sp,
                                  color: isFav
                                      ? scheme.onPrimary
                                      : scheme.primary,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  isFav ? 'Takipte' : 'Takip Et',
                                  style: TextStyle(
                                    color: isFav
                                        ? scheme.onPrimary
                                        : scheme.primary,
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Alt Metrikler Satırı (Takipçi · İzlenme · Video)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricItem(
                          scheme,
                          icon: Icons.group_rounded,
                          value: (uni.subscriberCount ?? 0).compact,
                          label: 'Takipçi',
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: scheme.outline.withValues(alpha: 0.5),
                            fontSize: 10.sp,
                          ),
                        ),
                        _buildMetricItem(
                          scheme,
                          icon: Icons.visibility_rounded,
                          value: (uni.viewCount ?? 0).compact,
                          label: 'İzlenme',
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: scheme.outline.withValues(alpha: 0.5),
                            fontSize: 10.sp,
                          ),
                        ),
                        _buildMetricItem(
                          scheme,
                          icon: Icons.movie_rounded,
                          value: '${uni.videoCount ?? 0}',
                          label: 'Video',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    ColorScheme scheme, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: scheme.outline),
        SizedBox(width: 4.w),
        RichText(
          text: TextSpan(
            text: '$value ',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildMetaText(UniversityModel uni) {
    final parts = <String>[];
    if (uni.city != null && uni.city!.isNotEmpty) {
      parts.add(uni.city!);
    }
    if (uni.foundedYear != null) {
      parts.add('${uni.foundedYear}');
    }
    if (uni.universityType != null && uni.universityType!.isNotEmpty) {
      final t = uni.universityType!.toLowerCase();
      if (t == 'devlet') {
        parts.add('Devlet');
      } else if (t == 'ozel' || t == 'özel' || t == 'vakif') {
        parts.add('Vakıf');
      } else if (t == 'kktc') {
        parts.add('KKTC');
      } else {
        parts.add(uni.universityType!);
      }
    }
    return parts.isEmpty ? 'Akademik Kanal' : parts.join(' · ');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. EMPTY & SHIMMER STATES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHigh,
              ),
              child: Icon(
                Icons.school_rounded,
                color: scheme.outline,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Sonuç Bulunamadı',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: isTablet ? 17.sp : 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Arama kriterine uygun üniversite veya kampüs kanalı bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: isTablet ? 13.sp : 11.5.sp,
              ),
            ),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _selectedTypeFilter = 'all');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Filtreleri Sıfırla',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardShimmer(BuildContext context, ColorScheme scheme) {
    return Container(
      height: 96.h,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. FİLTRE VE SIRALAMA UYGULAMA METODU
  // ═══════════════════════════════════════════════════════════════════════════
  List<UniversityModel> _getFilteredUniversities() {
    var list = controller.universities.toList();

    // 1) Tip Filtresi
    if (_selectedTypeFilter != 'all') {
      list = list.where((u) {
        final t = (u.universityType ?? '').toLowerCase();
        if (_selectedTypeFilter == 'devlet') return t == 'devlet';
        if (_selectedTypeFilter == 'vakif') return t == 'ozel' || t == 'özel' || t == 'vakif';
        if (_selectedTypeFilter == 'kktc') return t == 'kktc';
        return true;
      }).toList();
    }

    // 2) Arama Kutusu Filtresi
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((u) {
        final name = (u.name ?? '').toLowerCase();
        final city = (u.city ?? '').toLowerCase();
        return name.contains(query) || city.contains(query);
      }).toList();
    }

    // 3) Sıralama
    if (_currentSort == 'alpha') {
      list.sort((a, b) => turkishAlphabetCompare(a.name ?? '', b.name ?? ''));
    } else if (_currentSort == 'followers') {
      list.sort((a, b) => (b.subscriberCount ?? 0).compareTo(a.subscriberCount ?? 0));
    } else if (_currentSort == 'videos') {
      list.sort((a, b) => (b.videoCount ?? 0).compareTo(a.videoCount ?? 0));
    }

    return list;
  }
}
