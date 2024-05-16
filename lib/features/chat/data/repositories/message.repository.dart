import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.dart';
import 'package:metal/core/utils/uuid_center.dart';

import 'package:metal/features/chat/domain/entries/conversations.model.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/domain/reprositries/imessage_repository.dart';

class MessageRepository implements IMessageRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'conversations';

  @override
  Stream<List<ConversationsModel>> getChatList(String userId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('participantIds', arrayContains: userId)
          .orderBy('lastUpdatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map((doc) {
          return ConversationsModel.fromSnapshot(doc);
        }).toList();
        return list;
      });
    } catch (e) {
      print("Error getting chat list: $e");
      rethrow;
    }
  }

  @override
  Stream<List<MessageModel>> getMessages(String conversationId) {
    try {
      return _firestore
          .collection(_collectionName)
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
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
    String? conversationsId,
  }) async {
    try {
      String newConversationsId;
      // Check if a conversation ID is provided
      if (conversationsId == null) {
        // If no conversation ID provided, check if a conversation exists between sender and recipient
        final conversationExist =
            await _firebaseService.checkConversationExists(
          message.senderId,
          message.recipientId,
        );

        if (conversationExist == null) {
          // If no conversation exists, create a new conversation
          newConversationsId = await createConversation(message);
        } else {
          // If conversation exists, use its ID and create a new message in that conversation
          newConversationsId = conversationExist;
          createMessage(conversationExist, message);
          updateConversation(
              newConversationsId, message.message, message.timestamp);
        }
      } else {
        // If conversation ID is provided, use it and create a new message in that conversation
        newConversationsId = conversationsId;
        updateConversation(
            newConversationsId, message.message, message.timestamp);
        createMessage(conversationsId, message);
      }
      // Return a successful response with the new conversation ID
      return Responses(success: true, data: newConversationsId);
    } catch (e) {
      // Handle any errors and rethrow them
      print("Error sending message: $e");
      rethrow;
    }
  }

  Future<void> updateConversation(
    String conversationId,
    String lastMessage,
    DateTime lastUpdatedAt,
  ) async {
    try {
      // Get a reference to the conversation document
      final conversationDocRef =
          _firestore.collection('conversations').doc(conversationId);

      // Update the fields in the conversation document
      await conversationDocRef.update({
        'lastMessage': lastMessage,
        'lastUpdatedAt': lastUpdatedAt,
      });
    } catch (e) {
      print('Error updating conversation: $e');
      rethrow;
    }
  }

  Future<String> createConversation(MessageModel messageModel) async {
    try {
      final id = UUIDCenter.uuid;
      final conversations = ConversationsModel(
          documentId: id,
          initiatedAt: DateTime.now(),
          lastMessage: messageModel.message,
          lastUpdatedAt: DateTime.now(),
          game: "",
          participantIds: [messageModel.recipientId, messageModel.senderId]);

      await _firebaseService
          .addData(_collectionName, conversations.toJson(), id)
          .then((value) async {
        await createuserRoom(id, messageModel);
        await createMessage(id, messageModel);
      });
      return id;
    } catch (e) {
      print("Error creating conversation: $e");
      rethrow;
    }
  }

  Future<void> createMessage(
      String conversationId, MessageModel messageModel) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(conversationId)
          .collection('messages')
          .add(messageModel.toJson())
          .then((value) => print("i was here "));
    } catch (e) {
      print("Error creating message: $e");
      rethrow;
    }
  }

  Future<void> createuserRoom(
      String conversationId, MessageModel messageModel) async {
    try {
      await _firestore
          .collection("users")
          .doc(messageModel.senderId)
          .collection('conversation')
          .add({
        "conversationId": conversationId,
        "partnerId": messageModel.recipientId
      }).then((value) => print("i was here "));
    } catch (e) {
      print("Error creating message: $e");
      rethrow;
    }
  }

  @override
  Stream<ConversationsModel> conversation(String conversationId) {
    try {
      return _firestore
          .collection(_collectionName)
          .doc(conversationId)
          .snapshots()
          .map((snapshot) => ConversationsModel.fromSnapshot(snapshot));
    } catch (e) {
      print("Error getting conversation: $e");
      rethrow;
    }
  }

  @override
  Future<String> checkConversationId(String id, String recipientId) async {
    try {
      final conversationExist = await _firebaseService.checkConversationExists(
        id,
        recipientId,
      );

      if (conversationExist == null) {
        // If no conversation exists, create a new conversation
        return "";
      } else {
        // If conversation exists, use its ID and create a new message in that conversation
        return conversationExist;
      }
    } catch (e) {
      print("Error getting conversation: $e");
      rethrow;
    }
  }
  
  @override
  updateGame(String id, String gameTile) async {
 try {
      // Get a reference to the conversation document
      final conversationDocRef =
          _firestore.collection('conversations').doc(id);

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
}

final messageRepositoryProvider = Provider((ref) => MessageRepository());
