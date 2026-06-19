// lib/presentation/screens/home/widgets/tabs/universities_tab/universities_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../app/utils/university_sort_util.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../controllers/home_controller.dart';
import '../../../../controllers/university_alphabet_controller.dart';
import '../../../../controllers/university_sort_controller.dart';
import 'widgets/university_card_shimmer_widget.dart';
import 'widgets/university_list_card_widget.dart';

class UniversitiesTabWidget extends StatelessWidget {
  const UniversitiesTabWidget({super.key});

  /// Sıralama kriteri sadece "İsim" ise veya hiçbir kriter seçilmediyse
  /// A-Z sidebar'ını göster. Diğer durumlarda normal liste göster.
  bool _isAlphabetSortActive(UniversitySortController sortController) {
    final activeSorts = sortController.activeSorts;
    if (activeSorts.isEmpty) return true;
    if (activeSorts.length == 1 &&
        activeSorts.first.criteria == SortCriteria.name)
      return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final sortController = Get.find<UniversitySortController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.card(context),
          displacement: 40.h,
          onRefresh: homeController.loadUniversitiesAndPlaylists,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── AppBar ───────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppTheme.bg(context),
                automaticallyImplyLeading: false,
                toolbarHeight: 64.h,
                title: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Üniversiteler',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Arama Çubuğu ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppTheme.isDark(context)
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: TextField(
                      controller: sortController.searchController,
                      onChanged: sortController.updateSearchQuery,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textPri(context),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.textSec(context),
                          size: 22.sp,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(
                              () => sortController.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: AppTheme.textSec(context),
                                        size: 20.sp,
                                      ),
                                      onPressed: sortController.clearSearch,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        hintText: 'Üniversite veya şehir ara...',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSec(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Aktif Sıralama Chip'leri ─────────────────────────────
              Obx(() {
                if (sortController.activeSorts.isEmpty)
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: sortController.activeSorts.map((sort) {
                        return Chip(
                          avatar: Icon(
                            sort.icon,
                            size: 14.sp,
                            color: AppTheme.primaryColor,
                          ),
                          label: Text(
                            sort.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close_rounded,
                            size: 16.sp,
                            color: AppTheme.primaryColor,
                          ),
                          onDeleted: () =>
                              sortController.removeSort(sort.criteria),
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 0,
                          ),
                          labelPadding: EdgeInsets.only(left: 2.w),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),

              // ── İstatistik + Shimmer + Boş Durum + Liste ─────────────
              // Tek Obx: applySortAndFilter artık build başına 1 kez
              // çalışıyor (önceden 4 ayrı Obx'te 4 kez tekrar hesaplanıyordu).
              Obx(() {
                final isLoading = homeController.isUniversitiesLoading.value;
                final universities = sortController.applySortAndFilter(
                  homeController.universities,
                );

                return SliverMainAxisGroup(
                  slivers: [
                    // ── İstatistik Satırı ───────────────────────────
                    if (!isLoading && universities.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
                          child: Row(
                            children: [
                              Text(
                                '${universities.length} üniversite',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppTheme.textSec(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _showSortBottomSheet(context),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_rounded,
                                      size: 18.sp,
                                      color: AppTheme.primaryColor,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Sırala',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Shimmer Yükleniyor ───────────────────────────
                    if (isLoading)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 14.h),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, __) => const UniversityCardShimmerWidget(),
                            childCount: 6,
                          ),
                        ),
                      ),

                    // ── Boş Durum ─────────────────────────────────────
                    if (!isLoading && universities.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    color: AppTheme.card(context),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: 40.sp,
                                    color: AppTheme.textSec(context),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  'Üniversite bulunamadı',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPri(context),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  sortController.searchQuery.value.isNotEmpty
                                      ? '"${sortController.searchQuery.value}" için sonuç bulunamadı.'
                                      : 'Şu anda listelenecek üniversite mevcut değil.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.textSec(context),
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                SizedBox(
                                  height: 44.h,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        sortController
                                            .searchQuery
                                            .value
                                            .isNotEmpty
                                        ? sortController.clearSearch
                                        : homeController
                                              .loadUniversitiesAndPlaylists,
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      size: 20.sp,
                                    ),
                                    label: Text(
                                      'Tekrar Dene',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // ── Üniversite Listesi (Dinamik: A-Z veya Normal) ──
                    if (!isLoading && universities.isNotEmpty)
                      _buildUniversitiesSliver(
                        context,
                        sortController,
                        universities,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Üniversite Listesi Sliver'ı (Dinamik: A-Z veya Normal Liste) ───────
  // Artık dışarıdan zaten filtrelenmiş/sıralanmış liste alıyor, kendi
  // başına applySortAndFilter çağırmıyor.
  Widget _buildUniversitiesSliver(
    BuildContext context,
    UniversitySortController sortController,
    List<UniversityModel> universities,
  ) {
    // Eğer sıralama "İsim" dışında bir şeye göre ayarlanmışsa A-Z sidebar'ını gizle
    if (!_isAlphabetSortActive(sortController)) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 32.h),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => UniversityListCardWidget(university: universities[i]),
            childCount: universities.length,
          ),
        ),
      );
    }

    // --- A-Z HIZLI NAVİGASYON AKTİF ---
    // Not: Sidebar artık listenin üzerine binmiyor (Stack değil),
    // Row içinde listenin yanında ayrı bir sütun olarak duruyor.
    return SliverToBoxAdapter(
      child: _UniversityAlphabetListView(
        universities: universities,
        // CustomScrollView içindeki iç liste yüksekliği
        height: MediaQuery.of(context).size.height - 260.h,
        itemExtent: 168.h,
      ),
    );
  }

  // ── Sıralama BottomSheet ──────────────────────────────────────────────
  void _showSortBottomSheet(BuildContext context) {
    final sortController = Get.find<UniversitySortController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(maxHeight: 0.85.sh),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppTheme.textSec(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 0),
                child: Row(
                  children: [
                    Text(
                      'Sıralama Kriterleri',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: sortController.reset,
                      icon: Icon(Icons.refresh_rounded, size: 16.sp),
                      label: Text('Sıfırla', style: TextStyle(fontSize: 13.sp)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'İsim sıralaması seçildiğinde hızlı A-Z navigasyonu açılır.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSec(context),
                  ),
                ),
              ),
              Divider(height: 20.h, thickness: 1),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  children: SortCriteria.values
                      .map((criteria) => _SortOptionTile(criteria: criteria))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Sıralama Seçim Satırı ────────────────────────────────────────────────────

class _SortOptionTile extends StatelessWidget {
  final SortCriteria criteria;
  const _SortOptionTile({required this.criteria});

  String get _title {
    switch (criteria) {
      case SortCriteria.name:
        return 'İsim';
      case SortCriteria.city:
        return 'Şehir';
      case SortCriteria.foundedYear:
        return 'Kuruluş Yılı';
      case SortCriteria.subscriberCount:
        return 'Takipçi Sayısı';
      case SortCriteria.viewCount:
        return 'Görüntülenme Sayısı';
      case SortCriteria.videoCount:
        return 'İçerik Sayısı';
    }
  }

  IconData get _icon {
    switch (criteria) {
      case SortCriteria.name:
        return Icons.text_fields_rounded;
      case SortCriteria.city:
        return Icons.location_on_rounded;
      case SortCriteria.foundedYear:
        return Icons.calendar_today_rounded;
      case SortCriteria.subscriberCount:
        return Icons.people_rounded;
      case SortCriteria.viewCount:
        return Icons.visibility_rounded;
      case SortCriteria.videoCount:
        return Icons.play_circle_fill_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortController = Get.find<UniversitySortController>();

    return Obx(() {
      final isActive = sortController.activeSorts.any(
        (s) => s.criteria == criteria,
      );
      final sortOption = sortController.activeSorts.firstWhereOrNull(
        (s) => s.criteria == criteria,
      );

      return Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          leading: Icon(
            _icon,
            size: 20.sp,
            color: isActive ? AppTheme.primaryColor : AppTheme.textSec(context),
          ),
          title: Text(
            _title,
            style: TextStyle(
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textPri(context),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive) ...[
                IconButton(
                  icon: Icon(
                    sortOption!.direction == SortDirection.ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 20.sp,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => sortController.toggleDirection(criteria),
                ),
                SizedBox(width: 4.w),
              ],
              Checkbox(
                value: isActive,
                onChanged: (val) => sortController.addOrRemoveSort(criteria),
                activeColor: AppTheme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          onTap: () => sortController.addOrRemoveSort(criteria),
        ),
      );
    });
  }
}

// ── A-Z Hızlı Navigasyonlu Üniversite Listesi ───────────────────────────────
// Liste ve harf sidebar'ı bir Row içinde yan yana — Stack/overlay yok.
// Liste kaydırıldıkça aktif harf otomatik güncellenir; harfe dokunma/sürükleme
// listeyi o harfe kaydırır. Tüm senkron mantığı UniversityAlphabetController'da.

class _UniversityAlphabetListView extends StatefulWidget {
  final List<UniversityModel> universities;
  final double height;
  final double itemExtent;

  const _UniversityAlphabetListView({
    required this.universities,
    required this.height,
    required this.itemExtent,
  });

  @override
  State<_UniversityAlphabetListView> createState() =>
      _UniversityAlphabetListViewState();
}

class _UniversityAlphabetListViewState
    extends State<_UniversityAlphabetListView> {
  late final String _tag;
  late final UniversityAlphabetController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'uni_alpha_${identityHashCode(this)}';
    _controller = Get.put(UniversityAlphabetController(), tag: _tag);
    _controller.setData(widget.universities, widget.itemExtent);
  }

  @override
  void didUpdateWidget(covariant _UniversityAlphabetListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Liste arama/sıralama nedeniyle değiştiyse controller'a haber ver
    if (!identical(oldWidget.universities, widget.universities)) {
      _controller.setData(widget.universities, widget.itemExtent);
    }
  }

  @override
  void dispose() {
    Get.delete<UniversityAlphabetController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Liste ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _controller.scrollController,
              padding: EdgeInsets.zero,
              itemExtent: widget.itemExtent,
              itemCount: widget.universities.length,
              itemBuilder: (context, index) => UniversityListCardWidget(
                university: widget.universities[index],
              ),
            ),
          ),

          // ── A-Z Sidebar: ayrı sütun, kart üzerine binmiyor ────────
          Obx(() {
            final letters = _controller.availableLetters;
            if (letters.isEmpty) return const SizedBox.shrink();
            return _AlphabetSidebar(
              letters: letters,
              currentLetter: _controller.currentLetter.value,
              onTapLetter: _controller.jumpToLetter,
              onDragLetter: _controller.dragToLetter,
            );
          }),
        ],
      ),
    );
  }
}

class _AlphabetSidebar extends StatelessWidget {
  final List<String> letters;
  final String currentLetter;
  final ValueChanged<String> onTapLetter;
  final ValueChanged<String> onDragLetter;

  const _AlphabetSidebar({
    required this.letters,
    required this.currentLetter,
    required this.onTapLetter,
    required this.onDragLetter,
  });

  void _handlePosition(
    Offset localPosition,
    double height,
    ValueChanged<String> callback,
  ) {
    if (letters.isEmpty || height <= 0) return;
    final itemHeight = height / letters.length;
    final index = (localPosition.dy / itemHeight).floor().clamp(
      0,
      letters.length - 1,
    );
    callback(letters[index]);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) =>
              _handlePosition(d.localPosition, height, onTapLetter),
          onVerticalDragUpdate: (d) =>
              _handlePosition(d.localPosition, height, onDragLetter),
          child: Container(
            width: 22.w,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: letters.map((letter) {
                final isActive = letter == currentLetter;
                return Expanded(
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: isActive ? 12.sp : 10.sp,
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isActive
                            ? AppTheme.primaryColor
                            : AppTheme.textSec(context).withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
