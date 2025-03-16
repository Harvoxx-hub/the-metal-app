import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';

import 'package:metal/features/verification/domain/repositories/iverification.repository.dart';

class VerificationRepository implements IVerificationRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
  Future<Responses> verification() async {
    try {
      final userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(success: false, message: "User not logged in");
      }

      await _firebaseService.updateDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.users,
          documentId: userId,
          data: {'isVerified': true});

      return Responses(success: true, message: "Verification successful");
    } catch (e) {
      return Responses(success: false, message: e.toString());
    }
  }
}

final verificationRepositoryProvider = Provider((ref) {
  return VerificationRepository();
});
