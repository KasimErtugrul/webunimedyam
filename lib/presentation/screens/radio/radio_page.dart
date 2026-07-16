// lib/presentation/screens/radio/radio_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/radio_page_controller.dart';
import 'widgets/radio_card_widget.dart';
import 'widgets/radio_dot_indicator_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarTitleSize = 18;
  static const double listIconSize = 22;

  // Sheet
  static const double sheetBorderRadius = 16;
  static const double sheetTitlePaddingVertical = 12;
  static const double sheetTitleFontSize = 16;
  static const double sheetDividerHeight = 1;
  static const double sheetAvatarSize = 40;
  static const double sheetAvatarIconSize = 20;
  static const double sheetTitleFontSizeList = 14;
  static const double sheetCheckIconSize = 20;

  // Empty state
  static const double emptyFontSize = 15;

  // Navigation arrows
  static const double chevronSize = 32;

  // Dot indicator
  static const double dotIndicatorPaddingVertical = 12;

  // Bottom hint
  static const double hintPaddingBottom = 20;
  static const double hintFontSize = 12;

  // Body
  //static const double bodyPaddingHorizontal = 0;
 // static const double bodyPaddingVertical = 0;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double appBarTitleSize = 22;
  static const double listIconSize = 26;

  // Sheet - tablet için daha büyük
  static const double sheetBorderRadius = 20;
  static const double sheetTitlePaddingVertical = 16;
  static const double sheetTitleFontSize = 20;
  static const double sheetDividerHeight = 1.5;
  static const double sheetAvatarSize = 48;
  static const double sheetAvatarIconSize = 24;
  static const double sheetTitleFontSizeList = 16;
  static const double sheetCheckIconSize = 24;

  // Empty state - tablet için daha büyük
  static const double emptyFontSize = 18;

  // Navigation arrows - tablet için daha büyük
  static const double chevronSize = 40;

  // Dot indicator - tablet için daha büyük
  static const double dotIndicatorPaddingVertical = 16;

  // Bottom hint - tablet için daha büyük
  static const double hintPaddingBottom = 24;
  static const double hintFontSize = 14;

  // Body
 // static const double bodyPaddingHorizontal = 0;
 // static const double bodyPaddingVertical = 0;
}

// ─── Page ─────────────────────────────────────────────────────────────────────
//
// NOT: Bu sayfa artık PageView KULLANMIYOR. RadioVisualizer (radio_player
// paketinin native FFT görselleştiricisi), PageView'ın swipe sırasında
// widget'ları sürekli dispose/recreate etmesiyle temelden uyumsuzdu —
// native stream callback'i defunct olmuş bir Element'e ulaşmaya çalışınca
// "_lifecycleState != defunct" assertion hatası fırlatıyordu.
//
// Çözüm: Ekranda HER ZAMAN tek bir RadioCardWidget var. Üniversite
// değişimi swipe ile değil, üstteki liste (☰) veya ileri/geri okları ile
// yapılıyor. Böylece RadioVisualizer hiçbir zaman dispose edilmiyor;
// sadece çalınan istasyon (uni) değişiyor. Geçiş hissi için AnimatedSwitcher
// kullanıldı.

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  late final RadioPageController _ctrl;
  int _currentIndex = 0;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(RadioPageController());

    ever(_ctrl.universities, (list) {
      if (list.isNotEmpty && _ctrl.currentUrl.value == null) {
        _ctrl.playStation(list[0]);
      }
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<RadioPageController>()) {
      Get.delete<RadioPageController>(force: true);
    }
    super.dispose();
  }

  Future<void> _leave() async {
    if (_isLeaving) return;
    _isLeaving = true;

    await _ctrl.stopEverything();

    if (Get.isRegistered<RadioPageController>()) {
      Get.delete<RadioPageController>(force: true);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _goToIndex(int index) {
    final unis = _ctrl.universities;
    if (unis.isEmpty) return;
    final clamped = index % unis.length;
    setState(() => _currentIndex = clamped < 0 ? clamped + unis.length : clamped);
    _ctrl.currentIndex = _currentIndex;
    _ctrl.playStation(unis[_currentIndex]);
  }

  void _goNext() => _goToIndex(_currentIndex + 1);
  void _goPrevious() => _goToIndex(_currentIndex - 1);

  void _showUniversityList(BuildContext context) {
    final unis = _ctrl.universities;
    if (unis.isEmpty) return;

    final isTablet = Responsive.isTablet(context);
    final borderRadius = isTablet ? _TabletSizes.sheetBorderRadius : _PhoneSizes.sheetBorderRadius.r;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return isTablet
                ? _buildUniversityListTablet(context, unis, scrollController)
                : _buildUniversityListPhone(context, unis, scrollController);
          },
        );
      },
    );
  }

  Widget _buildUniversityListPhone(
    BuildContext context,
    List<dynamic> unis,
    ScrollController scrollController,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: _PhoneSizes.sheetTitlePaddingVertical.h),
          child: Text(
            'Tüm Radyolar',
            style: TextStyle(
              fontSize: _PhoneSizes.sheetTitleFontSize.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPri(context),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: unis.length,
            separatorBuilder: (_, __) => Divider(
              height: _PhoneSizes.sheetDividerHeight,
              color: AppTheme.isDark(context)
                  ? Colors.grey[800]
                  : Colors.grey[300],
            ),
            itemBuilder: (ctx, index) {
              final uni = unis[index];
              final isSelected = index == _currentIndex;
              return ListTile(
                leading: ClipOval(
                  child: Container(
                    width: _PhoneSizes.sheetAvatarSize.r,
                    height: _PhoneSizes.sheetAvatarSize.r,
                    color: AppTheme.surface(context),
                    child: uni.logoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: uni.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                              Icons.radio,
                              color: AppTheme.primaryColor,
                              size: _PhoneSizes.sheetAvatarIconSize.sp,
                            ),
                          )
                        : Icon(
                            Icons.radio,
                            color: AppTheme.primaryColor,
                            size: _PhoneSizes.sheetAvatarIconSize.sp,
                          ),
                  ),
                ),
                title: Text(
                  uni.name!,
                  style: TextStyle(
                    fontSize: _PhoneSizes.sheetTitleFontSizeList.sp,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPri(context),
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                        size: _PhoneSizes.sheetCheckIconSize.sp,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _goToIndex(index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityListTablet(
    BuildContext context,
    List<dynamic> unis,
    ScrollController scrollController,
  ) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: _TabletSizes.sheetTitlePaddingVertical),
          child: Text(
            'Tüm Radyolar',
            style: TextStyle(
              fontSize: _TabletSizes.sheetTitleFontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPri(context),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            itemCount: unis.length,
            separatorBuilder: (_, __) => Divider(
              height: _TabletSizes.sheetDividerHeight,
              color: AppTheme.isDark(context)
                  ? Colors.grey[800]
                  : Colors.grey[300],
            ),
            itemBuilder: (ctx, index) {
              final uni = unis[index];
              final isSelected = index == _currentIndex;
              return ListTile(
                leading: ClipOval(
                  child: Container(
                    width: _TabletSizes.sheetAvatarSize,
                    height: _TabletSizes.sheetAvatarSize,
                    color: AppTheme.surface(context),
                    child: uni.logoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: uni.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                              Icons.radio,
                              color: AppTheme.primaryColor,
                              size: _TabletSizes.sheetAvatarIconSize,
                            ),
                          )
                        : Icon(
                            Icons.radio,
                            color: AppTheme.primaryColor,
                            size: _TabletSizes.sheetAvatarIconSize,
                          ),
                  ),
                ),
                title: Text(
                  uni.name!,
                  style: TextStyle(
                    fontSize: _TabletSizes.sheetTitleFontSizeList,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPri(context),
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                        size: _TabletSizes.sheetCheckIconSize,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _goToIndex(index);
                },
              );
            },
          ),
        ),
      ],
    );
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _leave();
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        appBar: AppBar(
          title: Text(
            'Üniversite Radyoları',
            style: TextStyle(fontSize: _PhoneSizes.appBarTitleSize.sp),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _leave,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.list_rounded,
                size: _PhoneSizes.listIconSize.sp,
              ),
              tooltip: 'Radyo Listesi',
              onPressed: () => _showUniversityList(context),
            ),
          ],
        ),
        body: Obx(() {
          if (_ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final unis = _ctrl.universities;
          if (unis.isEmpty) {
            return Center(
              child: Text(
                'Radyo yayını bulunamadı.',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.emptyFontSize.sp,
                ),
              ),
            );
          }

          final safeIndex = _currentIndex.clamp(0, unis.length - 1);
          final currentUni = unis[safeIndex];

          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        size: _PhoneSizes.chevronSize.sp,
                      ),
                      onPressed: unis.length > 1 ? _goPrevious : null,
                      color: AppTheme.textSec(context),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: RadioCardWidget(
                          key: ValueKey(currentUni.id),
                          uni: currentUni,
                          ctrl: _ctrl,
                          isActive: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        size: _PhoneSizes.chevronSize.sp,
                      ),
                      onPressed: unis.length > 1 ? _goNext : null,
                      color: AppTheme.textSec(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _PhoneSizes.dotIndicatorPaddingVertical.h,
                ),
                child: RadioDotIndicatorWidget(
                  count: unis.length,
                  current: safeIndex,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: _PhoneSizes.hintPaddingBottom.h),
                child: Text(
                  'ok tuşları veya listeden radyo seç',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.hintFontSize.sp,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _leave();
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        appBar: AppBar(
          title: Text(
            'Üniversite Radyoları',
            style: TextStyle(fontSize: _TabletSizes.appBarTitleSize),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _leave,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.list_rounded,
                size: _TabletSizes.listIconSize,
              ),
              tooltip: 'Radyo Listesi',
              onPressed: () => _showUniversityList(context),
            ),
          ],
        ),
        body: Obx(() {
          if (_ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final unis = _ctrl.universities;
          if (unis.isEmpty) {
            return Center(
              child: Text(
                'Radyo yayını bulunamadı.',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.emptyFontSize,
                ),
              ),
            );
          }

          final safeIndex = _currentIndex.clamp(0, unis.length - 1);
          final currentUni = unis[safeIndex];

          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        size: _TabletSizes.chevronSize,
                      ),
                      onPressed: unis.length > 1 ? _goPrevious : null,
                      color: AppTheme.textSec(context),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: RadioCardWidget(
                          key: ValueKey(currentUni.id),
                          uni: currentUni,
                          ctrl: _ctrl,
                          isActive: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        size: _TabletSizes.chevronSize,
                      ),
                      onPressed: unis.length > 1 ? _goNext : null,
                      color: AppTheme.textSec(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _TabletSizes.dotIndicatorPaddingVertical,
                ),
                child: RadioDotIndicatorWidget(
                  count: unis.length,
                  current: safeIndex,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: _TabletSizes.hintPaddingBottom),
                child: Text(
                  'ok tuşları veya listeden radyo seç',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.hintFontSize,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}