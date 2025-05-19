import 'package:metal/core/model/responces.dart';
import 'package:metal/features/home_page/domain/entries/comment.model.dart';

abstract class ICommentRepository {
  Future<Responses> getComments(String thoughtId);
  Future<Responses> addComment(String thoughtId, String content);
  Future<Responses> deleteComment(String thoughtId, String commentId);
  Future<Responses> reactToComment(
      String thoughtId, String commentId, String emoji);
}
