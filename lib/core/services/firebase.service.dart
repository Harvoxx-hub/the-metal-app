import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:metal/core/model/responces.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Responses> getData(String collectionName) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();
      List<Object?> data = querySnapshot.docs.map((doc) => doc.data()).toList();
      return Responses(success: true, data: data);
    } catch (e) {
      print('Failed to get data: $e');
      return Responses(success: false, message: 'Failed to get data');
    }
  }

  Future<Responses> addData(
      String collectionName, Map<String, dynamic> data, String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).set(data);
      return Responses(success: true);
    } catch (e) {
      print('Failed to add data: $e');
      return Responses(success: false, message: 'Failed to add data');
    }
  }

  Future<Responses> updateData(String collectionName, String documentId,
      Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).update(data);
      return Responses(success: true);
    } catch (e) {
      print('Failed to update data: $e');
      return Responses(success: false, message: 'Failed to update data');
    }
  }

  Future<Responses> deleteData(String collectionName, String documentId) async {
    try {
      await _firestore.collection(collectionName).doc(documentId).delete();
      return Responses(success: true);
    } catch (e) {
      print('Failed to delete data: $e');
      return Responses(success: false, message: 'Failed to delete data');
    }
  }

  // Function to upload audio file to Firebase Storage
  Future<String> uploadAudio(String audioFilePath) async {
    try {
      // Generate a unique filename for the audio file
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.mp3';
      // Get a reference to the audio file in Firebase Storage
      Reference ref = _storage.ref().child('audio/$fileName');
      // Upload the audio file
      TaskSnapshot uploadTask = await ref.putFile(File(audioFilePath));
      // Get the download URL of the uploaded file
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload audio: $e');
      rethrow; // Propagate the exception for handling in the calling code
    }
  }

  Future<String?> checkConversationExists(
      String senderId, String receiverId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("conversations")
          .where("participantIds",
              arrayContainsAny: [senderId, receiverId]).get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          print("Document data: ${doc.data()}");

          print("Document data: ${doc.get("participantIds")}");
          List<dynamic> participantsIds = doc.get("participantIds");
          if (participantsIds.contains(senderId) &&
              participantsIds.contains(receiverId)) {
            // Conversation between sender and receiver exists
            return doc.id; // Return the conversation ID
          }
        }
      } else {
        return null;
      }
    } catch (e) {
      // Error occurred
      print("Error checking conversation: $e");
      rethrow;
    }
    return null;
  }
}
