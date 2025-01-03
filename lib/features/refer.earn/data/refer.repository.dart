import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';

import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/refer.earn/domain/irefer.repository.dart';

class ReferRepository implements IReferRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  Future<Responses> buySpark({
    required double numberOfSpark,
    required double amount,
  }) async {
    try {
      final userid = _firebaseService.userId;

      if (userid == null) {
        return Responses(
          success: false,
          message: "No user is currently logged in.",
        );
      }

      // Retrieve current user data
      final userData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userid,
      );

      if (userData == null || userData.isEmpty) {
        return Responses(
          success: false,
          message: "User data not found.",
        );
      }

      final currentSparks = userData['sparkBalance'] ?? 0.0;

      // Update the user's Sparks balance
      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userid,
        data: {"sparkBalance": currentSparks + numberOfSpark},
      );

      // Log the transaction
      await _firebaseService.createDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.sparksTransactions,
        data: {
          "type": "Purchase",
          "sparks": numberOfSpark,
          "amount": amount,
          "userId": userid,
          "timestamp": DateTime.now().toIso8601String(),
        },
      );

      return Responses(
        success: true,
        message: "Sparks purchased successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to buy Sparks: $e",
      );
    }
  }

  @override
  Future<Responses> getReferCount() async {
    try {
      final userId = _firebaseService.userId;

      // Fetch the current user's referral code
      final userData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId!,
      );

      if (userData == null || !userData.containsKey('referralCode')) {
        return Responses(
          success: false,
          message: "Current user's referral code not found.",
        );
      }

      final referralCode = userData['referralCode'];

      // Fetch all users whose 'referredBy' matches the referral code
      final referredUsers = await _firebaseService.queryCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        field: 'referredBy',
        value: referralCode,
      );

      // Check if any users were found
      if (referredUsers != null && referredUsers.isNotEmpty) {
        return Responses(
          success: true,
          message: "Referred users retrieved successfully.",
          data: referredUsers,
        );
      } else {
        return Responses(
          success: false,
          message: "No users found with the provided referral code.",
        );
      }
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to retrieve referred users: ${e.toString()}",
      );
    }
  }
}

final referRepositoryProvider = Provider((ref) {
  return ReferRepository();
});
