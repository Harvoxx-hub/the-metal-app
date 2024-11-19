import 'package:metal/core/model/responces.dart';

abstract class IHomeRepository {
  Future<Responses> getUserByUsername({
    required String username,
  });
  Future<Responses> getUserById({
    required String id,
  });
  Future<Responses> getUserByPhone({
    required String phone,
  });

  Future<Responses> getALLUser(String distance);

  Future<Responses> meltUser(String userToMelt, String conversationId);
  Future<Responses> sendThought(String thought);
  Future<Responses> reactThought(
    int thoughtId,
    String reaction,
  );
  Future<Responses> getThoughtForYou();
  Future<Responses> getThoughtExplore();
  Future<Responses> getThoughtById(String id);

  Future<Responses> pushUser(String userToPush);
  Future<Responses> unMeltUser(String userToMelt);
  Future<Responses> getMeltedUsers();
  Future<Responses> likeUser({required String userToLike});
  Future<Responses> unLikeUser({required String userToLike});
  Future<Responses> checkMelt({required String userId});
}
