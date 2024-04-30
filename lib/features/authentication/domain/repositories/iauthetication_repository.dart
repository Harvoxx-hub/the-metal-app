import 'dart:io';

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

  Future<Responses> activateAccount(
    String UUID,
  );

  Future<Responses> getCurrentUser();
  Future<Responses> getUserByID(
    {
      required String id
    }
  );
  // get metal properties
  Future<Responses> getMetalProperties();

  Future<Responses> updateUser(
    Map<String, dynamic>  user,
  );

   Future<Responses> completeUser(
    Map<String, dynamic>  user,
  );
   Future<Responses> DeleteUser(
    
  );

    Future<Responses> UpdateParticualarInfo(
     Map<String, dynamic>  update,
  );
    Future<Responses> uploadProfileImage(
     File  image,
  );




  //get user by

  //verifi
}
