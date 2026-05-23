import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/comment_model.dart';

class CommentRepository {
  final SupabaseDataSource _supabase;

  CommentRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────
  // İnternet yoksa uygulama çökmemeli, boş liste dönmeli. UI "Yorum yok" gösterir.
  
  Future<List<CommentModel>> getComments(String videoId) async {
    try {
      log('💬☁️ [Yorum] Video yorumları Supabase\'den çekiliyor → $videoId');
      final comments = await _supabase.getComments(videoId);
      log('💬✅ [Yorum] ${comments.length} yorum geldi');
      return comments;
    } catch (e) {
      log('💬❌ [Yorum] Yorumlar yüklenemedi (offline?): $e');
      return []; // Hata yutma değil, offline güvenliği. UI çökmez, boş liste döner.
    }
  }

  // ─── YAZMA İŞLEMLERİ (Write) ──────────────────────────────────────────────
  // Bu metotlarda try-catch YOK. Eğer yorum eklenemezse/silenemezse Controller 
  // bunu yakalayıp kullanıcıya "Yorum eklenemedi" snackback'ini göstermelidir.
  
  Future<void> addComment({
    required String userId,
    required String videoId,
    required String content,
  }) async {
    log('💬➕☁️ [Yorum] Yeni yorum ekleniyor → video: $videoId');
    await _supabase.addComment(userId, videoId, content);
    log('💬✅ [Yorum] Yorum eklendi');
  }

  Future<void> deleteComment(String commentId) async {
    log('💬🗑️☁️ [Yorum] Yorum siliniyor → $commentId');
    await _supabase.deleteComment(commentId);
    log('💬✅ [Yorum] Yorum silindi');
  }

  Future<void> updateComment(String commentId, String content) async {
    log('💬✏️☁️ [Yorum] Yorum güncelleniyor → $commentId');
    await _supabase.updateComment(commentId, content);
    log('💬✅ [Yorum] Yorum güncellendi');
  }
}