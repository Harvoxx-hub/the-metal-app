import 'package:metal/core/model/responces.dart';
import 'package:metal/features/thought/data/domain/entries/reaction.model.dart';

abstract class IReactionRepository {
  Future<Responses> getReactions(String thoughtId);
  Stream<List<ReactionModel>> getReactionsStream(String thoughtId);
  Future<Responses> addReaction(String thoughtId, String emoji);
  Future<Responses> updateReaction(
      String thoughtId, String reactionId, String emoji);
  Future<Responses> deleteReaction(String thoughtId, String reactionId);
  Future<Responses> getUserReaction(String thoughtId, String userId);
}
