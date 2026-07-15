// lib/presentation/screens/home/widgets/tabs/home_tab/shorts/shorts_row_widget.dart
//
// FIX: Shorts artık yayınlanma tarihine göre gösterilir (en yeni önce).
// Her üniversitenin en son yüklediği short önce gelir.
// Sonsuz döngüyü önlemek için cache kullanılmaz — her açılışta taze veri.
//
// RESPONSIVE NOT:
// Phone ve tablet için TAMAMEN AYRI iki widget/build yolu var.
// Aralarında hiçbir otomatik ölçekleme YOK — her ikisi de kendi sabit
// sayılarıyla çalışıyor. Sayıları aşağıdaki _PhoneSizes / _TabletSizes
// sınıflarından değiştirebilirsin, kod içinde arama yapmana gerek yok.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/shorts_model.dart';
import '../../../../../controllers/shorts_controller.dart';

// ═══════════════════════════════════════════════════════════════════════
//  SABİTLER — burayı değiştir, kodun geri kalanına dokunma
// ═══════════════════════════════════════════════════════════════════════

/// Phone için sabitler. Bunlar ScreenUtil (.w/.h/.sp) ile çarpılıyor,
/// yani telefon-içi farklı ekran boyutlarına (küçük/büyük telefon) hâlâ
/// orantılı uyum sağlıyor — sadece MUTLAK sayılar burada.
class _PhoneSizes {
  static const double rowHeight = 110;
  static const double avatarSize = 68;
  static const double ringPadding = 2.5;
  static const double innerPadding = 2;
  static const double logoSize = 22;
  static const double logoBorder = 1.5;
  static const double nameWidth = 72;
  static const double nameFontSize = 9.5;
  static const double dateFontSize = 8;
  static const double itemHorizontalPadding = 6;
  static const double listHorizontalPadding = 12;
  static const double spacingAfterAvatar = 5;
  static const double spacingAfterName = 2;
}

/// Tablet için sabitler. ScreenUtil'e HİÇ dokunmuyor — direkt piksel.
/// Phone'dan biraz küçük tutuldu (senin isteğin), istediğin gibi
/// büyüt/küçült.
class _TabletSizes {
  static const double rowHeight = 92;
  static const double avatarSize = 56;
  static const double ringPadding = 2;
  static const double innerPadding = 1.5;
  static const double logoSize = 17;
  static const double logoBorder = 1.2;
  static const double nameWidth = 62;
  static const double nameFontSize = 8.5;
  static const double dateFontSize = 7;
  static const double itemHorizontalPadding = 5;
  static const double listHorizontalPadding = 24;
  static const double spacingAfterAvatar = 4;
  static const double spacingAfterName = 2;
}

// ═══════════════════════════════════════════════════════════════════════
//  ANA WIDGET
// ═══════════════════════════════════════════════════════════════════════

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

    return Obx(() {
      if (controller.isLoading.value) {
        // ── TEK DALLANMA NOKTASI ────────────────────────────────────
        return Responsive.isTablet(context)
            ? _buildTabletShimmer(context)
            : _buildPhoneShimmer(context);
      }

      if (controller.shorts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Responsive.isTablet(context)
          ? _tablet(context, controller)
          : _phone(context, controller);
    });
  }

  // ── PHONE — mevcut tasarımın birebir aynısı, dokunulmadı ──────────────
  Widget _phone(BuildContext context, ShortsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _PhoneSizes.rowHeight.h,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.listHorizontalPadding.w,
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
        ),
      ],
    );
  }

  Widget _buildPhoneShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: SizedBox(
        height: 140.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: _PhoneSizes.listHorizontalPadding.w,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 56.w,
                  height: 10.h,
                  color: AppTheme.surface(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TABLET — ayrı, sabit sayılarla, ScreenUtil'siz ─────────────────────
  Widget _tablet(BuildContext context, ShortsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _TabletSizes.rowHeight,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: _TabletSizes.listHorizontalPadding,
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
        ),
      ],
    );
  }

  Widget _buildTabletShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: SizedBox(
        height: _TabletSizes.rowHeight + 30,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: _TabletSizes.listHorizontalPadding,
          ),
          itemCount: 8,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                Container(
                  width: _TabletSizes.avatarSize,
                  height: _TabletSizes.avatarSize,
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: _TabletSizes.nameWidth,
                  height: 9,
                  color: AppTheme.surface(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  SAYFALAMA YÜKLENİYOR GÖSTERGESİ — phone / tablet ayrı
// ═══════════════════════════════════════════════════════════════════════

class _PhoneLoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  const _PhoneLoadMoreIndicator({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.w,
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
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
      width: 42,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
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
//  TEK BİR SHORTS ÖĞESİ — PHONE (mevcut tasarımın birebir aynısı)
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

  String _shortName(String name) {
    return name
        .replaceAll('Üniversitesi', 'Üni.')
        .replaceAll('Teknik Üniversitesi', 'T.Ü.')
        .replaceAll('Vakıf Üniversitesi', 'V.Ü.');
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final timeAgo = timeago.format(shorts.publishedAt, locale: 'tr');

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.shortsPlayer,
          arguments: {'shorts': allShorts, 'initialIndex': initialIndex},
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.itemHorizontalPadding.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _PhoneSizes.avatarSize.w,
              height: _PhoneSizes.avatarSize.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: _PhoneSizes.avatarSize.w,
                    height: _PhoneSizes.avatarSize.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF1DB954), Color(0xFF0A84FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(_PhoneSizes.ringPadding),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.bg(context),
                      ),
                      padding: EdgeInsets.all(_PhoneSizes.innerPadding),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: shorts.bestThumbnail,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF1A1A1A),
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (shorts.logoUrl != null && shorts.logoUrl!.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: _PhoneSizes.logoSize.w,
                        height: _PhoneSizes.logoSize.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppTheme.bg(context),
                            width: _PhoneSizes.logoBorder,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: shorts.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.school, size: 12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: _PhoneSizes.spacingAfterAvatar.h),
            SizedBox(
              width: _PhoneSizes.nameWidth.w,
              child: Text(
                _shortName(shorts.universityName),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _PhoneSizes.nameFontSize.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSec(context),
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: _PhoneSizes.spacingAfterName.h),
            SizedBox(
              width: _PhoneSizes.nameWidth.w,
              child: Text(
                timeAgo,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _PhoneSizes.dateFontSize.sp,
                  color: AppTheme.textSec(context).withOpacity(0.6),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  TEK BİR SHORTS ÖĞESİ — TABLET (ayrı, sabit sayılarla, ScreenUtil yok)
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

  String _shortName(String name) {
    return name
        .replaceAll('Üniversitesi', 'Üni.')
        .replaceAll('Teknik Üniversitesi', 'T.Ü.')
        .replaceAll('Vakıf Üniversitesi', 'V.Ü.');
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    final timeAgo = timeago.format(shorts.publishedAt, locale: 'tr');

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.shortsPlayer,
          arguments: {'shorts': allShorts, 'initialIndex': initialIndex},
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _TabletSizes.itemHorizontalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _TabletSizes.avatarSize,
              height: _TabletSizes.avatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: _TabletSizes.avatarSize,
                    height: _TabletSizes.avatarSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF1DB954), Color(0xFF0A84FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(_TabletSizes.ringPadding),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.bg(context),
                      ),
                      padding: EdgeInsets.all(_TabletSizes.innerPadding),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: shorts.bestThumbnail,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF1A1A1A),
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (shorts.logoUrl != null && shorts.logoUrl!.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: _TabletSizes.logoSize,
                        height: _TabletSizes.logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: AppTheme.bg(context),
                            width: _TabletSizes.logoBorder,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: shorts.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.school, size: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: _TabletSizes.spacingAfterAvatar),
            SizedBox(
              width: _TabletSizes.nameWidth,
              child: Text(
                _shortName(shorts.universityName),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _TabletSizes.nameFontSize,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSec(context),
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: _TabletSizes.spacingAfterName),
            SizedBox(
              width: _TabletSizes.nameWidth,
              child: Text(
                timeAgo,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _TabletSizes.dateFontSize,
                  color: AppTheme.textSec(context).withOpacity(0.6),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
