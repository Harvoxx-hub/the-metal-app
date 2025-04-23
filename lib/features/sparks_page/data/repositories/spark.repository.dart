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

      // Create notification for purchase
      _createSparkTransactionNotification(
        userId: userid,
        title: "Spark Purchase Successful",
        subTitle: "You purchased $numberOfSpark sparks",
        data: {
          "amount": amount,
          "sparks": numberOfSpark,
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

      // Query Spark history for both sender and receiver
      final sparkHistory = await _firebaseService.queryCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.sparksTransactions,
        field: "userId",
        value: userid,
      );

      final sparkHistory2 = await _firebaseService.queryCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.sparksTransactions,
        field: "receiverId",
        value: userid,
      );

      // Combine both lists into one
      final combinedSparkHistory = [...sparkHistory, ...sparkHistory2];

      return Responses(
        success: true,
        data: combinedSparkHistory,
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
    required String receiverName,
    required String senderName,
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
            "senderName": senderName,
            "receiverName": receiverName,
            "receiverId": receiverID,
            "timestamp": DateTime.now().toIso8601String(),
          },
        );
      });

      // Create notification for receiver
      _createSparkTransactionNotification(
        userId: receiverID,
        title: "Sparks Received",
        subTitle: "You received $numberOfSparks sparks from $senderName",
        data: {
          "sparks": numberOfSparks,
          "senderId": userid,
          "senderName": senderName,
        },
      );

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

  @override
  Future<Responses> redeemReferralCode(String referralCode) async {
    try {
      final userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(
          success: false,
          message: "No user is currently logged in.",
        );
      }

      // Find user with this referral code
      final referrerData = await _findUserByReferralCode(referralCode);
      if (referrerData == null) {
        return Responses(
          success: false,
          message: "Invalid referral code.",
        );
      }

      // Check if user is trying to use their own code
      final referrerId = referrerData['id'];
      if (referrerId == userId) {
        return Responses(
          success: false,
          message: "You cannot use your own referral code.",
        );
      }

      // Check if this user has already redeemed a code
      final userData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
      );

      if (userData == null || userData.isEmpty) {
        return Responses(
          success: false,
          message: "User data not found.",
        );
      }

      // If user has already redeemed a code, prevent another redemption
      if (userData['hasRedeemedReferral'] == true) {
        return Responses(
          success: false,
          message: "You have already redeemed a referral code.",
        );
      }

      // Mark this user as having redeemed a code
      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
        data: {"hasRedeemedReferral": true},
      );

      // Get referrer's current sparks
      final referrerSparks = referrerData['sparkBalance'] ?? 0.0;

      // Add sparks to referrer (the one whose code was used)
      const double REFERRAL_BONUS = 50.0;
      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: referrerId,
        data: {"sparkBalance": referrerSparks + REFERRAL_BONUS},
      );

      // Also give a bonus to the person who used the code
      const double USER_BONUS = 25.0;
      final userSparks = userData['sparkBalance'] ?? 0.0;
      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
        data: {"sparkBalance": userSparks + USER_BONUS},
      );

      // Record transaction for referrer
      await _firebaseService.createDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.sparksTransactions,
        data: {
          "type": "Referred",
          "sparks": REFERRAL_BONUS,
          "userId": referrerId,
          "referredUserId": userId,
          "referredName": userData['username'] ?? "A new user",
          "timestamp": DateTime.now().toIso8601String(),
        },
      );

      // Record transaction for the user who entered the code
      await _firebaseService.createDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.sparksTransactions,
        data: {
          "type": "ReferralBonus",
          "sparks": USER_BONUS,
          "userId": userId,
          "referrerId": referrerId,
          "referrerName": referrerData['username'] ?? "Referrer",
          "timestamp": DateTime.now().toIso8601String(),
        },
      );

      // Create notification for referrer
      _createSparkTransactionNotification(
        userId: referrerId,
        title: "Referral Bonus",
        subTitle: "You earned $REFERRAL_BONUS sparks from a referral",
        data: {
          "sparks": REFERRAL_BONUS,
          "referredUserId": userId,
          "referralCode": referralCode,
        },
      );

      // Create notification for the user who entered the code
      _createSparkTransactionNotification(
        userId: userId,
        title: "Referral Bonus",
        subTitle: "You earned $USER_BONUS sparks for using a referral code",
        data: {
          "sparks": USER_BONUS,
          "referrerId": referrerId,
          "referralCode": referralCode,
        },
      );

      return Responses(
        success: true,
        message: "Referral bonus awarded successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to redeem referral code: $e",
      );
    }
  }

  // Helper method to find user by referral code
  Future<Map<String, dynamic>?> _findUserByReferralCode(String code) async {
    try {
      final users = await _firebaseService.queryCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        field: "referralCode",
        value: code,
      );

      if (users.isEmpty) return null;
      return users.first;
    } catch (e) {
      return null;
    }
  }

  // Helper method to create notifications for spark transactions
  void _createSparkTransactionNotification({
    required String userId,
    required String title,
    required String subTitle,
    required Map<String, dynamic> data,
  }) {
    try {
      _firebaseService.createDocument(
        collectionPath:
            "${FirebaseFirestoreCollectionKeys.users}/$userId/${FirebaseFirestoreCollectionKeys.notification}",
        data: {
          "recipientIds": [userId],
          "title": title,
          "subTitle": subTitle,
          "type": "sparks_transaction",
          "data": data,
          "androidNotification": {"priority": "high"},
          "iosNotification": {"headers": {}},
          "timestamp": DateTime.now().toIso8601String(),
          "isRead": false,
        },
      );
    } catch (e) {
      // Silent fail for notifications - don't block the main transaction
      print("Failed to create notification: $e");
    }
  }

  @override
  Future<Responses> reconcileSparkTransactions() async {
    try {
      final userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(
          success: false,
          message: "No user is currently logged in.",
        );
      }

      // Get all user's transactions
      final transactions = await getSparkHistory();
      if (transactions.success == false) return transactions;

      double calculatedBalance = 0.0;

      // Calculate what the balance should be
      if (transactions.data != null) {
        for (var tx in transactions.data) {
          if (tx['userId'] == userId) {
            // Outgoing transactions
            if (tx['type'] == 'Sent') {
              calculatedBalance -= (tx['sparks'] is int)
                  ? tx['sparks'].toDouble()
                  : (tx['sparks'] ?? 0.0);
            } else {
              // Purchases, referrals, and other incoming
              calculatedBalance += (tx['sparks'] is int)
                  ? tx['sparks'].toDouble()
                  : (tx['sparks'] ?? 0.0);
            }
          } else if (tx['receiverId'] == userId) {
            // Incoming from other users
            calculatedBalance += (tx['sparks'] is int)
                ? tx['sparks'].toDouble()
                : (tx['sparks'] ?? 0.0);
          }
        }
      }

      // Get current balance
      final userData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
      );

      final currentBalance = userData?['sparkBalance'] ?? 0.0;

      // If there's a discrepancy, fix it
      if ((calculatedBalance - currentBalance).abs() > 0.01) {
        // Allow for small rounding errors
        await _firebaseService.updateDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.users,
          documentId: userId,
          data: {"sparkBalance": calculatedBalance},
        );

        _createSparkTransactionNotification(
          userId: userId,
          title: "Spark Balance Updated",
          subTitle:
              "Your spark balance has been updated from $currentBalance to $calculatedBalance",
          data: {
            "oldBalance": currentBalance,
            "newBalance": calculatedBalance,
          },
        );

        return Responses(
          success: true,
          message:
              "Balance reconciled from $currentBalance to $calculatedBalance",
          data: {
            "oldBalance": currentBalance,
            "newBalance": calculatedBalance,
          },
        );
      }

      return Responses(
        success: true,
        message: "Balance is correct",
        data: {
          "balance": currentBalance,
        },
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Reconciliation error: $e",
      );
    }
  }
}

final sparkRepositoryProvider = Provider((ref) {
  return SparkRepository();
});
