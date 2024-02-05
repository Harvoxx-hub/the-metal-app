import 'package:metal/core/model/responces.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

abstract class IAuthenticationRepository {
  Future<Responses> signUp({
    required String email,
    required String password,
    required String phoneNumber,
  });

  Future<Responses> logIn({
    required String email,
    required String password,
  });

  Future<Responses> forgotPassword({
    required String email,
  });

  Future<Responses> activateAccount();

  Future<Responses> getCurrentUser();

  // get metal properties
  Future<Responses> getMetalProperties();

  Future<Responses> updateUser(
    UserModel user,
  );

  //get user by

  //verifi
}
