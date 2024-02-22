// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final firebaseServiceProvider = Provider<FirebaseService>((ref) {
//   return FirebaseService(ref.read);
// });

// class FirebaseService {
//   final ref;

//   FirebaseService(this.ref);

//   FirebaseFirestore get _firestore => FirebaseFirestore.instance;
//   FirebaseAuth get _auth => FirebaseAuth.instance;

//   // Method to create a new user account

//   // Method to send a message
//   Future<void> sendMessage({
//     required String senderId,
//     required String receiverId,
//     required String content,
//   }) async {
//     try {
//       await _firestore.collection('messages').add({
//         'senderId': senderId,
//         'receiverId': receiverId,
//         'content': content,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       throw Exception('Failed to send message: $e');
//     }
//   }

//   // Method to retrieve messages for a conversation
//   Stream<List<Map<String, dynamic>>> getMessagesForConversation(
//       String conversationId) {
//     return _firestore
//         .collection('messages')
//         .where('conversationId', isEqualTo: conversationId)
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
//   }

//   Future<List<String>> getUsersChattedWith(String userId) async {
//     try {
//       List<String> usersChattedWith = [];
//       QuerySnapshot conversationsSnapshot = await _firestore
//           .collection('conversations')
//           .where('participants.$userId', isEqualTo: true)
//           .get();

//       for (QueryDocumentSnapshot doc in conversationsSnapshot.docs) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         data['participants'].keys.forEach((participantId) {
//           if (participantId != userId &&
//               !usersChattedWith.contains(participantId)) {
//             usersChattedWith.add(participantId);
//           }
//         });
//       }

//       return usersChattedWith;
//     } catch (e) {
//       throw Exception('Failed to get users chatted with: $e');
//     }
//   }

//   Future<void> startConversation({
//     required String userId1,
//     required String userId2,
//   }) async {
//     try {
//       // Check if a conversation already exists between the two users
//       QuerySnapshot existingConversationsSnapshot = await _firestore
//           .collection('conversations')
//           .where('participants.$userId1', isEqualTo: true)
//           .where('participants.$userId2', isEqualTo: true)
//           .get();

//       if (existingConversationsSnapshot.docs.isNotEmpty) {
//         // Conversation already exists
//         return;
//       }

//       // Create a new conversation document
//       DocumentReference newConversationRef =
//           _firestore.collection('conversations').doc();
//       await newConversationRef.set({
//         'participants': {
//           userId1: true,
//           userId2: true,
//         },
//         // Add other metadata fields if needed
//       });

//       // You might also want to notify the users about the new conversation here
//     } catch (e) {
//       throw Exception('Failed to start conversation: $e');
//     }
//   }
// }
