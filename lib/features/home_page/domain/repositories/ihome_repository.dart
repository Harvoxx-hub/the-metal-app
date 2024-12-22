import 'package:metal/core/model/responces.dart';
import 'package:metal/features/home_page/domain/entries/melt.request.model.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

abstract class IHomeRepository {
  Future<Responses> getUserByUsername({
    required String username,
  });

  Future<Responses> meltUser(MeltRequestModel melt);
  Future<Responses> sendThought(ThoughtModel thought);
  Future<Responses> reactThought({
    required String thoughtId,
    required String userId,
    required String emoji,
  });
  Future markUserOnline(String userId);

  Future<Responses> getThoughtForYou();
  Future<Responses> getThoughtExplore();
  Future<Responses> getThoughtById(String id);
  Future<Responses> getThoughtsByUserId(String id);
  Future<Responses> unMeltUser(String userToMelt);
  Stream<Responses> fetchConnections({String? userId});
  Future<Responses> checkMelt({required String user2Id});
  Future markUserOffline(String userId);
}
