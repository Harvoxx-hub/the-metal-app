import 'package:metal/core/model/responces.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

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

  Future<Responses> meltUser(String userToMelt);
  Future<Responses> unMeltUser(String userToMelt);
  Future<Responses> getMeltedUsers();
  Future<Responses> likeUser( {required String userToLike});
  Future<Responses> unLikeUser( {required String userToLike});
}
