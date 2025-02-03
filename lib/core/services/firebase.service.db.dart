import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:metal/firebase_options.dart';

class FirebaseServiceDb {
  FirebaseServiceDb._privateConstructor();

  static final FirebaseServiceDb instance =
      FirebaseServiceDb._privateConstructor();

  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  FirebaseAuth get auth => FirebaseAuth.instance;

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  FirebaseStorage get storage => FirebaseStorage.instance;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  /// Create a document in the specified collection
  Future<void> createDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
    String? documentId, // Optional for custom document ID
  }) async {
    try {
      final collectionRef = firestore.collection(collectionPath);
      if (documentId != null) {
        await collectionRef.doc(documentId).set(data);
      } else {
        await collectionRef.add(data);
      }
    } catch (e) {
      throw Exception("Failed to create document: ${e.toString()}");
    }
  }

  /// Read a single document by ID
  Future<Map<String, dynamic>?> readDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      final docSnapshot =
          await firestore.collection(collectionPath).doc(documentId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      throw Exception("Failed to read document: ${e.toString()}");
    }
  }

  /// Read all documents in a collection
  Future<List<Map<String, dynamic>>> readCollection({
    required String collectionPath,
  }) async {
    try {
      final querySnapshot = await firestore.collection(collectionPath).get();
      return querySnapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      throw Exception("Failed to read collection: ${e.toString()}");
    }
  }

  /// Update a document
  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore.collection(collectionPath).doc(documentId).update(data);
    } catch (e) {
      throw Exception("Failed to update document: ${e.toString()}");
    }
  }

  /// Delete a document
  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await firestore.collection(collectionPath).doc(documentId).delete();
    } catch (e) {
      throw Exception("Failed to delete document: ${e.toString()}");
    }
  }

  /// Perform a query with filtering
  Future<List<Map<String, dynamic>>> queryCollection({
    required String collectionPath,
    required String field,
    required dynamic value,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .get();
      return querySnapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      throw Exception("Failed to query collection: ${e.toString()}");
    }
  }

  /// Perform a query with filtering and dynamic query builder
  Future<List<Map<String, dynamic>>> queryBuilderCollection({
    required String collectionPath,
    required Query Function(Query) queryBuilder, // The queryBuilder function
  }) async {
    try {
      // Create the base query object
      Query query = firestore.collection(collectionPath);

      // Apply the queryBuilder function to modify the query
      query = queryBuilder(query);

      // Execute the query and get the snapshot
      final querySnapshot = await query.get();

      // Convert the query snapshot into a list of maps
      return querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>
        }; // Ensure doc.data() is properly casted
      }).toList();
    } catch (e) {
      throw Exception("Failed to query collection: ${e.toString()}");
    }
  }

  Stream<List<Map<String, dynamic>>> queryBuilderCollectionStream({
    required String collectionPath,
    required Query<Map<String, dynamic>> Function(
            Query<Map<String, dynamic>> query)
        queryBuilder,
  }) {
    final query = FirebaseFirestore.instance.collection(collectionPath);
    final modifiedQuery = queryBuilder(query);
    return modifiedQuery.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Listen for real-time updates in a collection
  Stream<List<Map<String, dynamic>>> listenToCollection({
    required String collectionPath,
  }) {
    return firestore
        .collection(collectionPath)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();
    });
  }

  /// Listen for real-time updates on a document
  Stream<Map<String, dynamic>?> listenToDocument({
    required String collectionPath,
    required String documentId,
  }) {
    return firestore
        .collection(collectionPath)
        .doc(documentId)
        .snapshots()
        .map((docSnapshot) {
      return docSnapshot.exists ? docSnapshot.data() : null;
    });
  }

  ///Todo
  Future<void> editThought({
    required String thoughtId,
    required String collectionPath,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      await firestore
          .collection(collectionPath)
          .doc(thoughtId)
          .update(updatedData);
    } catch (e) {
      throw Exception("Failed to edit thought: ${e.toString()}");
    }
  }
}
