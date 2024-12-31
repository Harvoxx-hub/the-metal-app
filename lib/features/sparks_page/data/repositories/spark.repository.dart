import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
 
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';

import 'package:metal/features/sparks_page/domain/repositories/ispark.repository.dart';

class SparkRepository implements ISparkRepository {
 
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
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
  Future<Responses> getSparkHistory() async {
    try {
      final userid = _firebaseService.userId;
      if (userid == null) {
        return Responses(
          success: false,
          message: "No user is currently logged in.",
        );
      }

      // Query the Spark history
      final sparkHistory = await _firebaseService.queryCollection(
          collectionPath: FirebaseFirestoreCollectionKeys.sparksTransactions,
          field: "userId",
          value: userid);

      return Responses(
        success: true,
        data: sparkHistory,
        message: "Spark history retrieved successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to retrieve Spark history: $e",
      );
    }
  }

  @override
  Future<Responses> shareSpark({
    required double numberOfSparks,
    required String receiverID,
  }) async {
    try {
      final userid = _firebaseService.userId;
      if (userid == null) {
        return Responses(
          success: false,
          message: "No user is currently logged in.",
        );
      }

      // Retrieve sender's data
      final senderData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userid,
      );

      if (senderData == null || senderData.isEmpty) {
        return Responses(
          success: false,
          message: "Sender data not found.",
        );
      }

      final senderSparks = senderData['sparkBalance'] ?? 0.0;

      if (senderSparks < numberOfSparks) {
        return Responses(
          success: false,
          message: "Insufficient Sparks to share.",
        );
      }

      // Retrieve receiver's data
      final receiverData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: receiverID,
      );

      if (receiverData == null || receiverData.isEmpty) {
        return Responses(
          success: false,
          message: "Receiver data not found.",
        );
      }

      final receiverSparks = receiverData['sparkBalance'] ?? 0.0;

      // Perform the transfer in a Firestore transaction
      await _firebaseService.firestore.runTransaction((transaction) async {
        final senderRef = _firebaseService.firestore
            .collection(FirebaseFirestoreCollectionKeys.users)
            .doc(userid);
        final receiverRef = _firebaseService.firestore
            .collection(FirebaseFirestoreCollectionKeys.users)
            .doc(receiverID);

        // Update sender's Sparks
        transaction
            .update(senderRef, {"sparkBalance": senderSparks - numberOfSparks});

        // Update receiver's Sparks
        transaction.update(
            receiverRef, {"sparkBalance": receiverSparks + numberOfSparks});

        // Log the transaction
        transaction.set(
          _firebaseService.firestore
              .collection(FirebaseFirestoreCollectionKeys.sparksTransactions)
              .doc(),
          {
            "type": "Sent",
            "sparks": numberOfSparks,
            "userId": userid,
            "receiverId": receiverID,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
      });

      return Responses(
        success: true,
        message: "Sparks shared successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to share Sparks: $e",
      );
    }
  }
}

final sparkRepositoryProvider = Provider((ref) {
  return SparkRepository();
});
