import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';

import '../../domain/repositories/ihome_repository.dart';

class HomeRepository implements IHomeRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> getUserByUsername({required String username}) async {
    try {
      final response = await _apiService.get("user/get-by-username/$username");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getALLUser(String distance) async {
    try {
      final response = await _apiService.get("user/all-users");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getMeltedUsers() async {
    try {
      final response = await _apiService.get("melt/all-mets");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> likeUser({required String userToLike}) async {
    try {
      final response = await _apiService.post("melt/like", body: {
        "userToLike": userToLike,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> meltUser(String userToMelt) async {
    try {
      final response = await _apiService.post("melt/melt", body: {
        "userToMelt": userToMelt,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> unLikeUser({required String userToLike}) async {
    try {
      final response = await _apiService.post("melt/unlike", body: {
        "userToLike": userToLike,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> unMeltUser(String userToMelt) async {
    try {
      final response = await _apiService.post("melt/unmelt", body: {
        "userToMelt": userToMelt,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getUserById({required String id}) async {
    try {
      final response = await _apiService.get("user/user-by-id/$id");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getUserByPhone({required String phone}) async {
    try {
      final response = await _apiService.get("user/get-by-phone/$phone");
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<Responses> pushUser(String userToPush) async {
    try {
      final response = await _apiService.post("melt/push", body: {
        "userToPush": userToPush,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final homeRepositoryProvider = Provider((ref) {
  return HomeRepository();
});
