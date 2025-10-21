import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/thought/data/domain/entries/comment.model.dart';
import 'package:metal/features/thought/data/domain/repositories/icomment.repository.dart';

class CommentRepository implements ICommentRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
  Future<Responses> getComments(String thoughtId) async {
    try {
      final comments = await _firebaseService.readCollection(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/comments',
      );
      return Responses(success: true, data: comments);
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }

  /// Get real-time comments stream for a thought
  @override
  Stream<List<CommentModel>> getCommentsStream(String thoughtId) {
    try {
      return _firebaseService
          .listenToCollection(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/comments',
      )
          .map((commentMaps) {
        return commentMaps
            .map((commentMap) => CommentModel.fromJson(commentMap))
            .toList();
      });
    } catch (e) {
      print('Error getting comments stream: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<Responses> addComment(CommentModel comment) async {
    try {
      await _firebaseService.createDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/${comment.thoughtId}/comments',
        data: comment.toJson(),
        documentId: comment.id,
      );

      return Responses(success: true, message: "Comment added successfully");
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }

  @override
  Future<Responses> deleteComment(String thoughtId, String commentId) async {
    try {
      await _firebaseService.deleteDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/comments',
        documentId: commentId,
      );
      return Responses(success: true, message: "Comment deleted successfully");
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }

  @override
  Future<Responses> reactToComment(
      String thoughtId, String commentId, String emoji) async {
    try {
      final userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(success: false, message: "User not logged in");
      }

      // Get current comment
      final commentData = await _firebaseService.readDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/comments',
        documentId: commentId,
      );

      if (commentData == null) {
        return Responses(success: false, message: "Comment not found");
      }

      final comment = CommentModel.fromJson(commentData);

      // Add or update reaction
      final existingReactionIndex =
          comment.reactions.indexWhere((r) => r.userId == userId);
      final reactions = List.of(comment.reactions);

      if (existingReactionIndex != -1) {
        reactions[existingReactionIndex] =
            ReactionModel(userId: userId, emoji: emoji);
      } else {
        reactions.add(ReactionModel(userId: userId, emoji: emoji));
      }

      // Update comment with new reactions
      await _firebaseService.updateDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/comments',
        documentId: commentId,
        data: {'reactions': reactions.map((r) => r.toJson()).toList()},
      );

      return Responses(success: true, message: "Reaction added successfully");
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }
}

final commentRepositoryProvider = Provider((ref) {
  return CommentRepository();
});
