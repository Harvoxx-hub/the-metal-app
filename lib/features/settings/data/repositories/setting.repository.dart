import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';

import '../../domain/repositories/isetting_repository.dart';

class SettingRepository implements ISettingRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> blockUser(String id, String userName) async {
    try {
      final response = await _apiService.post(
        "user/block-user",
        body: {
          "name": userName,
          "id": id,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getBlockedUsers() async {
    try {
      final response = await _apiService.get(
        "user/get-blocked-user",
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> unBlockUser(String id) async {
    try {
      final response = await _apiService.post(
        "user/block-user",
        body: {
          "id": id,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final settingRepositoryProvider = Provider((ref) {
  return SettingRepository();
});
