import 'dart:developer';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

class FavoritesRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  FavoritesRepository({
    required SupabaseDataSource supabase,
    required LocalDataSource local,
  })  : _supabase = supabase,
        _local = local;

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────
  // İnternet yoksa veya local cache bozuksa uygulama çökmemeli.
  // Boş liste döner, UI "Favori yok" gösterir.

  Future<List<VideoModel>> getFavoriteVideos() async {
    try {
      log('❤️💾 [Favori] Favori videolar LOCAL\'den okunuyor...');
      final videos = await _local.getFavoriteVideos();
      log('❤️✅ [Favori] ${videos.length} favori video bulundu (local)');
      return videos;
    } catch (e) {
      log('❤️❌ [Favori] Local favoriler okunamadı: $e');
      return []; // Cache okunamazsa app çökmesin, boş liste dönsün
    }
  }

   Future<List<VideoModel>> getUserFavoriteVideos(String userId) async {
    try {
      // 1. Önce local cache'e bak
      final localFavorites = await _local.getFavoriteVideos();
      
      if (localFavorites.isNotEmpty) {
        log('❤️💾 [Favori] Profil favorileri LOCAL\'den geldi');
        return localFavorites;
      }
      
      // 2. Local boşsa (ilk kurulum/cache temizlenmesi), Supabase'den çek
      log('❤️☁️ [Favori] Local boş, Supabase\'den çekiliyor → $userId');
      final remoteFavorites = await _supabase.getUserFavoriteVideos(userId);
      
      // 3. Supabase'den gelenleri bir dahaki sefere hızlı olsun diye local'e yaz
      if (remoteFavorites.isNotEmpty) {
        for (var video in remoteFavorites) {
          await _local.saveFavoriteVideo(video); // Sırayla local'e kaydet
        }
        log('❤️💾 [Favori] Supabase\'den gelen ${remoteFavorites.length} favori local\'e yazıldı');
      }
      
      return remoteFavorites;
    } catch (e) {
      log('❤️❌ [Favori] Profil favorileri yüklenemedi: $e');
      return []; // Hata olursa boş liste dön, app çökmesin
    }
  }

  Future<List<String>> getFavoriteVideoIds(String userId) async {
    try {
      log('❤️☁️ [Favori] Favori ID\'leri Supabase\'den çekiliyor → $userId');
      final ids = await _supabase.getFavoriteVideoIds(userId);
      log('❤️✅ [Favori] ${ids.length} favori ID geldi (remote)');
      return ids;
    } catch (e) {
      log('❤️❌ [Favori] Favori ID\'leri çekilemedi (offline?): $e');
      return []; // Offline ise ID'ler bilinemez, boş döner (UI kalpleri boş gösterir ama çökmez)
    }
  }

  // ─── YAZMA İŞLEMLERİ (Write) ──────────────────────────────────────────────
  // BU METOTLARDA TRY-CATCH YOK!
  // Eğer Supabase'e favori yazılamazsa, Controller bunu yakalamalı ve 
  // UI'daki kırmızı kalbi eski haline (boş kalbe) geri döndürmelidir.

  Future<void> saveFavoriteVideoLocally(VideoModel video) async {
    log('❤️💾➕ [Favori] Video local\'e kaydediliyor → ${video.videoId}');
    await _local.saveFavoriteVideo(video);
  }

  Future<void> removeFavoriteVideoLocally(String videoId) async {
    log('❤️💾🗑️ [Favori] Video local\'den siliniyor → $videoId');
    await _local.removeFavoriteVideo(videoId);
  }

  Future<void> clearLocalFavorites() async {
    log('❤️🧹 [Favori] Tüm local favoriler temizleniyor');
    await _local.clearFavoriteVideos();
  }

  Future<void> addFavorite(String userId, String videoId) async {
    log('❤️☁️➕ [Favori] Favori Supabase\'e ekleniyor → $videoId');
    await _supabase.addFavorite(userId, videoId);
    log('❤️✅ [Favori] Favori eklendi (remote)');
  }

  Future<void> removeFavorite(String userId, String videoId) async {
    log('❤️☁️🗑️ [Favori] Favori Supabase\'den siliniyor → $videoId');
    await _supabase.removeFavorite(userId, videoId);
    log('❤️✅ [Favori] Favori silindi (remote)');
  }
}