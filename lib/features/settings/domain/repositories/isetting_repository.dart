import 'package:metal/core/model/responces.dart';

abstract class ISettingRepository {
  Future<Responses> blockUser(String id, String userName);
  Future<Responses> unBlockUser(String id);
  Future<Responses> getBlockedUsers();
}
