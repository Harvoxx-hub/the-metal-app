import 'package:metal/core/model/responces.dart';

abstract class IAuthenticationRepository {
  Future<Response> signUp({
    required String email,
    required String password,
    required String phoneNumber,
  });

  Future<Response> logIn({
    required String email,
    required String password,
  });

  Future<Response> forgotPassword({
    required String email,
  });
}
