import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';
import 'package:metal/core/services/auth.pref.service.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/domain/repositories/iauthetication_repository.dart';

class AuthenticationRepository implements IAuthenticationRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post(
        "auth/forgot-password",
        body: {
          "email": email,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> logIn(
      {required String email, required String password}) async {
    try {
      final response = await _apiService.post(
        "auth/login",
        body: {
          "username": email,
          "password": password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> signUp(
      {required String email,
      required String password,
      required String phoneNumber}) async {
    try {
      final response = await _apiService.post(
        "auth/signup",
        body: {
          "email": email,
          "password": password,
          "phone": phoneNumber,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> activateAccount(String UUID) async {
    try {
      final response = await _apiService.patch("auth/activate-account",
          body: {"UUID": UUID});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getCurrentUser() async {
    try {
      final response = await _apiService.get("user/current-user");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> updateUser(Map<String, dynamic> user) async {
    try {
      final response =
          await _apiService.patch("user/update-info", body: user );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getMetalProperties() async {
    try {
      final response = await _apiService.get("metal-properties/all");
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final authenticationRepositoryProvider = Provider((ref) {
  return AuthenticationRepository();
});
