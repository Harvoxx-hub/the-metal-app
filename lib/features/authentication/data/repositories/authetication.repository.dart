import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';
import 'package:metal/features/authentication/domain/repositories/iauthetication_repository.dart';

class AuthenticationRepository implements IAuthenticationRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Response> forgotPassword({required String email}) {
    // TODO: implement forgotPassword
    throw UnimplementedError();
  }

  @override
  Future<Response> logIn({required String email, required String password}) {
    // TODO: implement logIn
    throw UnimplementedError();
  }

  @override
  Future<Response> signUp(
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
      throw e;
    }
  }
}

final authenticationRepositoryProvider = Provider((ref) {
  return AuthenticationRepository();
});
