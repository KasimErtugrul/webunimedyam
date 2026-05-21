import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/themes/app_theme.dart';
import '../../../data/models/playlist_model.dart';
import '../../../data/models/video_model.dart';
import '../../../data/repositories/video_repository.dart';
import '../home/widgets/tabs/home_tab/widgets/video_card_widget.dart'; // VideoCardWidget import edildi

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late final PlaylistModel playlist;
  late final VideoRepository _videoRepository;

  List<VideoModel> _videos = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    playlist = Get.arguments as PlaylistModel;
    _videoRepository = Get.find<VideoRepository>();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      final videos = await _videoRepository.getPlaylistVideos(
        playlist.playlistId,
      );
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Videolar yüklenemedi.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: CustomScrollView(
        slivers: [
          // ── Zenginleştirilmiş Üst Alan (SliverAppBar) ─────────────────────
          SliverAppBar(
            expandedHeight: 260.h,
            pinned: true,
            backgroundColor: AppTheme.bg(context),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPri(context),
                size: 24.sp,
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Arka plan thumbnail (karartmalı)
                  if (playlist.thumbnailUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: playlist.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        color: AppTheme.surface(context),
                        child: Icon(
                          Icons.playlist_play_rounded,
                          color: AppTheme.textSec(context),
                          size: 64.sp,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.playlist_play_rounded,
                        color: AppTheme.textSec(context),
                        size: 64.sp,
                      ),
                    ),

                  // Alt gradient (videolardaki gibi)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 120.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppTheme.bg(context).withValues(alpha: 0.95),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Üst gradient (isteğe bağlı, daha soft)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 80.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // "OYNA LİSTESİ" rozeti (sol üst)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.4),
                            blurRadius: 8.r,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.playlist_play_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 14.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'OYNA LİSTESİ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Başlık + video sayısı (altta, modern)
                  Positioned(
                    bottom: 20.h,
                    left: 20.w,
                    right: 20.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.title,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6.r,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.video_library_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '${playlist.itemCount} video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
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
          ),

          // ── Video Listesi (Artık VideoCardWidget ile) ─────────────────────
          if (_isLoading)
            SliverToBoxAdapter(child: _buildShimmer())
          else if (_error.isNotEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: 48.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        _error,
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(100.w, 40.h),
                        ),
                        onPressed: _loadVideos,
                        child: Text(
                          'Tekrar Dene',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_videos.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Text(
                    'Bu oynatma listesinde video bulunmuyor.',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => VideoCardWidget(video: _videos[index]),
                childCount: _videos.length,
              ),
            ),
        ],
      ),
    );
  }

  // ── VideoCardWidget uyumlu Shimmer ───────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail alanı (200px)
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    color: AppTheme.surface(context),
                  ),
                  // İçerik alanı
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo + üniversite adı
                        Row(
                          children: [
                            Container(
                              width: 38.w,
                              height: 38.h,
                              decoration: BoxDecoration(
                                color: AppTheme.surface(context),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Container(
                                height: 14.h,
                                color: AppTheme.surface(context),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        // Başlık placeholder
                        Container(
                          height: 16.h,
                          width: double.infinity,
                          color: AppTheme.surface(context),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          height: 14.h,
                          width: 200.w,
                          color: AppTheme.surface(context),
                        ),
                        SizedBox(height: 14.h),
                        // İstatistik satırı
                        Row(
                          children: [
                            Container(
                              width: 60.w,
                              height: 12.h,
                              color: AppTheme.surface(context),
                            ),
                            const Spacer(),
                            Container(
                              width: 50.w,
                              height: 12.h,
                              color: AppTheme.surface(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}