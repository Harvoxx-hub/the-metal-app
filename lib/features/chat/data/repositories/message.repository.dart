import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';

import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/domain/reprositries/imessage_repository.dart';
import 'package:metal/features/thought/data/domain/entries/melt.request.model.dart';
import 'package:metal/features/thought/data/domain/entries/connection.model.dart';

class MessageRepository implements IMessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseServiceDb _db = FirebaseServiceDb.instance;

  @override
  Stream<List<MessageModel>> getMessages(String conversationId) {
    try {
      return _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromSnapshot(doc);
        }).toList();
      });
    } catch (e) {
      print("Error getting messages: $e");
      rethrow;
    }
  }

  /// Create or get connection for direct messaging (without melting first)
  @override
  Future<String> createOrGetConnectionForDirectMessage({
    required String senderId,
    required String recipientId,
  }) async {
    // Check if connection already exists
    final existingConnections = await _firestore
        .collection(FirebaseFirestoreCollectionKeys.connections)
        .where('users', arrayContains: senderId)
        .get();

    for (var doc in existingConnections.docs) {
      final data = doc.data();
      final users = List<String>.from(data['users'] ?? []);
      if (users.contains(recipientId)) {
        return doc.id; // Return existing connection ID
      }
    }

    // Create new connection with pending melt status
    final sortedUserIds = [senderId, recipientId]..sort();
    final connectionId = sortedUserIds.join('_');

    final connectionData = {
      'connectionId': connectionId,
      'users': [senderId, recipientId],
      'connectedOn': DateTime.now().toIso8601String(),
      'status': 'active',
      'meltStatus': 'pending', // Pending until recipient melts
      'lastMessage': 'Start sending messages!',
      'lastUpdatedAt': DateTime.now().toIso8601String(),
      'isAnonymous': false,
      'unreadCount': 0,
      'initiatorId': senderId,
      'receiverId': recipientId,
      'wasAnonymous': false,
      'dailyConversations': <String>[],
    };

    await _firestore
        .collection(FirebaseFirestoreCollectionKeys.connections)
        .doc(connectionId)
        .set(connectionData, SetOptions(merge: true));

    // Create a melt request from sender to recipient
    final meltRequest = MeltRequestModel(
      requesterId: senderId,
      recipientId: recipientId,
      senderId: senderId,
      isAnonymous: false,
      createdAt: DateTime.now().toIso8601String(),
      status: 'pending',
    );

    await _firestore
        .collection(FirebaseFirestoreCollectionKeys.meltRequests)
        .doc()
        .set(meltRequest.toJson());

    return connectionId;
  }

  @override
  Future<Responses> sendMessage({
    required MessageModel message,
    required String conversationsId,
  }) async {
    try {
      // Get the conversation document to check melt status
      final conversationDoc = await _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationsId)
          .get();

      if (!conversationDoc.exists) {
        return Responses(
          success: false,
          message: "Connection not found",
        );
      }

      final data = conversationDoc.data() as Map<String, dynamic>;
      
      // Check if user can send message based on melt status
      final connection = ConnectionModel.fromJson(data);
      if (!connection.canUserSendMessage(message.senderId)) {
        return Responses(
          success: false,
          message: "You need to melt with this user first to reply",
        );
      }

      // Get today's date in YYYY-MM-DD format for tracking daily conversations
      final today = DateTime.now().toIso8601String().split('T')[0];
      final List<String> dailyConversations =
          List<String>.from(data['dailyConversations'] ?? []);
      final String? lastConversationDate = data['lastConversationDate'];
      final int currentUnreadCount = data['unreadCount'] ?? 0;

      // Only add today's date if it's different from the last conversation date
      if (lastConversationDate != today) {
        dailyConversations.add(today);
      }

      // Update conversation with new message and daily conversation tracking
      await _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationsId)
          .update({
        'lastMessage': message.message,
        'lastUpdatedAt': message.timestamp,
        'dailyConversations': dailyConversations,
        'lastConversationDate': today,
        'lastSenderId': message.senderId,
        'unreadCount': currentUnreadCount + 1, // Increment unread count
      });

      // Create the message
      await createMessage(conversationsId, message);

      // Return a successful response with the conversation ID
      return Responses(success: true, data: conversationsId);
    } catch (e) {
      // Handle any errors and rethrow them
      print("Error sending message: $e");
      rethrow;
    }
  }

  Future<void> updateConversation(
    String conversationId,
  ) async {
    try {
      // Get a reference to the conversation document
      final conversationDocRef = _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationId);

      // Update the fields in the conversation document
      await conversationDocRef.update({
        'unreadCount': 0,
      });
    } catch (e) {
      print('Error updating conversation: $e');
      rethrow;
    }
  }

  Future<void> createMessage(
      String conversationId, MessageModel messageModel) async {
    try {
      await _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationId)
          .collection('messages')
          .add(messageModel.toJson())
          .then((value) => print("i was here "));
    } catch (e) {
      print("Error creating message: $e");
      rethrow;
    }
  }

  @override
  updateGame(String id, String gameTile, {MessageModel? message}) async {
    try {
      // Get a reference to the conversation document
      final conversationDocRef = _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(id);

      // Update the fields in the conversation document
      await conversationDocRef.update({
        'lastMessage': "Started a game",
        'game': gameTile,
      });
    } catch (e) {
      print('Error updating conversation: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearChat(String conversationId) async {
    try {
      final messagesRef = _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationId)
          .collection('messages');
      // Also clear last conversation metadata on the connection
      await _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationId)
          .update({
        'lastMessage': null,
        'lastUpdatedAt': null,
        'lastSenderId': null,
        'unreadCount': 0,
      });

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Also clear last conversation metadata on the connection
      await _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationId)
          .update({
        'lastMessage': null,
        'lastUpdatedAt': null,
        'lastSenderId': null,
        'unreadCount': 0,
      });

      print('Chat and connection last message metadata cleared successfully.');
    } catch (e) {
      print('Error clearing chat: $e');
      rethrow;
    }
  }

  @override
  Future<Responses> unMelt(
      String id, String messageId, Map<String, dynamic> data) async {
    try {
      await _db.updateDocument(
          collectionPath:
              '${FirebaseFirestoreCollectionKeys.connections}/$id/${FirebaseFirestoreCollectionKeys.message}',
          documentId: messageId,
          data: data);
      await _db.updateDocument(
          collectionPath: FirebaseFirestoreCollectionKeys.connections,
          documentId: id,
          data: {"isAnonymous": false});

      return Responses(success: true, message: "Un-melt Successfully");
    } catch (e) {
      rethrow;
    }
  }

  @override
  deleteMessage(String id, messageId) async {
    try {
      // Get the current user ID
      final currentUserId = _db.userId;
      if (currentUserId == null) {
        throw Exception("User not authenticated");
      }

      // Get the message being deleted to check if it's the last message
      final messageDoc = await _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(id)
          .collection(FirebaseFirestoreCollectionKeys.message)
          .doc(messageId)
          .get();

      final conversationDoc = await _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(id)
          .get();

      if (!conversationDoc.exists) {
        throw Exception("Conversation not found");
      }

      final conversationData = conversationDoc.data() as Map<String, dynamic>;
      final lastUpdatedAt = conversationData['lastUpdatedAt'] as String?;
      final messageData = messageDoc.data();
      final messageTimestamp = messageData?['timestamp'] as String?;

      // Check if the deleted message is the last message
      final isLastMessage = lastUpdatedAt != null &&
          messageTimestamp != null &&
          lastUpdatedAt == messageTimestamp;

      // Delete the message
      await _db.deleteDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.connections}/$id/${FirebaseFirestoreCollectionKeys.message}',
        documentId: messageId,
      );

      // If the deleted message was the last message, update the conversation
      if (isLastMessage) {
        // Get the most recent remaining message
        final remainingMessages = await _firestore
            .collection(FirebaseFirestoreCollectionKeys.connections)
            .doc(id)
            .collection(FirebaseFirestoreCollectionKeys.message)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (remainingMessages.docs.isNotEmpty) {
          // Update with the new last message
          final lastMessage = remainingMessages.docs.first.data();
          final newLastSenderId = lastMessage['senderId'] as String?;
          final newLastTimestamp = lastMessage['timestamp'] as String?;
          final isNewLastMessageRead = lastMessage['isRead'] as bool? ?? false;

          // Determine the correct unreadCount based on standard chat logic:
          // - If the new last message is from the current user, unreadCount = 0
          // - If the new last message is from the other user and was read, unreadCount = 0
          // - If the new last message is from the other user and was not read, count unread messages
          int newUnreadCount = 0;

          if (newLastSenderId != null && newLastSenderId != currentUserId) {
            // Message is from the other user
            if (!isNewLastMessageRead && newLastTimestamp != null) {
              // Count all unread messages from the other user
              // Note: We get all messages and filter in memory since Firestore
              // doesn't support complex queries with isNotEqualTo and orderBy
              final allMessages = await _firestore
                  .collection(FirebaseFirestoreCollectionKeys.connections)
                  .doc(id)
                  .collection(FirebaseFirestoreCollectionKeys.message)
                  .where('isRead', isEqualTo: false)
                  .get();

              // Filter to only count messages from the other user
              newUnreadCount = allMessages.docs.where((doc) {
                final msgData = doc.data();
                return msgData['senderId'] != currentUserId;
              }).length;
            } else {
              // Message was read, so unreadCount = 0
              newUnreadCount = 0;
            }
          } else {
            // Message is from the current user, so unreadCount = 0
            newUnreadCount = 0;
          }

          await _firestore
              .collection(FirebaseFirestoreCollectionKeys.connections)
              .doc(id)
              .update({
            'lastMessage': lastMessage['message'] ?? '',
            'lastUpdatedAt': newLastTimestamp,
            'lastSenderId': newLastSenderId,
            'unreadCount': newUnreadCount,
          });
        } else {
          // No more messages, clear the last message fields and reset unreadCount
          await _firestore
              .collection(FirebaseFirestoreCollectionKeys.connections)
              .doc(id)
              .update({
            'lastMessage': null,
            'lastUpdatedAt': null,
            'lastSenderId': null,
            'unreadCount': 0,
          });
        }
      }

      return Responses(success: true, message: "Deleted Successfully");
    } catch (e) {
      rethrow;
    }
  }

  @override
  updateMessage(String id, dynamic messageId, Map<String, dynamic> data) async {
    try {
      // Validate input to ensure no empty values
      if (id.isEmpty || messageId == null || messageId.toString().isEmpty) {
        throw Exception("Invalid connection ID or message ID");
      }

      // Build the collection path safely
      final collectionPath =
          '${FirebaseFirestoreCollectionKeys.connections}/$id/${FirebaseFirestoreCollectionKeys.message}';

      // Ensure the collectionPath is valid
      if (collectionPath.contains("//")) {
        throw Exception("Invalid collection path: $collectionPath");
      }
      if (data['isRead'] == true) {
        await _firestore
            .collection(FirebaseFirestoreCollectionKeys.connections)
            .doc(id)
            .update({'unreadCount': 0});
      }

      // Update the document in Firestore
      await _db.updateDocument(
        collectionPath: collectionPath,
        documentId: messageId.toString(),
        data: data,
      );

      // If marking message as read, reset unread count
      if (data['isRead'] == true) {
        await _firestore
            .collection(FirebaseFirestoreCollectionKeys.connections)
            .doc(id)
            .update({'unreadCount': 0});
      }

      return Responses(success: true, message: "Message updated successfully");
    } catch (e) {
      print("Error in updateMessage: $e");
      rethrow;
    }
  }
}

final messageRepositoryProvider = Provider((ref) => MessageRepository());
