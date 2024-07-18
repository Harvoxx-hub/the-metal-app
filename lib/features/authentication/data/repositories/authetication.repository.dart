import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';
import 'package:metal/fcm/fcm_client.dart';

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
      String? token = await FCMClient.instance.init();
      final response = await _apiService.post(
        "auth/login",
        body: {
          "username": email,
          "password": password,
          "fcmToken": token ?? ""
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
      required String phoneNumber,
      String? referal,
      }) async {
    try {
      String? token = await FCMClient.instance.init();
      final response = await _apiService.post(
        "auth/signup",
        body: {
          "email": email,
          "password": password,
          "phone": phoneNumber,
          "fcmToken": token ?? "",
          "reff_By": referal?? "",
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
      final response = await _apiService
          .patch("auth/activate-account", body: {"UUID": UUID});
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
      final response = await _apiService.patch("user/update-info", body: user);
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

  @override
  Future<Responses> completeUser(Map<String, dynamic> user) async {
    try {
      final response =
          await _apiService.patch("user/complete-profile", body: user);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> DeleteUser() async {
    try {
      final response = await _apiService.post("user/delete-account", body: {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getUserByID({required String id}) async {
    try {
      final response = await _apiService.get("user/user-by-id/$id");
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> UpdateParticualarInfo(Map<String, dynamic> update) async {
    try {
      final response =
          await _apiService.post("user/update-particular-info", body: update);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> uploadProfileImage(File image) async {
    try {
      final response = await _apiService.post(
        'user/upload-profile-image',
        formData: FormData.fromMap({
          "file": await MultipartFile.fromFile(image.path),
        }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final authenticationRepositoryProvider = Provider((ref) {
  return AuthenticationRepository();
});
