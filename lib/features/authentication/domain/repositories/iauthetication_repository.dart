import 'dart:io';

import 'package:metal/core/model/responces.dart';

abstract class IAuthenticationRepository {
  Future<Responses> signUp(
      {required String email,
      required String password,
      required String phoneNumber,
      String? referal});

  Future<Responses> logIn({
    required String email,
    required String password,
  });

  Future<Responses> forgotPassword({
    required String email,
  });

  Future<Responses> getCurrentUser();
  Future<Responses> getUserByID({required String id});
  // get metal properties
  Future<Responses> getMetalProperties();

  Future<Responses> updateUser(
    Map<String, dynamic> user,
  );

  Future<Responses> deleteUser();

  Future<Responses> uploadProfileImage(
    File image,
  );

  Future<Responses> sendFeedback(
    String feedback,
  );

  Future<Responses> forgetPassword(
    String email,
  );

  Future<Responses> changePassword(String id, String password);
  Future<Responses> getMetals();
}
