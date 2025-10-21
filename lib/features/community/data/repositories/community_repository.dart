import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/community/data/domain/entries/community.model.dart';
import 'package:metal/features/community/data/domain/repositories/icommunity_repository.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

class CommunityRepository implements ICommunityRepository {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<Responses> createCommunity(CommunityModel community) async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      // Generate a unique community ID
      final communityId = _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc()
          .id;

      // Prepare community data
      final communityData = {
        'id': communityId,
        'name': community.name,
        'nameLower': community.name.toLowerCase(),
        'description': community.description,
        'bannerImage': community.bannerImage,
        'creatorId': user.uid,
        'creatorName': community.creatorName,
        'memberCount': 1, // Creator is automatically a member
        'isPublic': community.isPublic,
        'tags': community.tags,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'rules': community.rules,
      };

      // Create community document
      await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .set(communityData);

      // Add creator as a member
      await _addCommunityMember(
        communityId,
        user.uid,
        community.creatorName,
        'creator',
      );

      if (community.bannerImage != null) {
        await uploadCommunityImage(community.bannerImage!, communityId);
      }

      return Responses(
        success: true,
        message: "Community created successfully",
        data: communityData,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error creating community: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> getAllCommunities() async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .orderBy('memberCount', descending: true)
          .get();

      final communities = <CommunityModel>[];

      for (final doc in querySnapshot.docs) {
        final communityData = doc.data();

        // Check if current user is a member of this community
        final memberDoc = await _firebaseService.firestore
            .collection(FirebaseFirestoreCollectionKeys.communities)
            .doc(doc.id)
            .collection(FirebaseFirestoreCollectionKeys.communityMembers)
            .doc(user.uid)
            .get();

        final isJoined = memberDoc.exists;

        final community = CommunityModel.fromJson({
          ...communityData,
          'isJoined': isJoined,
        });

        communities.add(community);
      }

      return Responses(
        success: true,
        message: "Communities retrieved successfully",
        data: communities,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error fetching communities: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> getCommunitiesByCategory(String category) async {
    try {
      final user = _firebaseService.auth.currentUser;

      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .where('tags', arrayContains: category)
          .orderBy('memberCount', descending: true)
          .get();

      final communities = <CommunityModel>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        bool isJoined = false;
        if (user != null) {
          final memberDoc = await _firebaseService.firestore
              .collection(FirebaseFirestoreCollectionKeys.communities)
              .doc(doc.id)
              .collection(FirebaseFirestoreCollectionKeys.communityMembers)
              .doc(user.uid)
              .get();
          isJoined = memberDoc.exists;
        }

        communities.add(
          CommunityModel.fromJson({
            ...data,
            'isJoined': isJoined,
          }),
        );
      }

      return Responses(
        success: true,
        message: "Communities retrieved successfully",
        data: communities,
      );
    } catch (e) {
      print(e);
      return Responses(
        success: false,
        message: "Error fetching communities: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> searchCommunities(String query) async {
    try {
      final user = _firebaseService.auth.currentUser;

      // Case-insensitive search using precomputed lowercase field
      final lower = query.toLowerCase();
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .where('nameLower', isGreaterThanOrEqualTo: lower)
          .where('nameLower', isLessThan: lower + '\uf8ff')
          .orderBy('memberCount', descending: true)
          .get();

      final communities = <CommunityModel>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        bool isJoined = false;
        if (user != null) {
          final memberDoc = await _firebaseService.firestore
              .collection(FirebaseFirestoreCollectionKeys.communities)
              .doc(doc.id)
              .collection(FirebaseFirestoreCollectionKeys.communityMembers)
              .doc(user.uid)
              .get();
          isJoined = memberDoc.exists;
        }

        communities.add(
          CommunityModel.fromJson({
            ...data,
            'isJoined': isJoined,
          }),
        );
      }

      return Responses(
        success: true,
        message: "Search results retrieved successfully",
        data: communities,
      );
    } catch (e) {
      print(e);
      return Responses(
        success: false,
        message: "Error searching communities: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> getCommunityById(String communityId) async {
    try {
      final docSnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .get();

      if (!docSnapshot.exists) {
        return Responses(
          success: false,
          message: "Community not found",
        );
      }

      final community = CommunityModel.fromJson(docSnapshot.data()!);

      return Responses(
        success: true,
        message: "Community retrieved successfully",
        data: community,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error fetching community: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> joinCommunity(String communityId, String userId) async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      // Check if user is already a member
      final memberDoc = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .collection(FirebaseFirestoreCollectionKeys.communityMembers)
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        return Responses(
          success: false,
          message: "User is already a member of this community",
        );
      }

      // Get user data
      final userDoc = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.users)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return Responses(
          success: false,
          message: "User not found",
        );
      }

      final userData = userDoc.data()!;
      final userName =
          userData['fullname'] ?? userData['username'] ?? 'Unknown';

      // Add user as member (only if they don't already exist)
      await _addCommunityMember(communityId, userId, userName, 'member');

      // Update member count
      await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .update({
        'memberCount': FieldValue.increment(1),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Responses(
        success: true,
        message: "Successfully joined community",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error joining community: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> leaveCommunity(String communityId, String userId) async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      // Check if user is a member
      final memberDoc = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .collection(FirebaseFirestoreCollectionKeys.communityMembers)
          .doc(userId)
          .get();

      if (!memberDoc.exists) {
        return Responses(
          success: false,
          message: "User is not a member of this community",
        );
      }

      // Check if user is the creator
      final memberData = memberDoc.data()!;
      if (memberData['role'] == 'creator') {
        return Responses(
          success: false,
          message: "Creator cannot leave the community",
        );
      }

      // Remove user from members
      await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .collection(FirebaseFirestoreCollectionKeys.communityMembers)
          .doc(userId)
          .delete();

      // Update member count
      await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .update({
        'memberCount': FieldValue.increment(-1),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Responses(
        success: true,
        message: "Successfully left community",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error leaving community: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> getUserCommunities(String userId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .where('members', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final communities = querySnapshot.docs
          .map((doc) => CommunityModel.fromJson(doc.data()))
          .toList();

      return Responses(
        success: true,
        message: "User communities retrieved successfully",
        data: communities,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error fetching user communities: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> isUserMemberOfCommunity(
      String communityId, String userId) async {
    try {
      final memberDoc = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .collection(FirebaseFirestoreCollectionKeys.communityMembers)
          .doc(userId)
          .get();

      return Responses(
        success: true,
        message: "Membership check completed",
        data: memberDoc.exists,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error checking membership: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> getCommunityMembers(String communityId) async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .collection(FirebaseFirestoreCollectionKeys.communityMembers)
          .orderBy('joinedAt', descending: false)
          .get();

      final members = querySnapshot.docs.map((doc) => doc.data()).toList();

      return Responses(
        success: true,
        message: "Community members retrieved successfully",
        data: members,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error fetching community members: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> updateCommunity(CommunityModel community) async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      // Check if user is the creator
      final communityDoc = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(community.id)
          .get();

      if (!communityDoc.exists) {
        return Responses(
          success: false,
          message: "Community not found",
        );
      }

      final communityData = communityDoc.data()!;
      if (communityData['creatorId'] != user.uid) {
        return Responses(
          success: false,
          message: "Only the creator can update the community",
        );
      }

      // Update community
      await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(community.id)
          .update({
        'name': community.name,
        'nameLower': community.name.toLowerCase(),
        'description': community.description,
        'bannerImage': community.bannerImage,
        'tags': community.tags,
        'rules': community.rules,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Responses(
        success: true,
        message: "Community updated successfully",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error updating community: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> deleteCommunity(String communityId, String userId) async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      // Check if user is the creator
      final communityDoc = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .get();

      if (!communityDoc.exists) {
        return Responses(
          success: false,
          message: "Community not found",
        );
      }

      final communityData = communityDoc.data()!;
      if (communityData['creatorId'] != user.uid) {
        return Responses(
          success: false,
          message: "Only the creator can delete the community",
        );
      }

      // Delete community (this will also delete subcollections)
      await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .delete();

      return Responses(
        success: true,
        message: "Community deleted successfully",
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error deleting community: ${e.toString()}",
      );
    }
  }

  @override
  Future<Responses> uploadCommunityImage(
      String filePath, String communityId) async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      // Create reference to the file
      final ref = _storage
          .ref()
          .child('communities')
          .child(communityId)
          .child('banner_${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload file
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update community with image URL
      await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.communities)
          .doc(communityId)
          .update({
        'bannerImage': downloadUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Responses(
        success: true,
        message: "Image uploaded successfully",
        data: downloadUrl,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Error uploading image: ${e.toString()}",
      );
    }
  }

  /// Helper method to add a community member
  Future<void> _addCommunityMember(
    String communityId,
    String userId,
    String userName,
    String role,
  ) async {
    // Check if member already exists
    final existingMemberDoc = await _firebaseService.firestore
        .collection(FirebaseFirestoreCollectionKeys.communities)
        .doc(communityId)
        .collection(FirebaseFirestoreCollectionKeys.communityMembers)
        .doc(userId)
        .get();

    // If member already exists, don't overwrite their data
    if (existingMemberDoc.exists) {
      return;
    }

    // Get user profile photo and metal for new members
    String? userPhoto;
    String? userMetal;
    try {
      final userDoc = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.users)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userPhoto = userData['profilePhoto'];
        userMetal = userData['metal'];
      }
    } catch (e) {
      // If we can't get the profile photo, continue with null
      print('Error fetching user profile photo: $e');
    }

    final memberData = {
      'id': userId,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      "metal": userMetal,
      'role': role,
      'joinedAt': DateTime.now().toIso8601String(),
      'isActive': true,
    };

    await _firebaseService.firestore
        .collection(FirebaseFirestoreCollectionKeys.communities)
        .doc(communityId)
        .collection(FirebaseFirestoreCollectionKeys.communityMembers)
        .doc(userId)
        .set(memberData);
  }

  @override
  Future<Responses> getCommunityThoughts(String communityId) async {
    try {
      // Query thoughts collection for posts with matching communityMetadata.communityId
      final querySnapshot = await _firebaseService.firestore
          .collection(FirebaseFirestoreCollectionKeys.thoughts)
          .where('communityMetadata.communityId', isEqualTo: communityId)
          .orderBy('createdAt', descending: true)
          .get();

      final thoughts = <ThoughtModel>[];

      for (final doc in querySnapshot.docs) {
        final thoughtData = doc.data();
        final thought = ThoughtModel.fromJson(thoughtData);
        thoughts.add(thought);
      }

      return Responses(
        success: true,
        message: "Community thoughts retrieved successfully",
        data: thoughts,
      );
    } catch (e) {
      print(e);
      return Responses(
        success: false,
        message: "Error fetching community thoughts: ${e.toString()}",
      );
    }
  }
}
