import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';

import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/core/utils/uuid_center.dart';
import 'package:metal/fcm/fcm_client.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

import 'package:metal/features/authentication/domain/repositories/iauthetication_repository.dart';

class AuthenticationRepository implements IAuthenticationRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> forgotPassword({required String email}) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
      return Responses(
        success: true,
        message: "Password reset email sent successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to send password reset email: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> logIn(
      {required String email, required String password}) async {
    try {
      await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String? token = await FCMClient.instance.init();

      Responses response = await updateUser({"fcmToken": token});

      return Responses(
          success: true,
          data: response.data,
          message: "Login successful, user data retrieved.");
    } catch (e) {
      return Responses(success: false, message: "Login failed: $e");
    }
  }

  @override
  Future<Responses> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    String? referal,
  }) async {
    try {
      String? token = await FCMClient.instance.init();
      var rng = new Random();
      var code = rng.nextInt(900000) + 100000;
      UserCredential userCredential =
          await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
          email: email,
          phone: phoneNumber,
          referralCode: code.toString(),
          fcmToken: token,
          referredBy: referal,
          id: userCredential.user?.uid);

      await _firebaseService.createDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.users,
          documentId: userCredential.user?.uid,
          data: user.toJson());

      return Responses(
          success: true, message: "Signup successful.", data: user);
    } catch (e) {
      return Responses(success: false, message: "Signup failed: $e");
    }
  }

  @override
  Future<Responses> getCurrentUser() async {
    try {
      User? user = _firebaseService.auth.currentUser;
      if (user != null) {
        final response = await _firebaseService.readDocument(
            collectionPath: FirebaseFirestoreCollectionKeys.users,
            documentId: user.uid);

        if (response?.isNotEmpty ?? false) {
          return Responses(
              success: true,
              data: response,
              message: "User data retrieved successfully.");
        }
      }
      return Responses(
        success: false,
        message: "No user is currently logged in.",
      );
    } catch (e) {
      return Responses(
          success: false, message: "Failed to fetch current user data: $e");
    }
  }

  @override
  Future<Responses> updateUser(Map<String, dynamic> user) async {
    try {
      String? userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(
          success: false,
          message: "User not logged in.",
        );
      }

      await _firebaseService.updateDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.users,
          documentId: userId,
          data: user);

      final response = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
      );

      return Responses(
          success: true,
          message: "User information updated successfully.",
          data: response);
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to update user information: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> uploadProfileImage(File image) async {
    try {
      if (!image.existsSync()) {
        return Responses(
          success: false,
          message: "The image file does not exist.",
        );
      }

      String? userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(
          success: false,
          message: "User not logged in.",
        );
      }

      Reference storageRef =
          _firebaseService.storage.ref().child('profileImages/$userId');
      UploadTask uploadTask = storageRef.putFile(image);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state != TaskState.success) {
        return Responses(
          success: false,
          message: "File upload failed.",
        );
      }

      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Validate file existence
      try {
        await storageRef.getMetadata();
      } catch (e) {
        return Responses(
          success: false,
          message: "Uploaded file metadata not found. Upload may have failed.",
        );
      }

      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
        data: {
          'profilePhoto': downloadUrl,
        },
      );

      return Responses(
        success: true,
        data: downloadUrl,
        message: "Profile image uploaded successfully.",
      );
    } on FirebaseException catch (e) {
      return Responses(
        success: false,
        message: "Firebase error: ${e.message}",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Unexpected error: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> sendFeedback(String feedback) async {
    try {
      await _firebaseService.createDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.feedback,
          data: {'feedback': feedback});

      return Responses(
        success: true,
        message: "Feedback submitted successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to submit feedback: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> DeleteUser() async {
    try {
      User? user = _firebaseService.auth.currentUser;
      if (user == null) {
        return Responses(success: false, message: "No user logged in.");
      }

      // Delete user data from Firestore
      await _firebaseService.deleteDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.feedback,
          documentId: user.uid);

      // Delete user from Firebase Auth
      await user.delete();

      return Responses(success: true, message: "User deleted successfully.");
    } catch (e) {
      return Responses(
          success: false, message: "Failed to delete user: ${e.toString()}");
    }
  }

  @override
  Future<Responses> changePassword(String id, String password) async {
    try {
      User? user = _firebaseService.auth.currentUser;
      if (user == null || user.uid != id) {
        return Responses(
            success: false, message: "Invalid user or not logged in.");
      }

      await user.updatePassword(password);

      return Responses(
          success: true, message: "Password changed successfully.");
    } catch (e) {
      return Responses(
          success: false,
          message: "Failed to change password: ${e.toString()}");
    }
  }

  @override
  Future<Responses> forgetPassword(String email) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
      return Responses(success: true, message: "Password reset email sent.");
    } catch (e) {
      return Responses(
          success: false,
          message: "Failed to send reset email: ${e.toString()}");
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
  Future<Responses> getUserByID({required String id}) async {
    try {
      final response = await _firebaseService.readDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.users,
          documentId: id);

      if (response?.isNotEmpty ?? false) {
        return Responses(
            success: true,
            data: response,
            message: "User data retrieved successfully.");
      }

      return Responses(success: false, message: "User not found.");
    } catch (e) {
      return Responses(
          success: false,
          message: "Failed to retrieve user data: ${e.toString()}");
    }
  }

  @override
  Future<Responses> getMetals() async {
    try {
      // Reference to the Firestore collection
      final collection = await _firebaseService.readCollection(
          collectionPath: FirebaseFirestoreCollectionKeys.metals);

      // Return a successful response
      return Responses(
        success: true,
        message: "Metals retrieved successfully.",
        data: collection,
      );
    } catch (e) {
      // Handle errors and return a failed response
      return Responses(
        success: false,
        message: "Failed to retrieve metals: ${e.toString()}",
      );
    }
  }
// import 'package:cloud_functions/cloud_functions.dart';

// Future<void> sendVerificationCode(String phoneNumber) async {
//   try {
//     final callable = FirebaseFunctions.instance.httpsCallable('sendVerificationCode');
//     final response = await callable.call({'phoneNumber': phoneNumber});

//     print(response.data['message']); // Output: Verification code sent to phone.
//   } catch (e) {
//     print('Failed to send verification code: $e');
//   }
// }

// Future<void> verifyCode(String phoneNumber, String code) async {
//   try {
//     final callable = FirebaseFunctions.instance.httpsCallable('verifyCode');
//     final response = await callable.call({'phoneNumber': phoneNumber, 'code': code});

//     if (response.data['success']) {
//       print("Phone number verified successfully.");
//     } else {
//       print("Verification failed: ${response.data['message']}");
//     }
//   } catch (e) {
//     print('Failed to verify code: $e');
//   }
// }
}

final authenticationRepositoryProvider = Provider((ref) {
  return AuthenticationRepository();
});
