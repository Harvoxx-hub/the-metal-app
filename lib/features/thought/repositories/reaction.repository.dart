import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/thought/data/domain/entries/reaction.model.dart';
import 'package:metal/features/thought/data/domain/repositories/ireaction.repository.dart';

class ReactionRepository implements IReactionRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
  Future<Responses> getReactions(String thoughtId) async {
    try {
      final reactions = await _firebaseService.readCollection(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/reactions',
      );
      return Responses(success: true, data: reactions);
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }

  /// Get real-time reactions stream for a thought
  Stream<List<ReactionModel>> getReactionsStream(String thoughtId) {
    try {
      return _firebaseService
          .listenToCollection(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/reactions',
      )
          .map((reactionMaps) {
        return reactionMaps
            .map((reactionMap) => ReactionModel.fromJson(reactionMap))
            .toList();
      });
    } catch (e) {
      print('Error getting reactions stream: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<Responses> addReaction(String thoughtId, String emoji) async {
    try {
      final userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(success: false, message: "User not logged in");
      }

      // Check if user already has a reaction
      final existingReaction = await getUserReaction(thoughtId, userId);
      if (existingReaction.success == true && existingReaction.data != null) {
        final reaction = ReactionModel.fromJson(existingReaction.data);
        // If clicking the same emoji, remove the reaction (unreact)
        if (reaction.emoji == emoji) {
          return deleteReaction(thoughtId, reaction.id);
        } else {
          // Otherwise, update to the new emoji
          return updateReaction(thoughtId, reaction.id, emoji);
        }
      }

      final reaction = ReactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        thoughtId: thoughtId,
        emoji: emoji,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _firebaseService.createDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/reactions',
        data: reaction.toJson(),
        documentId: reaction.id,
      );

      return Responses(success: true, message: "Reaction added successfully");
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }

  @override
  Future<Responses> updateReaction(
      String thoughtId, String reactionId, String emoji) async {
    try {
      await _firebaseService.updateDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/reactions',
        documentId: reactionId,
        data: {'emoji': emoji},
      );
      return Responses(success: true, message: "Reaction updated successfully");
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }

  @override
  Future<Responses> deleteReaction(String thoughtId, String reactionId) async {
    try {
      await _firebaseService.deleteDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/reactions',
        documentId: reactionId,
      );
      return Responses(success: true, message: "Reaction deleted successfully");
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }

  @override
  Future<Responses> getUserReaction(String thoughtId, String userId) async {
    try {
      final reactions = await _firebaseService.queryCollection(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.thoughts}/$thoughtId/reactions',
        field: 'userId',
        value: userId,
      );

      if (reactions.isEmpty) {
        return Responses(success: true, data: null);
      }

      return Responses(success: true, data: reactions.first);
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }
}

final reactionRepositoryProvider = Provider((ref) => ReactionRepository());
