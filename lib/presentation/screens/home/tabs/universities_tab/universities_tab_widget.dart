// lib/presentation/screens/home/tabs/universities_tab/universities_tab_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
      ((isTablet ? 110.0 : 96.0) + _cardGap);

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

    // NOT: Bu tab, HomeScreen'in kendi Scaffold'u içinde IndexedStack ile
    // gösteriliyor; ayrı bir Scaffold yerine Container + SafeArea yeterli
    // (gereksiz iç içe Scaffold/Material ağacını önler).
    return Container(
      color: AppTheme.bg(context),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // "ÜniTV / KAMPÜS YAYINI" barı artık HomeScreen'in Scaffold.appBar'ında
            // sabit (bkz. presentation/screens/home/widgets/unitv_app_bar.dart);
            // burada tekrar gösterilmiyor.
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 60),
          _buildEmptyState(context, scheme, isTablet: isTablet),
        ],
      );
    }

    // Alfabetik sıralama → hazır A-Z hızlı indeksli liste.
    // Harf grupları controller tarafından otomatik türetilir; liste kaydırınca
    // aktif harf güncellenir, şeride dokununca/sürükleyince liste kayar.
    if (_currentSort == 'alpha') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(
          bottom: i == filtered.length - 1 ? 0 : _cardGap,
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
  // 2. BAŞLIK + ARAMA — değişmedi (build'den metoda alındı)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTitleAndSearch(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /* Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Üniversiteler',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: isTablet ? 24.sp : 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Türkiye & KKTC akademik yayın ağları',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: isTablet ? 13.sp : 11.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                          width: 6,
                          height: 6,
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
                    SizedBox(width: 5),
                    Text(
                      'Canlı Odalar',
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: isTablet ? 11.sp : 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12), */
          Container(
            height: isTablet ? 46 : 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: scheme.outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: isTablet ? 14 : 12.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Üniversite veya şehir ara...',
                      hintStyle: TextStyle(
                        color: scheme.outline,
                        fontSize: isTablet ? 13.5 : 12,
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
                      size: 18,
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
      final vakifMyoCount = universities
          .where((u) => u.universityType?.toLowerCase() == 'vakif_myo')
          .length;

      final pills = [
        {'key': 'all', 'label': 'Tümü', 'count': universities.length},
        {'key': 'devlet', 'label': 'Devlet', 'count': devletCount},
        {'key': 'vakif', 'label': 'Vakıf', 'count': vakifCount},
        {'key': 'kktc', 'label': 'KKTC', 'count': kktcCount},
        {'key': 'vakif_myo', 'label': 'Vakıf MYO', 'count': vakifMyoCount},
      ];

      return SizedBox(
        height: isTablet ? 38 : 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: pills.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                  horizontal: isTablet ? 14 : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: 0.2)
                      : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
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
                        fontSize: isTablet ? 12.5 : 11.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (count > 0 && p['key'] != 'all') ...[
                      const SizedBox(width: 3),
                      Text(
                        '($count)',
                        style: TextStyle(
                          color:
                              (isSelected
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant)
                                  .withValues(alpha: 0.6),
                          fontSize: isTablet ? 10.5 : 9.5,
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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side flexes so a long count label doesn't push the sort
            // dropdown off-screen at large system font scales.
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.school_rounded, color: scheme.primary, size: 16),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${filtered.length} Üniversite',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: isTablet ? 13.5 : 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentSort == 'alpha')
                Icon(Icons.check_rounded, color: scheme.primary, size: 16),
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentSort == 'followers')
                Icon(Icons.check_rounded, color: scheme.primary, size: 16),
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentSort == 'videos')
                Icon(Icons.check_rounded, color: scheme.primary, size: 16),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sırala: ',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: isTablet ? 11.5 : 10.5,
              ),
            ),
            Text(
              currentSortLabel,
              style: TextStyle(
                color: scheme.primary,
                fontSize: isTablet ? 12.5 : 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.expand_more_rounded,
              color: scheme.onSurfaceVariant,
              size: 16,
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
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            if (isPopuler)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'POPÜLER',
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: isTablet ? 48 : 42,
                            height: isTablet ? 48 : 42,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: hasLogo
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
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
                                      fontSize: isTablet ? 15 : 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: scheme.primary,
                              ),
                              child: Icon(
                                Icons.check,
                                color: scheme.onPrimary,
                                size: 8.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
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
                                      fontSize: isTablet ? 14.5 : 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if ((uni.subscriberCount ?? 0) > 30000) ...[
                                  const SizedBox(width: 3),
                                  Icon(
                                    Icons.verified_rounded,
                                    color: scheme.primary,
                                    size: 13,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _buildMetaText(uni),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: isTablet ? 12 : 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Obx(() {
                        final isFav = controller.favoriteUniversityIds.contains(
                          uni.id,
                        );

                        return GestureDetector(
                          onTap: () => controller.toggleUniversityFavorite(uni),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5.5,
                            ),
                            decoration: BoxDecoration(
                              color: isFav
                                  ? scheme.primary
                                  : scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFav ? Icons.done : Icons.add,
                                  size: 13,
                                  color: isFav
                                      ? scheme.onPrimary
                                      : scheme.primary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isFav ? 'Takipte' : 'Takip Et',
                                  style: TextStyle(
                                    color: isFav
                                        ? scheme.onPrimary
                                        : scheme.primary,
                                    fontSize: 10.5,
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Metrics can't be truncated (numbers lose meaning),
                        // so each one scales down via FittedBox if the card
                        // is too narrow for all three + separators.
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _buildMetricItem(
                              scheme,
                              icon: Icons.group_rounded,
                              value: (uni.subscriberCount ?? 0).compact,
                              label: 'Takipçi',
                            ),
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: scheme.outline.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: _buildMetricItem(
                              scheme,
                              icon: Icons.visibility_rounded,
                              value: (uni.viewCount ?? 0).compact,
                              label: 'İzlenme',
                            ),
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            color: scheme.outline.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: _buildMetricItem(
                              scheme,
                              icon: Icons.movie_rounded,
                              value: '${uni.videoCount ?? 0}',
                              label: 'Video',
                            ),
                          ),
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
        Icon(icon, size: 12, color: scheme.outline),
        const SizedBox(width: 4),
        RichText(
          text: TextSpan(
            text: '$value ',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
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
      }
      if (t == 'vakif_myo') {
        parts.add('Vakıf MYO');
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHigh,
              ),
              child: Icon(
                Icons.school_rounded,
                color: scheme.outline,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sonuç Bulunamadı',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: isTablet ? 17 : 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Arama kriterine uygun üniversite veya kampüs kanalı bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: isTablet ? 13 : 11.5,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _selectedTypeFilter = 'all');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Filtreleri Sıfırla',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 12,
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
      height: 96,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
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
        if (_selectedTypeFilter == 'vakif_myo') return t == 'vakif_myo';
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