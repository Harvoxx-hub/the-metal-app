import 'package:metal/core/model/responces.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';

abstract class ICommentRepository {
  Future<Responses> getComments(String thoughtId);
  Stream<List<CommentModel>> getCommentsStream(String thoughtId);
  Future<Responses> addComment(CommentModel comment);
  Future<Responses> deleteComment(String thoughtId, String commentId);
  Future<Responses> reactToComment(
      String thoughtId, String commentId, String emoji);
}
