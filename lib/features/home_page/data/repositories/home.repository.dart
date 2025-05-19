import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/enums.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';
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
      // 1. Check if users are already connected
      if (await _hasExistingConnection(melt.requesterId, melt.recipientId)) {
        return Responses(
          success: false,
          message: "You are already connected with this user.",
        );
      }

      // 2. Check if the requester has already sent a melt request
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

  /// Check if a melt request already exists between two users
  Future<bool> _hasExistingRequest(
      String requesterId, String recipientId) async {
    final snapshot = await _firebaseService.firestore
        .collection(FirebaseFirestoreCollectionKeys.meltRequests)
        .where('requesterId', isEqualTo: requesterId)
        .where('recipientId', isEqualTo: recipientId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Check if a connection already exists between two users
  Future<bool> _hasExistingConnection(String user1Id, String user2Id) async {
    final connection = await getConnectionBetweenUsers(user1Id, user2Id);
    return connection != null;
  }

  /// Retrieve the connection between two specific users, if it exists
  Future<ConnectionModel?> getConnectionBetweenUsers(
      String user1Id, String user2Id) async {
    final querySnapshot = await _firebaseService.firestore
        .collection(FirebaseFirestoreCollectionKeys.connections)
        .where('users', arrayContains: user1Id)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      List<String> users = List<String>.from(data['users']);
      if (users.contains(user2Id)) {
        // Add ID to the data
        data['connectionId'] = doc.id;
        return ConnectionModel.fromJson(data);
      }
    }
    return null;
  }

  Future<void> _createMeltRequest(MeltRequestModel melt) async {
    await _firebaseService.firestore
        .collection(FirebaseFirestoreCollectionKeys.meltRequests)
        .doc()
        .set(melt.toJson());
  }

  @override
  Future<Responses> unMeltUser(String recipientId) async {
    try {
      User? user = _firebaseService.auth.currentUser;
      String currentUserId = user!.uid;

      // Find connection between current user and recipient
      final connection =
          await getConnectionBetweenUsers(currentUserId, recipientId);

      if (connection != null) {
        // Delete the connection
        await _firebaseService.firestore
            .collection(FirebaseFirestoreCollectionKeys.connections)
            .doc(connection.connectionId)
            .delete();

        return Responses(
            success: true, message: "Successfully unmelted.", data: null);
      }

      // If no connection is found, try to delete any melt requests (for backward compatibility)
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.meltRequests)
          .where('requesterId', isEqualTo: currentUserId)
          .where('recipientId', isEqualTo: recipientId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Delete the found document
        await _firebaseService.firestore
            .collection(FirebaseFirestoreCollectionKeys.meltRequests)
            .doc(querySnapshot.docs.first.id)
            .delete();

        return Responses(
            success: true, message: "Successfully unmelted.", data: null);
      }

      return Responses(
          success: false,
          message: "No connection or melt request found.",
          data: null);
    } catch (e) {
      throw Exception('An error occurred while unmelting: $e');
    }
  }

  /// Get connection status between two users
  Future<bool> getConnectionStatus(String user1Id, String user2Id) async {
    // Check if users are connected
    if (await _hasExistingConnection(user1Id, user2Id)) {
      return true;
    }

    
    // No connection or melt request exists
    return  false;
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
            'lastActive': DateTime.now().toIso8601String(),
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

      // Fetch connected user IDs
      final connectionListData = await getConnections(userId: user1Id);
      final connectedUserIds = connectionListData.data;
      List<String> otherUsersId = [];
      for (var i in connectedUserIds) {
        otherUsersId.add(i["users"].firstWhere(
          (user) => user != user1Id,
          orElse: () => "",
        ));
      }

      // Fetch blocked user IDs
      final blockedUsers = await _firebaseService.readCollection(
        collectionPath: "users/$user1Id/blocked",
      );
      final blockedUserIds = blockedUsers.map((doc) => doc['id']).toList();

      // Fetch thoughts
      final thoughts = await _firebaseService.readCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
      );

      // Filter thoughts to exclude connected users and blocked users
      final filteredThoughts = thoughts.where((thought) {
        final thoughtUserId = thought['userId'];
        return !otherUsersId.contains(thoughtUserId) &&
            !blockedUserIds.contains(thoughtUserId);
      }).toList();

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
      User? user = _firebaseService.auth.currentUser;
      String user1Id = user!.uid;

      // Fetch connected user IDs
      final connectionListData = await getConnections(userId: user1Id);
      final connectedUserIds = connectionListData.data;
      List<String> otherUsersId = [];
      for (var i in connectedUserIds) {
        otherUsersId.add(i["users"].firstWhere(
          (user) => user != user1Id,
          orElse: () => "",
        ));
      }

      // Fetch blocked user IDs
      final blockedUsers = await _firebaseService.readCollection(
        collectionPath: "users/$user1Id/blocked",
      );
      final blockedUserIds = blockedUsers.map((doc) => doc['id']).toList();

      // Fetch thoughts
      final thoughts = await _firebaseService.readCollection(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
      );

      // Filter thoughts to include only connected users and exclude blocked users
      final filteredThoughts = thoughts
          .where((thought) {
            final thoughtUserId = thought['userId'];
            return otherUsersId.contains(thoughtUserId) &&
                !blockedUserIds.contains(thoughtUserId);
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
        data: {'reactions': reactions },
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

      // First check if there's an existing connection between users
      final connection = await getConnectionBetweenUsers(user1Id, user2Id);
      if (connection != null) {
        // Users are already connected, return a special state for this
        return Responses(
            success: true,
            message: "Users are already connected.",
            data:
                MeltRequestState.connected); // Adding a new state for connected
      }

      // If no connection exists, proceed with checking melt requests

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

       if (user1ToUser2Request.docs.isNotEmpty) {
        // One user has sent a request, state is "Pending"
        meltState = MeltRequestState.pending;
      } else {
        // No requests exist, state is "No Request"
        meltState = MeltRequestState.noRequest;
      }

      return Responses(
          success: true,
          message: "Successfully retrieved melt state.",
          data: meltState);
    } catch (e) {
      throw Exception('An error occurred while checking the melt state: $e');
    }
  }

  @override
  Future<Responses> deleteThoughtById(String id) async {
    try {
      await _firebaseService.deleteDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
        documentId: id, // Use the unique ID for the thought
      );

      return Responses(
        success: true,
        message: "Thought deleted successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to create thought: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> deMeltUser(String userToMelt) async {
    try {
      // Delete the connection document
      await _firebaseService.deleteDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.connections,
        documentId: userToMelt,
      );

      return Responses(
        success: true,
        message: "Connection deleted successfully.",
      );
    } catch (e) {
      rethrow;
    }
  }

// New method to edit a thought
  Future<Responses> editThought(
      String thoughtId, Map<String, dynamic> updatedData) async {
    try {
      await _firebaseService.editThought(
        collectionPath: FirebaseFirestoreCollectionKeys.thoughts,
        thoughtId: thoughtId,
        updatedData: updatedData,
      );

      return Responses(
        success: true,
        message: "Thought updated successfully.",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to update thought: ${e.toString()}",
      );
    }
  }

  Future<Responses> getConnection(String connectionId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(connectionId)
          .get();

      if (!doc.exists) {
        throw Exception('Connection not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      data['connectionId'] = doc.id; // Add the document ID to the data

      final connection = ConnectionModel.fromJson(data);
      return Responses(
        success: true,
        message: "Connection retrieved successfully",
        data: connection,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Failed to get connection: $e",
      );
    }
  }
}

final homeRepositoryProvider = Provider((ref) {
  return HomeRepository();
});
