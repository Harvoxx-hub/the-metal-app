import 'package:metal/core/model/responces.dart';
import 'package:metal/features/thought/data/domain/entries/melt.request.model.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

abstract class IHomeRepository {
  Future<Responses> getUserByUsername({
    required String username,
  });

  Future<Responses> meltUser(MeltRequestModel melt);
  Future<Responses> sendThought(ThoughtModel thought);
  Future<Responses> sendVoiceThought(
      {required ThoughtModel thought,
      required String storagePath,
      required String localFilePath});
  Future markUserOnline(String userId);

  Future<Responses> getThoughtForYou();
  Future<Responses> getThoughtExplore();
  Future<Responses> getThoughtById(String id);
  Future<Responses> deleteThoughtById(String id);
  Future<Responses> getThoughtsByUserId(String id);
  Future<Responses> createRepost({required String originalThoughtId});
  Future<Responses> unMeltUser(String userToMelt);
  Future<Responses> deMeltUser(String userToMelt);
  Stream<Responses> fetchConnections({String? userId});
  Future<Responses> checkMelt({required String user2Id});
  Future markUserOffline(String userId);
  Future<Responses> getConnection(String connectionId);
}
