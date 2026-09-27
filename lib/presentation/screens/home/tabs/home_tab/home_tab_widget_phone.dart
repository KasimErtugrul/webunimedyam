// lib/presentation/screens/home/tabs/home_tab/home_tab_widget_phone.dart
//
// PHONE Home tab'ı. Ortak mantık (scroll/refresh/worker) HomeTabLogic'te,
// ortak widget'lar common/ altında. Bu dosyada yalnızca phone'a özgü
// içerik gövdesi (tam genişlik liste) duruyor.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import 'common/home_tab_logic.dart';
import 'common/home_tab_sizes.dart';
import 'common/home_tab_widgets.dart';
import 'widgets/home_feed_wheel_widget.dart';
import 'widgets/video_card_widget.dart';

class HomeTabWidgetPhone extends StatefulWidget {
  const HomeTabWidgetPhone({super.key});

  @override
  State<HomeTabWidgetPhone> createState() => _HomeTabWidgetPhoneState();
}

class _HomeTabWidgetPhoneState extends State<HomeTabWidgetPhone>
    with HomeTabLogic {
  static const PhoneHomeTabSizes _sizes = PhoneHomeTabSizes();

  @override
  HomeTabSizes get sizes => _sizes;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => maybeAutoLoadMore());

    // NOT: Bu tab, HomeScreen'in kendi Scaffold'u içinde IndexedStack ile
    // gösteriliyor; appBar/drawer/FAB burada tekrar tanımlanmadığı için
    // ayrı bir Scaffold yerine sade bir Container + SafeArea yeterli
    // (gereksiz iç içe Scaffold/Material ağacını önler).
    return Container(
      color: AppTheme.bg(context),
      child: SafeArea(
        child: RefreshIndicator(
          key: refreshIndicatorKey,
          color: Theme.of(context).colorScheme.primary,
          onRefresh: refreshHomeTab,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Üst bar (ÜniTV / KAMPÜS YAYINI) HomeScreen'in Scaffold.appBar'ında —
              // tüm sekmelerde sabit kalması için (bkz. unitv_app_bar.dart).
              ...commonSliversBeforeContent(),

              // ── İçerik Alanı ───────────────────────────────────────────
              Obx(() => _buildContentSliver(context)),

              ...commonSliversAfterContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSliver(BuildContext context) {
    if (controller.isLoading.value) {
      return SliverToBoxAdapter(child: HomeVideoShimmer(sizes: sizes));
    }

    if (controller.errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(
        child: HomeErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.loadVideos,
          sizes: sizes,
        ),
      );
    }

    final nonShorts = controller.videos.where((v) => !v.isShorts).toList();

    // FIX korunuyor: Boş sonuç durumunda da bölüm başlığı (ve filtre
    // seçici) görünür — yoksa kullanıcı filtreyi değiştiremezdi.
    if (nonShorts.isEmpty) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                sizes.contentTitlePadHorizontal,
                sizes.contentTitlePadTop,
                sizes.contentTitlePadHorizontal,
                sizes.contentTitlePadBottom,
              ),
              child: HomeContentHeader(controller: controller, sizes: sizes),
            ),
          ),
          SliverToBoxAdapter(
            child: HomeEmptyWidget(
              message: controller.feedFilter.value
                  .emptyMessage(isLoggedIn: controller.isLoggedIn),
              sizes: sizes,
            ),
          ),
        ],
      );
    }

    if (controller.isWheelView.value) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeFeedWheelWidget(
                videos: nonShorts,
                universities: controller.universities,
              ),
            ],
          ),
        ),
      );
    }

    final showLoader = controller.hasMoreVideos.value;
    final isLoadingMore = controller.isLoadingMore.value;

    // ── PHONE: Tam genişlik liste görünümü ────────────────────────────
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizes.contentTitlePadHorizontal,
              sizes.contentTitlePadTop,
              sizes.contentTitlePadHorizontal,
              sizes.contentTitlePadBottom,
            ),
            child: HomeContentHeader(controller: controller, sizes: sizes),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= nonShorts.length) {
              return isLoadingMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            return VideoCardWidget(video: nonShorts[index]);
          }, childCount: nonShorts.length + (showLoader ? 1 : 0)),
        ),
      ],
    );
  }
}