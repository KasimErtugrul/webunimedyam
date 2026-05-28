import 'dart:developer';
import 'dart:async';
import 'package:get/get.dart';

import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

/// Event sınıfı – favori değişikliklerini taşır
class FavoriteChange {
  final String videoId;
  final bool isFavorite; // true: eklendi, false: silindi
  final VideoModel? video; // video objesi (ekleme durumunda kullanılır)

  FavoriteChange({required this.videoId, required this.isFavorite, this.video});
}

class FavoritesRepository extends GetxService {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  // Broadcast stream – birden çok dinleyiciye izin verir
  final _favoriteChangeController = StreamController<FavoriteChange>.broadcast();
  Stream<FavoriteChange> get onFavoriteChanged => _favoriteChangeController.stream;

  FavoritesRepository({
    required SupabaseDataSource supabase,
    required LocalDataSource local,
  })  : _supabase = supabase,
        _local = local;

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────

  Future<List<VideoModel>> getFavoriteVideos() async {
    try {
      log('❤️💾 [Favori] Favori videolar LOCAL\'den okunuyor...');
      final videos = await _local.getFavoriteVideos();
      log('❤️✅ [Favori] ${videos.length} favori video bulundu (local)');
      return videos;
    } catch (e) {
      log('❤️❌ [Favori] Local favoriler okunamadı: $e');
      return [];
    }
  }

  Future<List<VideoModel>> getUserFavoriteVideos(String userId) async {
    try {
      final localFavorites = await _local.getFavoriteVideos();
      if (localFavorites.isNotEmpty) {
        log('❤️💾 [Favori] Profil favorileri LOCAL\'den geldi');
        return localFavorites;
      }
      log('❤️☁️ [Favori] Local boş, Supabase\'den çekiliyor → $userId');
      final remoteFavorites = await _supabase.getUserFavoriteVideos(userId);
      if (remoteFavorites.isNotEmpty) {
        for (var video in remoteFavorites) {
          await _local.saveFavoriteVideo(video);
        }
        log('❤️💾 [Favori] Supabase\'den gelen ${remoteFavorites.length} favori local\'e yazıldı');
      }
      return remoteFavorites;
    } catch (e) {
      log('❤️❌ [Favori] Profil favorileri yüklenemedi: $e');
      return [];
    }
  }

  // lib/data/repositories/favorites_repository.dart
Future<List<String>> getFavoriteVideoIds(String userId) async {
  try {
    // 1. Önce local'e bak — video nesneleri zaten cache'deyse ID'leri oradan çek
    final localVideos = await _local.getFavoriteVideos();
    if (localVideos.isNotEmpty) {
      log('❤️💾 [Favori] ID\'ler LOCAL\'den geldi (${localVideos.length} adet)');
      return localVideos.map((v) => v.videoId).toList();
    }

    // 2. Local boşsa Supabase'e git
    log('❤️☁️ [Favori] Favori ID\'leri Supabase\'den çekiliyor → $userId');
    final ids = await _supabase.getFavoriteVideoIds(userId);
    log('❤️✅ [Favori] ${ids.length} favori ID geldi (remote)');
    return ids;
  } catch (e) {
    log('❤️❌ [Favori] Favori ID\'leri çekilemedi (offline?): $e');
    return [];
  }
}

  // ─── YAZMA İŞLEMLERİ (Write) ──────────────────────────────────────────────

  Future<void> saveFavoriteVideoLocally(VideoModel video) async {
    log('❤️💾➕ [Favori] Video local\'e kaydediliyor → ${video.videoId}');
    await _local.saveFavoriteVideo(video);
    // Event yayınla (local write sonrası diğer controller'lar haberdar olur)
    _favoriteChangeController.add(FavoriteChange(
      videoId: video.videoId,
      isFavorite: true,
      video: video,
    ));
  }

  Future<void> removeFavoriteVideoLocally(String videoId) async {
    log('❤️💾🗑️ [Favori] Video local\'den siliniyor → $videoId');
    await _local.removeFavoriteVideo(videoId);
    // Event yayınla (local write sonrası diğer controller'lar haberdar olur)
    _favoriteChangeController.add(FavoriteChange(
      videoId: videoId,
      isFavorite: false,
    ));
  }

  Future<void> clearLocalFavorites() async {
    log('❤️🧹 [Favori] Tüm local favoriler temizleniyor');
    await _local.clearFavoriteVideos();
    // Toplu temizlik için event göndermiyoruz, dinleyiciler kendi kendilerini yenileyebilir
  }

  Future<void> addFavorite(String userId, String videoId) async {
    log('❤️☁️➕ [Favori] Favori Supabase\'e ekleniyor → $videoId');
    await _supabase.addFavorite(userId, videoId);
    log('❤️✅ [Favori] Favori eklendi (remote)');
    // Event YAYINLANMIYOR — local write (saveFavoriteVideoLocally) zaten event gönderecek.
    // Çift event ve gereksiz rebuild önlenmiş oldu.
  }

  Future<void> removeFavorite(String userId, String videoId) async {
    log('❤️☁️🗑️ [Favori] Favori Supabase\'den siliniyor → $videoId');
    await _supabase.removeFavorite(userId, videoId);
    log('❤️✅ [Favori] Favori silindi (remote)');
    // Event YAYINLANMIYOR — local write (removeFavoriteVideoLocally) zaten event gönderecek.
    // Çift event ve gereksiz rebuild önlenmiş oldu.
  }

  @override
  void onClose() {
    _favoriteChangeController.close();  // ← @override ile otomatik çağrılır
    super.onClose();
  }
}