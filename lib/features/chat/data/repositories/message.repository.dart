import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';

import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/domain/reprositries/imessage_repository.dart';

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

  @override
  Future<Responses> sendMessage({
    required MessageModel message,
    required String conversationsId,
  }) async {
    try {
      // Get today's date in YYYY-MM-DD format for tracking daily conversations
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Get the conversation document
      final conversationDoc = await _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
          .doc(conversationsId)
          .get();

      if (conversationDoc.exists) {
        final data = conversationDoc.data() as Map<String, dynamic>;
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
      }

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

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('Chat cleared successfully.');
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
      await _db.deleteDocument(
        collectionPath:
            '${FirebaseFirestoreCollectionKeys.connections}/$id/${FirebaseFirestoreCollectionKeys.message}',
        documentId: messageId,
      );

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
