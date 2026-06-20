// lib/presentation/screens/university_detail/university_detail_screen.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:readmore/readmore.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/video_model.dart';
import '../../controllers/university_detail_controller.dart';
import '../home/tabs/home_tab/widgets/video_card_widget.dart';

// ════════════════════════════════════════════════════════════════════════════
// BUSINESS LOGIC: Radyo Akışını Yöneten GetX Controller
// ════════════════════════════════════════════════════════════════════════════

class UniversityRadioController extends GetxController {
  // Durum değişkenleri (Reaktif)
  final Rx<PlaybackState> playbackState = PlaybackState.unknown.obs;
  final Rx<Metadata?> metadata = Rx<Metadata?>(null);
  final Rx<String?> currentPlayingUrl = Rx<String?>(null);
  final Rx<String?> currentPlayingName = Rx<String?>(null);
  final Rx<String?> currentPlayingLogo = Rx<String?>(null);

  // Stream Subscriptions
  StreamSubscription? _playbackStateSub;
  StreamSubscription? _metadataSub;

  @override
  void onInit() {
    super.onInit();
    _playbackStateSub = RadioPlayer.playbackStateStream.listen((state) {
      playbackState.value = state;
    });

    _metadataSub = RadioPlayer.metadataStream.listen((meta) {
      metadata.value = meta;
    });
  }

  void togglePlayPause({
    required String url,
    required String name,
    String? logoUrl,
  }) {
    if (currentPlayingUrl.value == url) {
      if (playbackState.value == PlaybackState.playing) {
        RadioPlayer.pause();
      } else {
        RadioPlayer.play();
      }
    } else {
      currentPlayingUrl.value = url;
      currentPlayingName.value = name;
      currentPlayingLogo.value = logoUrl;
      metadata.value = null;

      RadioPlayer.setStation(
        title: name,
        url: url,
        logoNetworkUrl: logoUrl,
        parseStreamMetadata: true,
      );
      RadioPlayer.play();
    }
  }

  void stopRadio() {
    RadioPlayer.reset();
    currentPlayingUrl.value = null;
    currentPlayingName.value = null;
    currentPlayingLogo.value = null;
    metadata.value = null;
    playbackState.value = PlaybackState.unknown;
  }

  bool get isPlaying => playbackState.value == PlaybackState.playing;
  bool get isBuffering => playbackState.value == PlaybackState.buffering;
  bool get isRadioActive => currentPlayingUrl.value != null;

  @override
  void onClose() {
    _playbackStateSub?.cancel();
    _metadataSub?.cancel();
    super.onClose();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ANA SAYFA: UniversityDetailScreen
// ════════════════════════════════════════════════════════════════════════════

class UniversityDetailScreen extends StatefulWidget {
  const UniversityDetailScreen({super.key});

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  late final UniversityDetailController controller;
  late final UniversityRadioController radioController;

  // Sayfa ömrünü bu sayfaya özel bağlamak için benzersiz bir tag oluşturuyoruz
  late final String _radioTag;
  final ScrollController _scrollController = ScrollController();
  double _titleOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UniversityDetailController>();

    // Her detay sayfası örneği için kendine özel bir controller oluştur (permanent: true KALDIRILDI)
    _radioTag = 'uni_radio_${identityHashCode(this)}';
    radioController = Get.put(UniversityRadioController(), tag: _radioTag);

    _scrollController.addListener(_updateTitleOpacity);
  }

  @override
  void dispose() {
    // 1. Radyo yayını tamamen durdur ve arka plan bildirimini kaldır
    radioController.stopRadio();

    // 2. Controller'ı GetX belleğinden sil ve dispose et
    Get.delete<UniversityRadioController>(tag: _radioTag);

    // 3. Scroll controller'ı temizle
    _scrollController.removeListener(_updateTitleOpacity);
    _scrollController.dispose();

    super.dispose();
  }

  void _updateTitleOpacity() {
    if (!_scrollController.hasClients) return;
    final double offset = _scrollController.offset;
    final double maxScroll = 240.h - kToolbarHeight;
    final double fadeStart = maxScroll * 0.99;
    final double fadeEnd = maxScroll;

    double newOpacity;
    if (offset <= fadeStart) {
      newOpacity = 0.0;
    } else if (offset >= fadeEnd) {
      newOpacity = 1.0;
    } else {
      newOpacity = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(
        0.0,
        1.0,
      );
    }

    if (newOpacity != _titleOpacity) {
      setState(() => _titleOpacity = newOpacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 240.h,
                    pinned: true,
                    floating: false,
                    backgroundColor: AppTheme.bg(context),
                    scrolledUnderElevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPri(context),
                        size: 22.sp,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    title: Opacity(
                      opacity: _titleOpacity,
                      child: Obx(() {
                        final uni = controller.university.value;
                        if (uni == null) return const SizedBox.shrink();
                        final hasLogo =
                            uni.logoUrl != null && uni.logoUrl!.isNotEmpty;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasLogo)
                              Padding(
                                padding: EdgeInsets.only(right: 10.w),
                                child: ClipOval(
                                  child: Container(
                                    width: 30.w,
                                    height: 30.w,
                                    color: Colors.white,
                                    child: CachedNetworkImage(
                                      imageUrl: uni.logoUrl!,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.school_rounded,
                                        size: 18.sp,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Icon(
                                  Icons.school_rounded,
                                  size: 22.sp,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            Flexible(
                              child: Text(
                                uni.name ?? '',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPri(context),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    actions: [
                      Obx(() {
                        final isFav = controller.isFavorite.value;
                        final isLoading = controller.isFavoriteLoading.value;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: isLoading
                              ? SizedBox(
                                  width: 44.w,
                                  height: 44.w,
                                  child: Center(
                                    child: SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  tooltip: isFav
                                      ? 'Favorilerden çıkar'
                                      : 'Favorilere ekle',
                                  icon: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, anim) =>
                                        ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
                                    child: Icon(
                                      isFav
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_border_rounded,
                                      key: ValueKey(isFav),
                                      color: isFav
                                          ? AppTheme.primaryColor
                                          : AppTheme.textPri(context),
                                      size: 26.sp,
                                    ),
                                  ),
                                  onPressed: controller.toggleFavorite,
                                ),
                        );
                      }),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _Header(controller: controller),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(context: context),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _AboutTab(
                      controller: controller,
                      radioController: radioController,
                    ),
                    _VideosTab(controller: controller),
                    _ShortsTab(controller: controller),
                  ],
                ),
              ),
            ),
            _RadioMiniPlayer(radioController: radioController),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// YENİ WIDGET: Radyo Mini Player (Ekran En Altında)
// ════════════════════════════════════════════════════════════════════════════

class _RadioMiniPlayer extends StatelessWidget {
  final UniversityRadioController radioController;
  const _RadioMiniPlayer({required this.radioController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!radioController.isRadioActive) return const SizedBox.shrink();

      final meta = radioController.metadata.value;
      final titleText =
          meta?.title ?? radioController.currentPlayingName.value ?? 'Yayın';
      final artistText = meta?.artist ?? 'Canlı Yayın';

      return Container(
        decoration: BoxDecoration(
          color: AppTheme.isDark(context)
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, -2.h),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: radioController.currentPlayingLogo.value != null
                      ? CachedNetworkImage(
                          imageUrl: radioController.currentPlayingLogo.value!,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.radio_rounded,
                          color: AppTheme.primaryColor,
                          size: 24.sp,
                        ),
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPri(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        artistText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppTheme.textSec(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                if (radioController.isBuffering)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                else ...[
                  IconButton(
                    icon: Icon(
                      radioController.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppTheme.primaryColor,
                      size: 36.sp,
                    ),
                    onPressed: () {
                      radioController.togglePlayPause(
                        url: radioController.currentPlayingUrl.value!,
                        name: radioController.currentPlayingName.value!,
                        logoUrl: radioController.currentPlayingLogo.value,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.stop_circle_outlined,
                      color: AppTheme.textSec(context),
                      size: 28.sp,
                    ),
                    onPressed: radioController.stopRadio,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Header — Yeniden Tasarlanmış (Gradient + Glow)
// ════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final UniversityDetailController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null)
        return Container(
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        );
      final hasLogo = uni.logoUrl != null && uni.logoUrl!.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.06),
              AppTheme.bg(context).withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 56.h),
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
              child: Center(
                child: Container(
                  width: 78.w,
                  height: 78.w,
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.18),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        blurRadius: 24.r,
                        spreadRadius: 2.r,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: uni.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => Center(
                              child: SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: 32.sp,
                            ),
                          )
                        : Icon(
                            Icons.school_rounded,
                            color: AppTheme.primaryColor,
                            size: 32.sp,
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                uni.name ?? '',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPri(context),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (uni.city != null) ...[
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14.sp,
                    color: AppTheme.textSec(context),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    uni.city!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 10.h),
            Obx(() {
              if (!controller.isFavorite.value) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      size: 12.sp,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Favorilerimde',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TabBar Delegate
// ════════════════════════════════════════════════════════════════════════════

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final BuildContext context;
  const _TabBarDelegate({required this.context});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.bg(context),
      child: TabBar(
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSec(context),
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 2.5,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Hakkında'),
          Tab(text: 'Videolar'),
          Tab(text: 'Shorts'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════════════
// Hakkında Sekmesi (Radyo Kartı Entegrasyonu Yapıldı)
// ════════════════════════════════════════════════════════════════════════════

class _AboutTab extends StatelessWidget {
  final UniversityDetailController controller;
  final UniversityRadioController radioController;
  const _AboutTab({required this.controller, required this.radioController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) return const Center(child: CircularProgressIndicator());
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final isFav = controller.isFavorite.value;
              final isLoading = controller.isFavoriteLoading.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : controller.toggleFavorite,
                  icon: isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isFav
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 18.sp,
                        ),
                  label: Text(
                    isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFav
                        ? AppTheme.card(context)
                        : AppTheme.primaryColor,
                    foregroundColor: isFav
                        ? AppTheme.primaryColor
                        : Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      side: isFav
                          ? BorderSide(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.5,
                              ),
                            )
                          : BorderSide.none,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(height: 20.h),
            _SectionTitle(title: 'Açıklama'),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppTheme.isDark(context)
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: ReadMoreText(
                (uni.description != null && uni.description!.isNotEmpty)
                    ? uni.description!
                    : 'Bu üniversite için açıklama bulunmuyor.',
                trimMode: TrimMode.Line,
                trimLines: 5,
                trimCollapsedText: ' Daha fazla',
                trimExpandedText: ' Daha az',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppTheme.textSec(context),
                  height: 1.6,
                  fontStyle:
                      (uni.description != null && uni.description!.isNotEmpty)
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
                moreStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
                lessStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _SectionTitle(title: 'Genel Bilgiler'),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppTheme.isDark(context)
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    label: 'Şehir',
                    value: uni.city ?? '—',
                    isFirst: true,
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Kuruluş Yılı',
                    value: uni.foundedYear != null ? '${uni.foundedYear}' : '—',
                  ),
                  _InfoRow(
                    icon: Icons.play_circle_rounded,
                    label: 'Video Sayısı',
                    value: uni.videoCount != null ? '${uni.videoCount}' : '—',
                  ),
                  _InfoRow(
                    icon: Icons.people_rounded,
                    label: 'Abone Sayısı',
                    value: uni.subscriberCount != null
                        ? controller.formattedSubscriberCount
                        : '—',
                  ),
                  _InfoRow(
                    icon: Icons.visibility_rounded,
                    label: 'Toplam İzlenme',
                    value: uni.viewCount != null
                        ? controller.formattedViewCount
                        : '—',
                    isLast: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            if (uni.websiteUrl != null ||
                uni.customUrl != null ||
                (uni.radioLink != null && uni.radioLink!.isNotEmpty)) ...[
              _SectionTitle(title: 'Bağlantılar'),
              SizedBox(height: 8.h),
              if (uni.websiteUrl != null && uni.websiteUrl!.isNotEmpty)
                _LinkButton(
                  icon: Icons.language_rounded,
                  label: 'Resmi Web Sitesi',
                  url: uni.websiteUrl!,
                ),
              if (uni.customUrl != null && uni.customUrl!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _LinkButton(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'YouTube Kanalı',
                  url: 'https://www.youtube.com/${uni.customUrl}',
                  color: const Color(0xFFFF0000),
                ),
              ],

              if (uni.radioLink != null && uni.radioLink!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _RadioInlineCard(
                  university: uni,
                  radioController: radioController,
                ),
              ],
              SizedBox(height: 20.h),
            ],

            if (uni.channelId != null) ...[
              _SectionTitle(title: 'YouTube Kanalı'),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppTheme.isDark(context)
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.tag_rounded,
                      label: 'Kanal ID',
                      value: uni.channelId!,
                      isFirst: true,
                      isLast: uni.channelSyncedAt == null,
                    ),
                    if (uni.channelSyncedAt != null)
                      _InfoRow(
                        icon: Icons.sync_rounded,
                        label: 'Son Senkronizasyon',
                        value: _formatDate(uni.channelSyncedAt!),
                        isLast: true,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// YENİ WIDGET: Inline Radyo Kartı (Hakkında Sekmesinde)
// ════════════════════════════════════════════════════════════════════════════

class _RadioInlineCard extends StatelessWidget {
  final dynamic university; // UniversityModel
  final UniversityRadioController radioController;

  const _RadioInlineCard({
    required this.university,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isThisPlaying =
          radioController.currentPlayingUrl.value == university.radioLink;
      final bool buffering = isThisPlaying && radioController.isBuffering;
      final bool playing = isThisPlaying && radioController.isPlaying;

      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isThisPlaying
                ? [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    AppTheme.card(context),
                  ]
                : [AppTheme.card(context), AppTheme.card(context)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isThisPlaying
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                : AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (playing || buffering)
                    _RadioWaveAnimation(isActive: playing),
                  Icon(
                    buffering
                        ? Icons.hdr_weak_rounded
                        : (playing
                              ? Icons.equalizer_rounded
                              : Icons.radio_rounded),
                    color: const Color(0xFF8B5CF6),
                    size: 22.sp,
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Üniversite Radyosu',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPri(context),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isThisPlaying
                        ? (playing
                              ? 'Canlı Yayın Dinleniyor...'
                              : (buffering
                                    ? 'Yayına Bağlanılıyor...'
                                    : 'Yayın Duraklatıldı'))
                        : 'Canlı yayını dinlemek için tıklayın',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: isThisPlaying
                          ? const Color(0xFF8B5CF6)
                          : AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24.r),
                onTap: () {
                  radioController.togglePlayPause(
                    url: university.radioLink,
                    name: university.name,
                    logoUrl: university.logoUrl,
                  );
                },
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: isThisPlaying
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: isThisPlaying
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4.h),
                            ),
                          ]
                        : null,
                  ),
                  child: buffering
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isThisPlaying
                              ? Colors.white
                              : const Color(0xFF8B5CF6),
                          size: 24.sp,
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Radyo çalarken arka planda oluşan dalga animasyonu
class _RadioWaveAnimation extends StatelessWidget {
  final bool isActive;
  const _RadioWaveAnimation({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 400 + (index * 150)),
            width: 3.w,
            height: isActive ? (20.h + (index % 2 == 0 ? 10.h : 0)) : 6.h,
            margin: EdgeInsets.symmetric(horizontal: 1.5.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          );
        }),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPri(context),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(icon, size: 17.sp, color: AppTheme.primaryColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppTheme.textSec(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppTheme.textPri(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 14.w,
            endIndent: 14.w,
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
      ],
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color? color;
  const _LinkButton({
    required this.icon,
    required this.label,
    required this.url,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppTheme.primaryColor;
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri))
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(icon, size: 17.sp, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPri(context),
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: 16.sp,
              color: AppTheme.textSec(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Videolar Sekmesi
// ════════════════════════════════════════════════════════════════════════════

class _VideosTab extends StatelessWidget {
  final UniversityDetailController controller;
  const _VideosTab({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final videoList = controller.videoOnly;
      if (isLoading)
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: 6,
          itemBuilder: (_, __) => _VideoShimmer(),
        );
      if (error.isNotEmpty)
        return _ErrorView(error: error, onRetry: controller.loadVideos);
      if (videoList.isEmpty)
        return const _EmptyView(
          icon: Icons.videocam_off_rounded,
          title: 'Henüz video yok',
          subtitle: 'Bu üniversiteye ait video bulunamadı.',
        );
      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadVideos,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
          itemCount: videoList.length,
          itemBuilder: (_, i) => VideoCardWidget(video: videoList[i]),
        ),
      );
    });
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Shorts Sekmesi
// ════════════════════════════════════════════════════════════════════════════

class _ShortsTab extends StatelessWidget {
  final UniversityDetailController controller;
  const _ShortsTab({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final shortsList = controller.shortsOnly;
      if (isLoading)
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: 6,
          itemBuilder: (_, __) => const _ShortsListShimmer(),
        );
      if (error.isNotEmpty)
        return _ErrorView(error: error, onRetry: controller.loadVideos);
      if (shortsList.isEmpty)
        return const _EmptyView(
          icon: Icons.movie_filter_outlined,
          title: 'Henüz Shorts yok',
          subtitle: 'Bu üniversiteye ait shorts video bulunamadı.',
        );
      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadVideos,
        child: ListView.separated(
          padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
          itemCount: shortsList.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (_, i) => _ShortsListCard(
            video: shortsList[i],
            onTap: () => _openShortsPlayer(shortsList, i),
          ),
        ),
      );
    });
  }

  void _openShortsPlayer(List<VideoModel> shorts, int initialIndex) {
    Get.toNamed(
      AppRoutes.simpleShortsPlayer,
      arguments: {'shorts': shorts, 'initialIndex': initialIndex},
    );
  }
}

class _ShortsListCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;
  const _ShortsListCard({required this.video, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Material(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.all(10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(context),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 100.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ShortsBadge(),
                            if (video.formattedDuration.isNotEmpty) ...[
                              SizedBox(width: 6.w),
                              _DurationChip(duration: video.formattedDuration),
                            ],
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPri(context),
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (video.description.isNotEmpty)
                          Text(
                            video.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppTheme.textSec(context),
                              height: 1.3,
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: 12.sp,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              video.formattedViewCount,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: AppTheme.textSec(context),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.schedule_rounded,
                              size: 11.sp,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              timeago.format(video.publishedAt, locale: 'tr'),
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: AppTheme.textSec(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: 68.w,
        height: 100.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: video.bestThumbnail,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE8E8E8),
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE8E8E8),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: 24.sp,
                ),
              ),
            ),
            Center(
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill_rounded,
            size: 10.sp,
            color: Colors.white,
          ),
          SizedBox(width: 2.w),
          Text(
            'SHORTS',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String duration;
  const _DurationChip({required this.duration});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        duration,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSec(context),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Yardımcı Widget'lar
// ════════════════════════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: AppTheme.textSec(context),
            ),
            SizedBox(height: 16.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSec(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 18.sp),
              label: Text('Tekrar Dene', style: TextStyle(fontSize: 13.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyView({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36.sp, color: AppTheme.textSec(context)),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPri(context),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.textSec(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

class _ShortsListShimmer extends StatelessWidget {
  const _ShortsListShimmer();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
