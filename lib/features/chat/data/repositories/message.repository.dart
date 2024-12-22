import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';
import 'package:metal/core/services/firebase.service.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/core/utils/uuid_center.dart';

import 'package:metal/features/chat/domain/entries/conversations.model.dart';
import 'package:metal/features/chat/domain/entries/message.model.dart';
import 'package:metal/features/chat/domain/reprositries/imessage_repository.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';

class MessageRepository implements IMessageRepository {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  

  final ApiService _apiService = ApiService();

 

  @override
  Stream<List<MessageModel>> getMessages(String conversationId) {
    try {
      return _firestore
          .collection(FirebaseFirestoreCollectionKeys.connections)
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
    required String conversationsId,
  }) async {
    try {
      updateConversation(conversationsId, message.message, message.timestamp);
      createMessage(conversationsId, message);
   
      // Return a successful response with the new conversation ID
      return Responses(success: true, data: conversationsId);
    } catch (e) {
      // Handle any errors and rethrow them
      print("Error sending message: $e");
      rethrow;
    }
  }

  Future<void> updateConversation(
    String conversationId,
    String lastMessage,
    String lastUpdatedAt,
  ) async {
    try {
      // Get a reference to the conversation document
      final conversationDocRef =
          _firestore.collection(FirebaseFirestoreCollectionKeys.connections).doc(conversationId);

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
      final conversationDocRef = _firestore.collection(FirebaseFirestoreCollectionKeys.connections).doc(id);

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
  Future<Responses> lastActiveTime(String id) async {
    try {
      final response = await _apiService.post(
        "user/get-last-seen",
        body: {"user": id},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Responses> deMelt(String id) async {
    try {
      final response = await _apiService.post(
        "melt/de-melt",
        body: {"userToDeMelt": id},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final messageRepositoryProvider = Provider((ref) => MessageRepository());
