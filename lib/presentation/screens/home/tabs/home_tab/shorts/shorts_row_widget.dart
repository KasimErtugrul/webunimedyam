// lib/presentation/screens/home/tabs/home_tab/shorts/shorts_row_widget.dart
//
// TASARIM DEĞİŞİKLİĞİ: Instagram Story tarzı (yuvarlak avatar + halka)
// yerine TikTok/Shorts benzeri DİKEY KART tasarımına geçildi.
// Her kart: tam kaplayan thumbnail + alt kısımda gradient üzerine
// üniversite logosu + başlık + yayın tarihi.
//
// RESPONSIVE NOT: Phone ve tablet için TAMAMEN AYRI sabitler ve kart
// widget'ları var (_PhoneSizes / _TabletSizes, _ShortsThumbItemPhone /
// _ShortsThumbItemTablet). ScreenUtil SADECE phone tarafında kullanılıyor.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../core/widgets/hover_tap.dart';
import '../../../../../../data/models/shorts_model.dart';
import '../../../../../controllers/shorts_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

/// Phone için sabitler. ScreenUtil (.w/.h/.sp) ile çarpılıyor.
class _PhoneSizes {
  // Satır / kart
  static const double rowHeight = 185;
  static const double cardWidth = 104;
  static const double cardHeight = 185;
  static const double cardMarginRight = 10;
  static const double cardBorderRadius = 12;
  static const double listPaddingHorizontal = 12;

  // Gradient + üst rozet
  static const double gradientHeight = 72;
  static const double durationTop = 6;
  static const double durationRight = 6;
  static const double durationPaddingHorizontal = 5;
  static const double durationPaddingVertical = 2;
  static const double durationBorderRadius = 4;
  static const double durationFontSize = 8;

  // Alt içerik (logo + başlık + tarih)
  static const double contentPaddingHorizontal = 7;
  static const double contentPaddingBottom = 7;
  static const double logoSize = 18;
  static const double logoBorder = 1.2;
  static const double logoTitleSpacing = 5;
  static const double uniNameFontSize = 8;
  static const double rowToTitleSpacing = 4;
  static const double titleFontSize = 9.5;
  static const double titleLineHeight = 1.2;
  static const double titleToTimeSpacing = 3;
  static const double timeAgoFontSize = 7.5;

  // Placeholder
  static const double placeholderIconSize = 26;

  // Bölüm başlığı ("Shorts")
  static const double sectionPadLeft = 16;
  static const double sectionPadTop = 12;
  static const double sectionPadRight = 16;
  static const double sectionPadBottom = 8;
  static const double sectionIconSize = 18;
  static const double sectionIconSpacing = 6;
  static const double sectionTitleFontSize = 16;
}

/// Tablet için sabitler. ScreenUtil'e HİÇ dokunmuyor — direkt piksel.
class _TabletSizes {
  static const double rowHeight = 220;
  static const double cardWidth = 124;
  static const double cardHeight = 220;
  static const double cardMarginRight = 12;
  static const double cardBorderRadius = 14;
  static const double listPaddingHorizontal = 24;

  static const double gradientHeight = 86;
  static const double durationTop = 8;
  static const double durationRight = 8;
  static const double durationPaddingHorizontal = 6;
  static const double durationPaddingVertical = 3;
  static const double durationBorderRadius = 5;
  static const double durationFontSize = 9;

  static const double contentPaddingHorizontal = 9;
  static const double contentPaddingBottom = 9;
  static const double logoSize = 22;
  static const double logoBorder = 1.4;
  static const double logoTitleSpacing = 6;
  static const double uniNameFontSize = 9.5;
  static const double rowToTitleSpacing = 5;
  static const double titleFontSize = 11.5;
  static const double titleLineHeight = 1.25;
  static const double titleToTimeSpacing = 4;
  static const double timeAgoFontSize = 9;

  static const double placeholderIconSize = 30;

  // Bölüm başlığı ("Shorts")
  static const double sectionPadLeft = 24;
  static const double sectionPadTop = 16;
  static const double sectionPadRight = 24;
  static const double sectionPadBottom = 10;
  static const double sectionIconSize = 20;
  static const double sectionIconSpacing = 8;
  static const double sectionTitleFontSize = 18;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class ShortsRowWidget extends StatefulWidget {
  const ShortsRowWidget({super.key});

  @override
  State<ShortsRowWidget> createState() => _ShortsRowWidgetState();
}

class _ShortsRowWidgetState extends State<ShortsRowWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      Get.find<ShortsController>().loadMoreShorts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortsController>();
    // Üçlü ölçek: web (masaüstü tarayıcı) → tablet → telefon.
    final isWeb = Responsive.isWeb(context);
    final isTablet = Responsive.isTablet(context);

    return Obx(() {
      if (controller.isLoading.value) {
        // ── TEK DALLANMA NOKTASI ────────────────────────────────────
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isWeb
                ? _buildSectionTitleWeb(context)
                : isTablet
                ? _buildSectionTitleTablet(context)
                : _buildSectionTitlePhone(context),
            isWeb
                ? _buildWebShimmer(context)
                : isTablet
                ? _buildTabletShimmer(context)
                : _buildPhoneShimmer(context),
          ],
        );
      }

      if (controller.shorts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWeb
              ? _buildSectionTitleWeb(context)
              : isTablet
              ? _buildSectionTitleTablet(context)
              : _buildSectionTitlePhone(context),
          isWeb
              ? _web(context, controller)
              : isTablet
              ? _tablet(context, controller)
              : _phone(context, controller),
        ],
      );
    });
  }

  // ── "Üniversite Shorts" Bölüm Başlığı — Phone ──────────────────────────
  // Tasarım: sol → ⚡ ikon + "Üniversite Shorts" başlığı; sağ → "Tümü >" linki
  Widget _buildSectionTitlePhone(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _PhoneSizes.sectionPadLeft,
        _PhoneSizes.sectionPadTop,
        _PhoneSizes.sectionPadRight,
        _PhoneSizes.sectionPadBottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: _PhoneSizes.sectionIconSize,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: _PhoneSizes.sectionIconSpacing),
                Flexible(
                  child: Text(
                    'Üniversite Shorts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _PhoneSizes.sectionTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // TODO(kasım): "Tümü" — tüm shorts'ları gösteren ayrı bir ekrana
          // yönlendirme henüz bağlanmadı; onTap boş bırakıldı.
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümü',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── "Kampüs Shorts & Reels" Bölüm Başlığı — Tablet ─────────────────────
  // Tasarımdaki gibi: başlık + sağda "Tümünü Gör" linki ve şeridi kaydıran
  // ok butonları (chevron_left / chevron_right).
  Widget _buildSectionTitleTablet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _TabletSizes.sectionPadLeft,
        _TabletSizes.sectionPadTop,
        _TabletSizes.sectionPadRight,
        _TabletSizes.sectionPadBottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: _TabletSizes.sectionIconSize,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: _TabletSizes.sectionIconSpacing),
                Flexible(
                  child: Text(
                    'Kampüs Shorts & Reels',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _TabletSizes.sectionTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // TODO(kasım): "Tümünü Gör" — tüm shorts'ları gösteren ayrı bir
          // ekrana yönlendirme henüz bağlanmadı; onTap boş bırakıldı.
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tasarımdaki ok butonları — şeridi sola/sağa kaydırır.
          _TabletScrollArrowButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => _scrollShortsRow(-1),
          ),
          const SizedBox(width: 6),
          _TabletScrollArrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: () => _scrollShortsRow(1),
          ),
        ],
      ),
    );
  }

  // Şeridi bir "ekran dolusu" sola/sağa kaydırır (tasarımdaki davranış:
  // scrollBy ±300px, smooth).
  void _scrollShortsRow(int direction) {
    if (!_scrollController.hasClients) return;
    final double page = _scrollController.position.viewportDimension * 0.8;
    _scrollController.animateTo(
      (_scrollController.offset + direction * page).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI
  // ═══════════════════════════════════════════════════════════════════════

  Widget _phone(BuildContext context, ShortsController controller) {
    return SizedBox(
      height: _PhoneSizes.rowHeight,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: _PhoneSizes.listPaddingHorizontal,
        ),
        itemCount:
            controller.shorts.length + (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.shorts.length) {
            return _PhoneLoadMoreIndicator(
              isLoading: controller.isLoadingMore.value,
            );
          }
          return _ShortsThumbItemPhone(
            shorts: controller.shorts[index],
            initialIndex: index,
            allShorts: controller.shorts,
          );
        },
      ),
    );
  }

  Widget _buildPhoneShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: SizedBox(
        height: _PhoneSizes.rowHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: _PhoneSizes.listPaddingHorizontal,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => Container(
            width: _PhoneSizes.cardWidth,
            height: _PhoneSizes.cardHeight,
            margin: const EdgeInsets.only(right: _PhoneSizes.cardMarginRight),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _tablet(BuildContext context, ShortsController controller) {
    return SizedBox(
      height: _TabletSizes.rowHeight,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: _TabletSizes.listPaddingHorizontal,
        ),
        itemCount:
            controller.shorts.length + (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.shorts.length) {
            return _TabletLoadMoreIndicator(
              isLoading: controller.isLoadingMore.value,
            );
          }
          return _ShortsThumbItemTablet(
            shorts: controller.shorts[index],
            initialIndex: index,
            allShorts: controller.shorts,
          );
        },
      ),
    );
  }

  Widget _buildTabletShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: SizedBox(
        height: _TabletSizes.rowHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: _TabletSizes.listPaddingHorizontal,
          ),
          itemCount: 8,
          itemBuilder: (_, _) => Container(
            width: _TabletSizes.cardWidth,
            height: _TabletSizes.cardHeight,
            margin: const EdgeInsets.only(right: _TabletSizes.cardMarginRight),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(
                _TabletSizes.cardBorderRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── "Kampüs Shorts & Reels" Bölüm Başlığı — Web ───────────────────────
  Widget _buildSectionTitleWeb(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _WebSizes.sectionPadLeft,
        _WebSizes.sectionPadTop,
        _WebSizes.sectionPadRight,
        _WebSizes.sectionPadBottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: _WebSizes.sectionIconSize,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: _WebSizes.sectionIconSpacing),
                Flexible(
                  child: Text(
                    'Kampüs Shorts & Reels',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _WebSizes.sectionTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // TODO(kasım): "Tümünü Gör" — tablet dakiyle aynı, henüz bağlanmadı.
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Web gövde — tablet sırasının web ölçeği ────────────────────────────
  Widget _web(BuildContext context, ShortsController controller) {
    return SizedBox(
      height: _WebSizes.rowHeight,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: _WebSizes.listPaddingHorizontal,
        ),
        itemCount:
            controller.shorts.length + (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.shorts.length) {
            return _TabletLoadMoreIndicator(
              isLoading: controller.isLoadingMore.value,
            );
          }
          return _ShortsThumbItemWeb(
            shorts: controller.shorts[index],
            initialIndex: index,
            allShorts: controller.shorts,
          );
        },
      ),
    );
  }

  Widget _buildWebShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: SizedBox(
        height: _WebSizes.rowHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: _WebSizes.listPaddingHorizontal,
          ),
          itemCount: 8,
          itemBuilder: (_, _) => Container(
            width: _WebSizes.cardWidth,
            height: _WebSizes.cardHeight,
            margin: const EdgeInsets.only(right: _WebSizes.cardMarginRight),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(_WebSizes.cardBorderRadius),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TABLET BAŞLIK OK BUTONU — tasarım: w-8 h-8, rounded-lg,
// bg-surface-container-high, chevron ikonu
// ═══════════════════════════════════════════════════════════════════════

class _TabletScrollArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TabletScrollArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: scheme.onSurface),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// SAYFALAMA YÜKLENİYOR GÖSTERGESİ — phone / tablet ayrı
// ═══════════════════════════════════════════════════════════════════════

class _PhoneLoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  const _PhoneLoadMoreIndicator({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _TabletLoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  const _TabletLoadMoreIndicator({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TEK BİR SHORTS KARTI — PHONE (Dikey kart, TikTok/Shorts tarzı)
// ═══════════════════════════════════════════════════════════════════════

class _ShortsThumbItemPhone extends StatelessWidget {
  final ShortsModel shorts;
  final int initialIndex;
  final List<ShortsModel> allShorts;

  const _ShortsThumbItemPhone({
    required this.shorts,
    required this.initialIndex,
    required this.allShorts,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final timeAgo = timeago.format(shorts.publishedAt, locale: 'tr');

    return TapCursor(
      onTap: () => Get.toNamed(
        AppRoutes.shortsPlayer,
        arguments: {'shorts': allShorts, 'initialIndex': initialIndex},
      ),
      child: Container(
        width: _PhoneSizes.cardWidth,
        height: _PhoneSizes.cardHeight,
        margin: const EdgeInsets.only(right: _PhoneSizes.cardMarginRight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: shorts.bestThumbnail,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _placeholder(context),
              placeholder: (_, _) => _shimmerBox(context),
            ),

            // Alt gradient (metin okunabilirliği için)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _PhoneSizes.gradientHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Süre rozeti — sağ üst
            if (shorts.duration.isNotEmpty)
              Positioned(
                top: _PhoneSizes.durationTop,
                right: _PhoneSizes.durationRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _PhoneSizes.durationPaddingHorizontal,
                    vertical: _PhoneSizes.durationPaddingVertical,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(
                      _PhoneSizes.durationBorderRadius,
                    ),
                  ),
                  child: Text(
                    _formatDuration(shorts.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _PhoneSizes.durationFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Alt içerik: logo + üniversite adı + başlık + tarih
            Positioned(
              left: _PhoneSizes.contentPaddingHorizontal,
              right: _PhoneSizes.contentPaddingHorizontal,
              bottom: _PhoneSizes.contentPaddingBottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: _PhoneSizes.logoSize,
                        height: _PhoneSizes.logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: _PhoneSizes.logoBorder,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              (shorts.logoUrl != null &&
                                  shorts.logoUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: shorts.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) =>
                                      const Icon(Icons.school, size: 10),
                                )
                              : const Icon(Icons.school, size: 10),
                        ),
                      ),
                      const SizedBox(width: _PhoneSizes.logoTitleSpacing),
                      Expanded(
                        child: Text(
                          shorts.universityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: _PhoneSizes.uniNameFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _PhoneSizes.rowToTitleSpacing),
                  Text(
                    shorts.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _PhoneSizes.titleFontSize,
                      fontWeight: FontWeight.w700,
                      height: _PhoneSizes.titleLineHeight,
                    ),
                  ),
                  const SizedBox(height: _PhoneSizes.titleToTimeSpacing),
                  Text(
                    timeAgo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: _PhoneSizes.timeAgoFontSize,
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

  Widget _placeholder(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: _PhoneSizes.placeholderIconSize,
    ),
  );

  Widget _shimmerBox(BuildContext context) =>
      Container(color: AppTheme.surface(context));
}

// ═══════════════════════════════════════════════════════════════════════
// TEK BİR SHORTS KARTI — TABLET (ayrı, sabit sayılarla)
// ═══════════════════════════════════════════════════════════════════════

class _ShortsThumbItemTablet extends StatelessWidget {
  final ShortsModel shorts;
  final int initialIndex;
  final List<ShortsModel> allShorts;

  const _ShortsThumbItemTablet({
    required this.shorts,
    required this.initialIndex,
    required this.allShorts,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final timeAgo = timeago.format(shorts.publishedAt, locale: 'tr');

    return TapCursor(
      onTap: () => Get.toNamed(
        AppRoutes.shortsPlayer,
        arguments: {'shorts': allShorts, 'initialIndex': initialIndex},
      ),
      child: Container(
        width: _TabletSizes.cardWidth,
        height: _TabletSizes.cardHeight,
        margin: const EdgeInsets.only(right: _TabletSizes.cardMarginRight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: shorts.bestThumbnail,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _placeholder(context),
              placeholder: (_, _) => _shimmerBox(context),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _TabletSizes.gradientHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            if (shorts.duration.isNotEmpty)
              Positioned(
                top: _TabletSizes.durationTop,
                right: _TabletSizes.durationRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _TabletSizes.durationPaddingHorizontal,
                    vertical: _TabletSizes.durationPaddingVertical,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(
                      _TabletSizes.durationBorderRadius,
                    ),
                  ),
                  child: Text(
                    _formatDuration(shorts.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _TabletSizes.durationFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: _TabletSizes.contentPaddingHorizontal,
              right: _TabletSizes.contentPaddingHorizontal,
              bottom: _TabletSizes.contentPaddingBottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: _TabletSizes.logoSize,
                        height: _TabletSizes.logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: _TabletSizes.logoBorder,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              (shorts.logoUrl != null &&
                                  shorts.logoUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: shorts.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) =>
                                      const Icon(Icons.school, size: 12),
                                )
                              : const Icon(Icons.school, size: 12),
                        ),
                      ),
                      const SizedBox(width: _TabletSizes.logoTitleSpacing),
                      Expanded(
                        child: Text(
                          shorts.universityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: _TabletSizes.uniNameFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _TabletSizes.rowToTitleSpacing),
                  Text(
                    shorts.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _TabletSizes.titleFontSize,
                      fontWeight: FontWeight.w700,
                      height: _TabletSizes.titleLineHeight,
                    ),
                  ),
                  const SizedBox(height: _TabletSizes.titleToTimeSpacing),
                  Text(
                    timeAgo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: _TabletSizes.timeAgoFontSize,
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

  Widget _placeholder(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: _TabletSizes.placeholderIconSize,
    ),
  );

  Widget _shimmerBox(BuildContext context) =>
      Container(color: AppTheme.surface(context));
}

// ─── ISO 8601 süreyi "MM:SS" formatına çevirir ───────────────────────────────

String _formatDuration(String iso) {
  final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
  final match = regex.firstMatch(iso);
  if (match == null) return '';

  final h = int.tryParse(match.group(1) ?? '') ?? 0;
  final m = int.tryParse(match.group(2) ?? '') ?? 0;
  final s = int.tryParse(match.group(3) ?? '') ?? 0;

  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════
// WEB SABİTLERİ — masaüstü tarayıcı (≥1024px). Tablet ölçülerini
// temel alır; kart 150×266'ya büyütülür, sayfa kenarları 32'ye çıkar.
// ═══════════════════════════════════════════════════════════
class _WebSizes {
  static const double rowHeight = 266;
  static const double cardWidth = 150;
  static const double cardHeight = 266;
  static const double cardMarginRight = 14;
  static const double cardBorderRadius = 14;
  static const double listPaddingHorizontal = 32;

  static const double gradientHeight = 104;
  static const double durationTop = 10;
  static const double durationRight = 10;
  static const double durationPaddingHorizontal = 7;
  static const double durationPaddingVertical = 4;
  static const double durationBorderRadius = 6;
  static const double durationFontSize = 10;

  static const double contentPaddingHorizontal = 11;
  static const double contentPaddingBottom = 11;
  static const double logoSize = 26;
  static const double logoBorder = 1.6;
  static const double logoTitleSpacing = 7;
  static const double uniNameFontSize = 11;
  static const double rowToTitleSpacing = 6;
  static const double titleFontSize = 13.5;
  static const double titleLineHeight = 1.25;
  static const double titleToTimeSpacing = 5;
  static const double timeAgoFontSize = 10.5;

  static const double placeholderIconSize = 34;

  // Bölüm başlığı ("Kampüs Shorts & Reels")
  static const double sectionPadLeft = 32;
  static const double sectionPadTop = 16;
  static const double sectionPadRight = 32;
  static const double sectionPadBottom = 12;
  static const double sectionIconSize = 22;
  static const double sectionIconSpacing = 8;
  static const double sectionTitleFontSize = 20;
}

// ═══════════════════════════════════════════════════════════
// WEB KARTI — tablet kartın dikey tasarımının web ölçeği.
// Tablet sınıfıyla birebir; yalnızca _WebSizes sabitlerini kullanır.
// ═══════════════════════════════════════════════════════════
class _ShortsThumbItemWeb extends StatelessWidget {
  final ShortsModel shorts;
  final int initialIndex;
  final List<ShortsModel> allShorts;

  const _ShortsThumbItemWeb({
    required this.shorts,
    required this.initialIndex,
    required this.allShorts,
  });

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final timeAgo = timeago.format(shorts.publishedAt, locale: 'tr');

    return TapCursor(
      onTap: () => Get.toNamed(
        AppRoutes.shortsPlayer,
        arguments: {'shorts': allShorts, 'initialIndex': initialIndex},
      ),
      child: Container(
        width: _WebSizes.cardWidth,
        height: _WebSizes.cardHeight,
        margin: const EdgeInsets.only(right: _WebSizes.cardMarginRight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_WebSizes.cardBorderRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: shorts.bestThumbnail,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _placeholder(context),
              placeholder: (_, _) => _shimmerBox(context),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _WebSizes.gradientHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
            if (shorts.duration.isNotEmpty)
              Positioned(
                top: _WebSizes.durationTop,
                right: _WebSizes.durationRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _WebSizes.durationPaddingHorizontal,
                    vertical: _WebSizes.durationPaddingVertical,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(
                      _WebSizes.durationBorderRadius,
                    ),
                  ),
                  child: Text(
                    _formatDuration(shorts.duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _WebSizes.durationFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: _WebSizes.contentPaddingHorizontal,
              right: _WebSizes.contentPaddingHorizontal,
              bottom: _WebSizes.contentPaddingBottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: _WebSizes.logoSize,
                        height: _WebSizes.logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: _WebSizes.logoBorder,
                          ),
                        ),
                        child: ClipOval(
                          child:
                              (shorts.logoUrl != null &&
                                  shorts.logoUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: shorts.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) =>
                                      const Icon(Icons.school, size: 12),
                                )
                              : const Icon(Icons.school, size: 12),
                        ),
                      ),
                      const SizedBox(width: _WebSizes.logoTitleSpacing),
                      Expanded(
                        child: Text(
                          shorts.universityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: _WebSizes.uniNameFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _WebSizes.rowToTitleSpacing),
                  Text(
                    shorts.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: _WebSizes.titleFontSize,
                      fontWeight: FontWeight.w700,
                      height: _WebSizes.titleLineHeight,
                    ),
                  ),
                  const SizedBox(height: _WebSizes.titleToTimeSpacing),
                  Text(
                    timeAgo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: _WebSizes.timeAgoFontSize,
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

  Widget _placeholder(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: _WebSizes.placeholderIconSize,
    ),
  );

  Widget _shimmerBox(BuildContext context) =>
      Container(color: AppTheme.surface(context));
}
