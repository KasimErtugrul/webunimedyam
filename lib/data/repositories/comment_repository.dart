import '../datasources/remote/supabase_datasource.dart';
import '../models/comment_model.dart';

class CommentRepository {
  final SupabaseDataSource _supabase;

  CommentRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  Future<List<CommentModel>> getComments(String videoId) async {
    return await _supabase.getComments(videoId);
  }

  Future<void> addComment({
    required String userId,
    required String videoId,
    required String content,
  }) async {
    await _supabase.addComment(userId, videoId, content);
  }

  Future<void> deleteComment(String commentId) async {
    await _supabase.deleteComment(commentId);
  }

  Future<void> updateComment(String commentId, String content) async {
    await _supabase.updateComment(commentId, content);
  }
}