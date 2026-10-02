/* // lib/presentation/screens/radio/radio_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✨ SIFIRDAN YENİDEN TASARLANMIŞ RADYO SAYFASI
// Konsept: "Modern Glassmorphism Radio Player"
// Özellikler korundu: liste, oynatma, görselleştirici, dalga, dot indicator
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:radio_player/radio_player.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/repositories/video_repository.dart';
import '../../controllers/radio_page_controller.dart';
import 'widgets/radio_card_widget.dart';
import 'widgets/radio_dot_indicator_widget.dart';

// ═══════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double appBarTitleSize = 18;
  static const double listIconSize = 22;
  static const double sheetBorderRadius = 20;
  static const double sheetTitlePaddingVertical = 12;
  static const double sheetTitleFontSize = 16;
  static const double sheetDividerHeight = 1;
  static const double sheetAvatarSize = 40;
  static const double sheetAvatarIconSize = 20;
  static const double sheetTitleFontSizeList = 14;
  static const double sheetCheckIconSize = 20;
  static const double emptyFontSize = 15;
  static const double chevronSize = 32;
  static const double dotIndicatorPaddingVertical = 12;
  static const double hintPaddingBottom = 20;
  static const double hintFontSize = 12;
}

class _TabletSizes {
  static const double appBarTitleSize = 22;
  static const double listIconSize = 26;
  static const double sheetBorderRadius = 24;
  static const double sheetTitlePaddingVertical = 16;
  static const double sheetTitleFontSize = 20;
  static const double sheetDividerHeight = 1.5;
  static const double sheetAvatarSize = 48;
  static const double sheetAvatarIconSize = 24;
  static const double sheetTitleFontSizeList = 16;
  static const double sheetCheckIconSize = 24;
  static const double emptyFontSize = 18;
  static const double dotIndicatorPaddingVertical = 16;
  static const double hintPaddingBottom = 24;
  static const double hintFontSize = 14;
}

// ═══════════════════════════════════════════════════════════
// ANA SAYFA
// ═══════════════════════════════════════════════════════════

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

    // RadioPage kendi Binding'ine sahip değil (route'ta binding atanmamış),
    // bu yüzden VideoRepository'nin her koşulda hazır olduğundan burada
    // emin oluyoruz — HomeBinding zaten aynı deseni kullanıyor.
    if (!Get.isRegistered<VideoRepository>()) {
      Get.lazyPut(
        () => VideoRepository(supabase: Get.find(), local: Get.find()),
        fenix: true,
      );
    }

    _ctrl = Get.put(RadioPageController(videoRepository: Get.find()));

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
    final borderRadius = isTablet ? _TabletSizes.sheetBorderRadius : _PhoneSizes.sheetBorderRadius;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.surface(context).withValues(alpha: 0.95),
                    AppTheme.bg(context).withValues(alpha: 0.98),
                  ],
                ),
              ),
              child: isTablet
                  ? _buildUniversityListTablet(context, unis, scrollController)
                  : _buildUniversityListPhone(context, unis, scrollController),
            );
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
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.textSec(context).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: _PhoneSizes.sheetTitlePaddingVertical),
          child: Text(
            'Tüm Radyolar',
            style: TextStyle(
              fontSize: _PhoneSizes.sheetTitleFontSize,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPri(context),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Divider(
          height: 1,
          color: AppTheme.isDark(context) ? Colors.grey[800] : Colors.grey[200],
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: unis.length,
            separatorBuilder: (_, _) => Divider(
              height: _PhoneSizes.sheetDividerHeight,
              indent: 64,
              color: AppTheme.isDark(context) ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[200],
            ),
            itemBuilder: (ctx, index) {
              final uni = unis[index];
              final isSelected = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: _PhoneSizes.sheetAvatarSize,
                    height: _PhoneSizes.sheetAvatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipOval(
                      child: Container(
                        color: AppTheme.surface(context),
                        child: uni.logoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: uni.logoUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.radio,
                                  color: AppTheme.primaryColor,
                                  size: _PhoneSizes.sheetAvatarIconSize,
                                ),
                              )
                            : const Icon(
                                Icons.radio,
                                color: AppTheme.primaryColor,
                                size: _PhoneSizes.sheetAvatarIconSize,
                              ),
                      ),
                    ),
                  ),
                  title: Text(
                    uni.name!,
                    style: TextStyle(
                      fontSize: _PhoneSizes.sheetTitleFontSizeList,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPri(context),
                    ),
                  ),
                  subtitle: isSelected
                      ? Text(
                          'Şu an çalıyor',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          ),
                        )
                      : null,
                  trailing: isSelected
                      ? Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: _PhoneSizes.sheetCheckIconSize * 0.7,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _goToIndex(index);
                  },
                ),
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
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.textSec(context).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: _TabletSizes.sheetTitlePaddingVertical),
          child: Text(
            'Tüm Radyolar',
            style: TextStyle(
              fontSize: _TabletSizes.sheetTitleFontSize,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPri(context),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Divider(
          height: 1,
          color: AppTheme.isDark(context) ? Colors.grey[800] : Colors.grey[200],
        ),
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: unis.length,
            separatorBuilder: (_, _) => Divider(
              height: _TabletSizes.sheetDividerHeight,
              indent: 80,
              color: AppTheme.isDark(context) ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[200],
            ),
            itemBuilder: (ctx, index) {
              final uni = unis[index];
              final isSelected = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: _TabletSizes.sheetAvatarSize,
                    height: _TabletSizes.sheetAvatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipOval(
                      child: Container(
                        color: AppTheme.surface(context),
                        child: uni.logoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: uni.logoUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.radio,
                                  color: AppTheme.primaryColor,
                                  size: _TabletSizes.sheetAvatarIconSize,
                                ),
                              )
                            : const Icon(
                                Icons.radio,
                                color: AppTheme.primaryColor,
                                size: _TabletSizes.sheetAvatarIconSize,
                              ),
                      ),
                    ),
                  ),
                  title: Text(
                    uni.name!,
                    style: TextStyle(
                      fontSize: _TabletSizes.sheetTitleFontSizeList,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPri(context),
                    ),
                  ),
                  subtitle: isSelected
                      ? Text(
                          'Şu an çalıyor',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          ),
                        )
                      : null,
                  trailing: isSelected
                      ? Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: _TabletSizes.sheetCheckIconSize * 0.7,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _goToIndex(index);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PHONE TASARIMI - ✨ YENİ ✨
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Üniversite Radyoları',
            style: TextStyle(
              fontSize: _PhoneSizes.appBarTitleSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
            onPressed: _leave,
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.list_rounded,
                    size: _PhoneSizes.listIconSize,
                    color: Colors.white,
                  ),
                ),
                tooltip: 'Radyo Listesi',
                onPressed: () => _showUniversityList(context),
              ),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Obx(() {
          if (_ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final unis = _ctrl.universities;
          if (unis.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radio_outlined, size: 64, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'Radyo yayını bulunamadı.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: _PhoneSizes.emptyFontSize,
                    ),
                  ),
                ],
              ),
            );
          }

          final safeIndex = _currentIndex.clamp(0, unis.length - 1);
          final currentUni = unis[safeIndex];

          return Stack(
            children: [
              // ✨ Dinamik gradient arka plan
              Obx(() {
                final playing = _ctrl.playbackState.value == PlaybackState.playing;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: playing
                          ? [
                              AppTheme.primaryColor.withValues(alpha: 0.4),
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                              AppTheme.bg(context),
                              AppTheme.bg(context),
                            ]
                          : [
                              AppTheme.primaryColor.withValues(alpha: 0.2),
                              AppTheme.primaryColor.withValues(alpha: 0.05),
                              AppTheme.bg(context),
                              AppTheme.bg(context),
                            ],
                      stops: const [0.0, 0.2, 0.5, 1.0],
                    ),
                  ),
                );
              }),

              // ✨ Arka plan parçacık efekti (dekoratif daireler)
              ...List.generate(6, (i) {
                return Positioned(
                  top: 80 + (i * 60),
                  left: (i % 2 == 0 ? -20 : 40),
                  child: Container(
                    width: 80 + i * 20,
                    height: 80 + i * 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withValues(alpha: 0.03 + i * 0.01),
                    ),
                  ),
                );
              }),

              // Ana içerik
              SafeArea(
                child: Column(
                  children: [
                    // Üst boşluk
                    const SizedBox(height: 20),

                    // Ana kart alanı
                    Expanded(
                      child: Row(
                        children: [
                          // Sol ok
                          _buildNavArrow(
                            icon: Icons.chevron_left,
                            onPressed: unis.length > 1 ? _goPrevious : null,
                          ),
                          // Kart
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: RadioCardWidget(
                                key: ValueKey(currentUni.id),
                                uni: currentUni,
                                ctrl: _ctrl,
                                isActive: true,
                              ),
                            ),
                          ),
                          // Sağ ok
                          _buildNavArrow(
                            icon: Icons.chevron_right,
                            onPressed: unis.length > 1 ? _goNext : null,
                          ),
                        ],
                      ),
                    ),

                    // Dot indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: _PhoneSizes.dotIndicatorPaddingVertical,
                      ),
                      child: RadioDotIndicatorWidget(
                        count: unis.length,
                        current: safeIndex,
                      ),
                    ),

                    // Alt ipucu
                    Padding(
                      padding: const EdgeInsets.only(bottom: _PhoneSizes.hintPaddingBottom),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_rounded,
                              size: 14,
                              color: Colors.white38,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'ok tuşları veya listeden radyo seç',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: _PhoneSizes.hintFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNavArrow({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onPressed != null
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.03),
            border: Border.all(
              color: onPressed != null
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: _PhoneSizes.chevronSize,
            color: onPressed != null ? Colors.white70 : Colors.white24,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TABLET TASARIMI - ✨ YENİ ✨
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Üniversite Radyoları',
            style: TextStyle(
              fontSize: _TabletSizes.appBarTitleSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
            onPressed: _leave,
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.list_rounded,
                    size: _TabletSizes.listIconSize,
                    color: Colors.white,
                  ),
                ),
                tooltip: 'Radyo Listesi',
                onPressed: () => _showUniversityList(context),
              ),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Obx(() {
          if (_ctrl.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final unis = _ctrl.universities;
          if (unis.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.radio_outlined, size: 80, color: Colors.white38),
                  SizedBox(height: 16),
                  Text(
                    'Radyo yayını bulunamadı.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: _TabletSizes.emptyFontSize,
                    ),
                  ),
                ],
              ),
            );
          }

          final safeIndex = _currentIndex.clamp(0, unis.length - 1);
          final currentUni = unis[safeIndex];

          return Stack(
            children: [
              // ✨ Dinamik gradient arka plan
              Obx(() {
                final playing = _ctrl.playbackState.value == PlaybackState.playing;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: playing
                          ? [
                              AppTheme.primaryColor.withValues(alpha: 0.4),
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                              AppTheme.bg(context),
                              AppTheme.bg(context),
                            ]
                          : [
                              AppTheme.primaryColor.withValues(alpha: 0.2),
                              AppTheme.primaryColor.withValues(alpha: 0.05),
                              AppTheme.bg(context),
                              AppTheme.bg(context),
                            ],
                      stops: const [0.0, 0.2, 0.5, 1.0],
                    ),
                  ),
                );
              }),

              // ✨ Arka plan dekoratif daireler
              ...List.generate(8, (i) {
                return Positioned(
                  top: 100 + (i * 80),
                  left: (i % 2 == 0 ? -30 : 60).toDouble(),
                  child: Container(
                    width: (100 + i * 30).toDouble(),
                    height: (100 + i * 30).toDouble(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withValues(alpha: 0.03 + i * 0.008),
                    ),
                  ),
                );
              }),

              // Ana içerik
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Expanded(
                      child: Row(
                        children: [
                          _buildNavArrow(
                            icon: Icons.chevron_left,
                            onPressed: unis.length > 1 ? _goPrevious : null,
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: RadioCardWidget(
                                key: ValueKey(currentUni.id),
                                uni: currentUni,
                                ctrl: _ctrl,
                                isActive: true,
                              ),
                            ),
                          ),
                          _buildNavArrow(
                            icon: Icons.chevron_right,
                            onPressed: unis.length > 1 ? _goNext : null,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: _TabletSizes.dotIndicatorPaddingVertical,
                      ),
                      child: RadioDotIndicatorWidget(
                        count: unis.length,
                        current: safeIndex,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: _TabletSizes.hintPaddingBottom),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swipe_rounded, size: 16, color: Colors.white38),
                            SizedBox(width: 8),
                            Text(
                              'ok tuşları veya listeden radyo seç',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: _TabletSizes.hintFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
} */
