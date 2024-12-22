import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';

import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/enums.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/home_page/domain/entries/melt.request.model.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

import '../../domain/repositories/ihome_repository.dart';

class HomeRepository implements IHomeRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  @override
  Future<Responses> getUserByUsername({required String username}) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.users)
          .where("username", isGreaterThanOrEqualTo: username)
          .where("username",
              isLessThan: username +
                  '\uf8ff') // Unicode trick to include partial matches
          .get();

      final response = querySnapshot.docs.map((doc) => doc.data()).toList();

      return Responses(
        success: true,
        message: "Users retrieved successfully.",
        data: response,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error occurred while fetching users: $e",
      );
    }
  }

  @override
  Stream<Responses> fetchConnections({String? userId}) {
    try {
      User? user = _firebaseService.auth.currentUser;
      String id = userId ?? user!.uid;

      // Use the queryCollectionStream method to fetch a stream of connections
      Stream<List<Map<String, dynamic>>> connectionsStream =
          _firebaseService.queryBuilderCollectionStream(
        collectionPath: FirebaseFirestoreCollectionKeys.connections,
        queryBuilder: (query) {
          return query.where('users', arrayContains: id);
        },
      );

      // Map the stream to Responses object
      return connectionsStream.map((connections) {
        return Responses(
          success: true,
          message: "Connections fetched successfully.",
          data: connections,
        );
      });
    } catch (e) {
      // If an error occurs, create a single-error stream
      return Stream.value(
        Responses(
          success: false,
          message: "Failed to fetch connections: ${e.toString()}",
          data: [],
        ),
      );
    }
  }

  Future<Responses> getConnections({String? userId}) async {
    try {
      User? user = _firebaseService.auth.currentUser;
      String id = userId ?? user!.uid;
      // Use the queryCollection method to fetch connections where userId is part of the connection
      List<Map<String, dynamic>> connections =
          await _firebaseService.queryBuilderCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.connections,
        queryBuilder: (query) {
          return query.where('users', arrayContains: id);
        },
      );

      return Responses(
        success: true,
        message: "Connections fetched successfully.",
        data: connections,
      );
    } catch (e) {
      throw Exception("Failed to fetch connections: ${e.toString()}");
    }
  }

  @override
  Future<Responses> meltUser(MeltRequestModel melt) async {
    try {
      // 1. Check if the requester has already sent a melt request
      if (await _hasExistingRequest(melt.requesterId, melt.recipientId)) {
        return Responses(
          success: false,
          message: "You have already sent a melt request to this user.",
        );
      }

      await _createMeltRequest(melt);

      return Responses(
        success: true,
        message: "Melt request sent successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "An error occurred while sending the melt request: $e",
      );
    }
  }

  Future<bool> _hasExistingRequest(
      String requesterId, String recipientId) async {
    final snapshot = await _firebaseService.firestore
        .collection(FirebaseFirestoreCollectionKeys.meltRequests)
        .where('requesterId', isEqualTo: requesterId)
        .where('recipientId', isEqualTo: recipientId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _createMeltRequest(MeltRequestModel melt) async {
    await _firebaseService.firestore
        .collection(FirebaseFirestoreCollectionKeys.meltRequests)
        .doc()
        .set(melt.toJson());
  }

  @override
  Future<Responses> unMeltUser(String connectionId) async {
    try {
      // Delete the connection document
      await _firebaseService.deleteDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.connections,
        documentId: connectionId,
      );

      return Responses(
        success: true,
        message: "Connection deleted successfully.",
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getThoughtById(String thoughtId) async {
    try {
      // Fetch the thought document by its ID
      final thoughtData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
        documentId: thoughtId,
      );

      if (thoughtData != null) {
        return Responses(
          success: true,
          message: "Thought retrieved successfully.",
          data: thoughtData,
        );
      } else {
        return Responses(
          success: false,
          message: "Thought not found.",
        );
      }
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to retrieve thought: ${e.toString()}",
      );
    }
  }

  @override
  Future markUserOffline(String userId) async {
    try {
      // Fetch the thought document by its ID
      await _firebaseService.updateDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.users,
          documentId: userId,
          data: {
            'isOnline': false,
            'lastActive': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future markUserOnline(String userId) async {
    try {
      // Fetch the thought document by its ID
      await _firebaseService.updateDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.users,
          documentId: userId,
          data: {
            'isOnline': true,
          });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> getThoughtExplore() async {
    try {
      User? user = _firebaseService.auth.currentUser;
      String user1Id = user!.uid;
      final connectionListData = await getConnections(userId: user1Id);
      final connectedUserIds = connectionListData.data;
      List<String> otherUsersId = [];
      for (var i in connectedUserIds) {
        otherUsersId.add(i["users"].firstWhere(
          (user) => user != user1Id,
          orElse: () =>
              "", // Handle cases where all user IDs match the current user
        ));
      }
      // Fetch thoughts from users not in the connected user list
      final thoughts = await _firebaseService.readCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
      );

      // Filter thoughts locally to exclude connected users
      final filteredThoughts = thoughts
          .where((thought) {
            return !otherUsersId.contains(thought['userId']);
          })
          .take(20)
          .toList();

      return Responses(
        success: true,
        message: "Successfully fetched explore thoughts.",
        data: filteredThoughts,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to fetch explore thoughts: $e",
      );
    }
  }

  @override
  Future<Responses> getThoughtForYou() async {
    try {
      // Fetch connections of the current user
      User? user = _firebaseService.auth.currentUser;
      String user1Id = user!.uid;
      final connectionListData = await getConnections(userId: user1Id);
      final connectedUserIds = connectionListData.data;
      List<String> otherUsersId = [];
      for (var i in connectedUserIds) {
        otherUsersId.add(i["users"].firstWhere(
          (user) => user != user1Id,
          orElse: () =>
              "", // Handle cases where all user IDs match the current user
        ));
      }

      // Fetch thoughts from users not in the connected user list
      final thoughts = await _firebaseService.readCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
      );

      // Filter thoughts locally to exclude connected users
      final filteredThoughts = thoughts
          .where((thought) {
            return otherUsersId.contains(thought['userId']);
          })
          .take(20)
          .toList();

      return Responses(
        success: true,
        message: "Successfully fetched 'For You' thoughts.",
        data: filteredThoughts,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to fetch 'For You' thoughts: $e",
      );
    }
  }

  @override
  Future<Responses> getThoughtsByUserId(String userId) async {
    try {
      // Query Firestore to fetch all thoughts posted by the user
      final thoughtsData = await _firebaseService.queryCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
        field: "userId",
        value: userId,
      );

      if (thoughtsData.isNotEmpty) {
        return Responses(
          success: true,
          message: "Thoughts retrieved successfully.",
          data: thoughtsData,
        );
      } else {
        return Responses(
          success: false,
          message: "No thoughts found for the user.",
        );
      }
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to retrieve thoughts: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> sendThought(ThoughtModel thought) async {
    try {
      // Add the thought to the "thoughts" collection
      await _firebaseService.createDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
        documentId: thought.id, // Use the unique ID for the thought
        data: thought.toJson(), // Serialize the thought to JSON
      );

      return Responses(
        success: true,
        message: "Thought created successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to create thought: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> reactThought({
    required String thoughtId,
    required String userId,
    required String emoji,
  }) async {
    try {
      // Fetch the current thought document
      final thoughtDoc = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
        documentId: thoughtId,
      );

      if (thoughtDoc == null) {
        return Responses(
          success: false,
          message: "Thought not found.",
        );
      }

      // Get the current reactions list
      final reactions = (thoughtDoc['reactions'] ?? []) as List<dynamic>;

      // Check if the user already reacted
      final existingReactionIndex =
          reactions.indexWhere((reaction) => reaction['userId'] == userId);

      if (existingReactionIndex != -1) {
        // Update the emoji for the existing reaction
        reactions[existingReactionIndex]['emoji'] = emoji;
      } else {
        // Add a new reaction
        reactions.add({'userId': userId, 'emoji': emoji});
      }

      // Update the thought document with the modified reactions
      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
        documentId: thoughtId,
        data: {'reactions': reactions},
      );

      return Responses(
        success: true,
        message: "Reaction added successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to add reaction: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> checkMelt({required String user2Id}) async {
    try {
      User? user = _firebaseService.auth.currentUser;
      String user1Id = user!.uid;
      // Query to check if user1 has sent a melt request to user2
      final user1ToUser2Request = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.meltRequests)
          .where('requesterId', isEqualTo: user1Id)
          .where('recipientId', isEqualTo: user2Id)
          .get();

      // Query to check if user2 has sent a melt request to user1
      final user2ToUser1Request = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.meltRequests)
          .where('requesterId', isEqualTo: user2Id)
          .where('recipientId', isEqualTo: user1Id)
          .get();

      MeltRequestState? meltState;
      if (user1ToUser2Request.docs.isNotEmpty &&
          user2ToUser1Request.docs.isNotEmpty) {
        // Both users have sent a request, state is "Mutual"
        meltState = MeltRequestState.mutual;
      } else if (user1ToUser2Request.docs.isNotEmpty) {
        // One user has sent a request, state is "Pending"
        meltState = MeltRequestState.pending;
      } else {
        // No requests exist, state is "No Request"
        meltState = MeltRequestState.noRequest;
      }

      return Responses(
          success: true, message: "successfully.", data: meltState);
    } catch (e) {
      throw Exception('An error occurred while checking the melt state: $e');
    }
  }

}

final homeRepositoryProvider = Provider((ref) {
  return HomeRepository();
});
