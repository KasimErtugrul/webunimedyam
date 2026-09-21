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
import 'widgets/universities_alphabet_list.dart';

class UniversitiesTabWidget extends StatefulWidget {
  const UniversitiesTabWidget({super.key});

  @override
  State<UniversitiesTabWidget> createState() => _UniversitiesTabWidgetState();
}

class _UniversitiesTabWidgetState extends State<UniversitiesTabWidget> {
  final HomeController controller = Get.find<HomeController>();
  final TextEditingController _searchController = TextEditingController();

  // Filtre Hapları (Tümü, Devlet, Vakıf, KKTC)
  String _selectedTypeFilter = 'all'; // all, devlet, vakif, kktc

  // Sıralama Seçimi
  String _currentSort = 'alpha'; // alpha | followers | videos

  // ═══════════════════════════════════════════════════════════════════
  // A-Z LİSTESİ ÖLÇÜLERİ
  // ═══════════════════════════════════════════════════════════════════
  // UniversitiesAlphabetList sabit satır yüksekliğiyle (itemExtent) çalışır:
  // bir satır = kart yüksekliği + kartlar arası boşluk.
  // NOT: Kart tasarımını değiştirirseniz bu değeri güncelleyin.
  static const double _cardGap = 8;

  double _alphabetItemExtent(bool isTablet) =>
      ((isTablet ? 110.0 : 96.0) + _cardGap).w;

  /// A-Z listesinin layout spec'i.
  /// ⚠️ GEÇİCİ DEĞERLER: UniversitiesTabLayoutSpec kurucusu farklıysa
  /// (fazla/zorunlu alan, factory vb.) dosyayı gönderin, birebir uyarlayayım.
  /* UniversitiesTabLayoutSpec _buildAlphabetSpec(bool isTablet) {
    return UniversitiesTabLayoutSpec(
      contentHPadding: isTablet ? 24 : 16,
      sidebarWidth: isTablet ? 32 : 26,
      sidebarPillWidth: isTablet ? 26 : 22,
      sidebarActiveFontSize: isTablet ? 13 : 12,
      sidebarInactiveFontSize: isTablet ? 10 : 9,
    );
  } */

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildTopHeader(context, scheme, isTablet: isTablet),
            _buildTitleAndSearch(context, scheme, isTablet: isTablet),
            _buildFilterPills(context, scheme, isTablet: isTablet),
            _buildCounterAndSortRow(context, scheme, isTablet: isTablet),
            // Liste kalan alanı kaplar; UniversitiesAlphabetList kendi
            // ScrollController'ını (ve A-Z şeridini) yönetir.
            Expanded(
              child: RefreshIndicator(
                color: scheme.primary,
                backgroundColor: scheme.surfaceContainerHigh,
                onRefresh: controller.loadUniversitiesAndPlaylists,
                child: Obx(
                  () => _buildListBody(context, scheme, isTablet: isTablet),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // LİSTE GÖVDESİ — yükleme / boş / alfabetik (A-Z şeritli) / diğer sıralama
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildListBody(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    final isLoading = controller.isUniversitiesLoading.value;
    final filtered = _getFilteredUniversities();

    if (isLoading) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        itemCount: 6,
        itemBuilder: (_, _) => _buildCardShimmer(context, scheme),
      );
    }

    if (filtered.isEmpty) {
      // RefreshIndicator'ın çalışabilmesi için kaydırılabilir olmalı.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          SizedBox(height: 60.h),
          _buildEmptyState(context, scheme, isTablet: isTablet),
        ],
      );
    }

    // Alfabetik sıralama → hazır A-Z hızlı indeksli liste.
    // Harf grupları controller tarafından otomatik türetilir; liste kaydırınca
    // aktif harf güncellenir, şeride dokununca/sürükleyince liste kayar.
    if (_currentSort == 'alpha') {
      return Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: UniversitiesAlphabetList(
          //spec: _buildAlphabetSpec(isTablet),
          universities: filtered,
          itemExtent: _alphabetItemExtent(isTablet),
          itemBuilder: (context, index, university) => _buildUniversityCard(
            context,
            scheme,
            university,
            isTablet: isTablet,
          ),
        ),
      );
    }

    // Takipçi / video sayısına göre sıralama → şeritsiz düz liste.
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
      itemCount: filtered.length,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(
          bottom: i == filtered.length - 1 ? 0 : _cardGap.h,
        ),
        child: _buildUniversityCard(
          context,
          scheme,
          filtered[i],
          isTablet: isTablet,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1. ÜST HEADER — değişmedi
  // ═══════════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════════
  // 2. BAŞLIK + ARAMA — değişmedi (build'den metoda alındı)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTitleAndSearch(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
          Container(
            height: isTablet ? 46.h : 42.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: scheme.outline, size: 20.sp),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3. FILTER PILLS — değişmedi (sayaçların RxList'e tepki vermesi için Obx'e alındı)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildFilterPills(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Obx(() {
      final universities = controller.universities;
      final devletCount = universities
          .where((u) => u.universityType?.toLowerCase() == 'devlet')
          .length;
      final vakifCount = universities
          .where(
            (u) =>
                u.universityType?.toLowerCase() == 'ozel' ||
                u.universityType?.toLowerCase() == 'özel' ||
                u.universityType?.toLowerCase() == 'vakif',
          )
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
              onTap: () =>
                  setState(() => _selectedTypeFilter = p['key'] as String),
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
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (count > 0 && p['key'] != 'all') ...[
                      SizedBox(width: 3.w),
                      Text(
                        '($count)',
                        style: TextStyle(
                          color:
                              (isSelected
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
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // 4. SAYAÇ + SIRALAMA SATIRI
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCounterAndSortRow(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Obx(() {
      final filtered = _getFilteredUniversities();
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.school_rounded, color: scheme.primary, size: 16.sp),
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
            _buildSortDropdown(context, scheme, isTablet: isTablet),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // 5. SORT DROPDOWN — değişmedi
  // ═══════════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════════
  // 6. TEK ÜNİVERSİTE KARTI — değişmedi
  // ═══════════════════════════════════════════════════════════════════
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
      onTap: () => Get.toNamed(AppRoutes.universityDetail, arguments: uni),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Stack(
          children: [
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      Obx(() {
                        final isFav = controller.favoriteUniversityIds.contains(
                          uni.id,
                        );

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

  // ═══════════════════════════════════════════════════════════════════
  // 7. EMPTY & SHIMMER — değişmedi
  // ═══════════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════════
  // 8. FİLTRE + SIRALAMA — değişmedi
  // ═══════════════════════════════════════════════════════════════════
  List<UniversityModel> _getFilteredUniversities() {
    var list = controller.universities.toList();

    if (_selectedTypeFilter != 'all') {
      list = list.where((u) {
        final t = (u.universityType ?? '').toLowerCase();
        if (_selectedTypeFilter == 'devlet') return t == 'devlet';
        if (_selectedTypeFilter == 'vakif') {
          return t == 'ozel' || t == 'özel' || t == 'vakif';
        }
        if (_selectedTypeFilter == 'kktc') return t == 'kktc';
        return true;
      }).toList();
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((u) {
        final name = (u.name ?? '').toLowerCase();
        final city = (u.city ?? '').toLowerCase();
        return name.contains(query) || city.contains(query);
      }).toList();
    }

    if (_currentSort == 'alpha') {
      list.sort((a, b) => turkishAlphabetCompare(a.name ?? '', b.name ?? ''));
    } else if (_currentSort == 'followers') {
      list.sort(
        (a, b) => (b.subscriberCount ?? 0).compareTo(a.subscriberCount ?? 0),
      );
    } else if (_currentSort == 'videos') {
      list.sort((a, b) => (b.videoCount ?? 0).compareTo(a.videoCount ?? 0));
    }

    return list;
  }
}
