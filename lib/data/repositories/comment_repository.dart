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
      final comments = await _supabase.getComments(videoId);
      return comments;
    } catch (e, stacktrace) {
      log(
        'Yorumlar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    try {
      await _supabase.addComment(userId, videoId, content);
    } catch (e, stacktrace) {
      log('Yorum eklenirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _supabase.deleteComment(commentId);
    } catch (e, stacktrace) {
      log('Yorum silinirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      rethrow;
    }
  }

  Future<void> updateComment(String commentId, String content) async {
    try {
      await _supabase.updateComment(commentId, content);
    } catch (e, stacktrace) {
      log(
        'Yorum güncellenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }
}
