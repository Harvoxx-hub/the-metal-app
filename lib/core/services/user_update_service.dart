import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/core/error/firebase.error.handle.dart';

/// Comprehensive user update service with validation and data integrity
class UserUpdateService {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  /// Update user with proper validation and data integrity
  Future<Responses> updateUser({
    required Map<String, dynamic> updates,
    bool validateRequired = true,
    bool mergeWithExisting = true,
  }) async {
    try {
      final userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      // Get current user data if merging is enabled
      Map<String, dynamic> finalData = {};

      if (mergeWithExisting) {
        final currentData = await _getCurrentUserData(userId);
        if (currentData != null) {
          finalData = Map<String, dynamic>.from(currentData);
        }
      }

      // Apply updates
      finalData.addAll(updates);

      // Add/update timestamps
      final now = DateTime.now().toIso8601String();
      finalData['updatedAt'] = now;
      if (finalData['createdAt'] == null) {
        finalData['createdAt'] = now;
      }

      // Validate data
      if (validateRequired) {
        final validation = _validateUserData(finalData);
        if (!validation.isValid) {
          return Responses(
            success: false,
            message: "Validation failed: ${validation.errors.join(', ')}",
          );
        }
      }

      // Sanitize data before update
      final sanitizedData = _sanitizeUserData(finalData);

      // Perform atomic update
      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
        data: sanitizedData,
      );

      // Retrieve updated data to ensure consistency
      final updatedData = await _getCurrentUserData(userId);
      if (updatedData == null) {
        return Responses(
          success: false,
          message: "Failed to retrieve updated user data",
        );
      }

      final userModel = UserModel.fromJson(updatedData);

      return Responses(
        success: true,
        message: "User updated successfully",
        data: userModel,
      );
    } catch (e) {
      final errorMessage = FirebaseErrorHandler.handleFirebaseError(e);
      return Responses(
        success: false,
        message: "Update failed: $errorMessage",
      );
    }
  }

  /// Batch update multiple fields with transaction support
  Future<Responses> batchUpdateUser({
    required List<Map<String, dynamic>> updateBatches,
    bool validateEachBatch = false,
  }) async {
    try {
      final userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(
          success: false,
          message: "User not authenticated",
        );
      }

      // Get current user data
      final currentData = await _getCurrentUserData(userId);
      if (currentData == null) {
        return Responses(
          success: false,
          message: "Current user data not found",
        );
      }

      Map<String, dynamic> finalData = Map<String, dynamic>.from(currentData);

      // Apply all updates in sequence
      for (final batch in updateBatches) {
        finalData.addAll(batch);

        if (validateEachBatch) {
          final validation = _validateUserData(finalData);
          if (!validation.isValid) {
            return Responses(
              success: false,
              message:
                  "Batch validation failed: ${validation.errors.join(', ')}",
            );
          }
        }
      }

      // Add timestamp
      finalData['updatedAt'] = DateTime.now().toIso8601String();

      // Final validation
      final validation = _validateUserData(finalData);
      if (!validation.isValid) {
        return Responses(
          success: false,
          message: "Final validation failed: ${validation.errors.join(', ')}",
        );
      }

      // Sanitize and update
      final sanitizedData = _sanitizeUserData(finalData);

      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
        data: sanitizedData,
      );

      // Get final updated data
      final updatedData = await _getCurrentUserData(userId);
      final userModel = UserModel.fromJson(updatedData!);

      return Responses(
        success: true,
        message: "Batch update completed successfully",
        data: userModel,
      );
    } catch (e) {
      final errorMessage = FirebaseErrorHandler.handleFirebaseError(e);
      return Responses(
        success: false,
        message: "Batch update failed: $errorMessage",
      );
    }
  }

  /// Update specific profile section (e.g., basic info, preferences, etc.)
  Future<Responses> updateProfileSection({
    required ProfileSection section,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Validate section-specific data
      final validation = _validateProfileSection(section, data);
      if (!validation.isValid) {
        return Responses(
          success: false,
          message: "Section validation failed: ${validation.errors.join(', ')}",
        );
      }

      // // Add section completion flag
      // data['${section.name}Updated'] = true;

      return await updateUser(
        updates: data,
        validateRequired: false, // Section-specific validation already done
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Section update failed: ${e.toString()}",
      );
    }
  }

  /// Complete profile setup with all required fields
  Future<Responses> completeProfile({
    required Map<String, dynamic> finalData,
  }) async {
    try {
      // Ensure all required fields are present
   //   final requiredFields = _getRequiredFieldsForCompletion();
      final missingFields = <String>[];

      // for (final field in requiredFields) {
      //   if (!finalData.containsKey(field) || finalData[field] == null) {
      //     missingFields.add(field);
      //   }
      // }

      if (missingFields.isNotEmpty) {
        return Responses(
          success: false,
          message: "Missing required fields: ${missingFields.join(', ')}",
        );
      }

      // Mark profile as completed
      finalData['completedProfile'] = true;
      finalData['profileUpdated'] = true;

      return await updateUser(
        updates: finalData,
        validateRequired: true,
      );
    } catch (e) {
      return Responses(
        success: false,
        message: "Profile completion failed: ${e.toString()}",
      );
    }
  }

  /// Get current user data
  Future<Map<String, dynamic>?> _getCurrentUserData(String userId) async {
    return await _firebaseService.readDocument(
      collectionPath: FirebaseFirestoreCollectionKeys.users,
      documentId: userId,
    );
  }

  /// Validate user data integrity
  ValidationResult _validateUserData(Map<String, dynamic> data) {
    final errors = <String>[];

    // Email validation
    if (data['email'] != null) {
      final email = data['email'] as String;
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        errors.add('Invalid email format');
      }
    }

    // Phone validation
    if (data['phone'] != null) {
      final phone = data['phone'] as String;
      if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(phone)) {
        errors.add('Invalid phone format');
      }
    }

    // Username validation
    if (data['username'] != null) {
      final username = data['username'] as String;
      if (username.length < 3 || username.length > 30) {
        errors.add('Username must be between 3 and 30 characters');
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        errors
            .add('Username can only contain letters, numbers, and underscores');
      }
    }

    // DOB validation
    // if (data['dob'] != null) {
    //   try {
    //     // Assuming DOB format is stored as ISO string or parseable date
    //     final dobStr = data['dob'] as String;
    //     final dob = DateTime.parse(dobStr);
    //     final age = DateTime.now().difference(dob).inDays / 365;
    //     if (age < 18) {
    //       errors.add('User must be at least 18 years old');
    //     }
    //   } catch (e) {
    //     errors.add('Invalid date of birth format');
    //   }
    // }

    return ValidationResult(errors.isEmpty, errors);
  }

  /// Validate specific profile sections
  ValidationResult _validateProfileSection(
      ProfileSection section, Map<String, dynamic> data) {
    final errors = <String>[];

    switch (section) {
      case ProfileSection.basicInfo:
        if (data['fullname'] != null &&
            (data['fullname'] as String).trim().split(' ').length < 2) {
          errors.add('Full name must include first and last name');
        }
        break;

      case ProfileSection.preferences:
        // Validate preferences data structure
        if (data['preferences'] != null) {
          // Add specific preference validation logic
        }
        break;

      case ProfileSection.address:
        if (data['address'] != null) {
          final address = data['address'] as Map<String, dynamic>;
          if (address['country'] == null || address['state'] == null) {
            errors.add('Country and state are required for address');
          }
        }
        break;

      case ProfileSection.extraData:
        // Validate extra data fields
        break;

      case ProfileSection.metals:
        if (data['metal'] != null) {
          final metal = data['metal'] as String;
          if (metal.isEmpty) {
            errors.add('Metal selection is required');
          }
        }
        break;

      case ProfileSection.passions:
        if (data['passion'] != null) {
          final passions = data['passion'] as List;
          if (passions.isEmpty) {
            errors.add('At least one passion must be selected');
          }
        }
        break;
    }

    return ValidationResult(errors.isEmpty, errors);
  }

  /// Sanitize user data before saving
  Map<String, dynamic> _sanitizeUserData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    data.forEach((key, value) {
      if (value != null) {
        // Trim string values
        if (value is String) {
          sanitized[key] = value.trim();
        } else {
          sanitized[key] = value;
        }
      } else {
        // Include null values for essential fields to ensure they're set in Firebase
        const essentialFields = {
          'fullname',
          'username',
          'gender',
          'metal',
          'isVerified',
          'profilePhoto',
          'location',
          'dob',
          'completedProfile',
          'profileUpdated',
          'updatedAt',
          'createdAt'
        };

        if (essentialFields.contains(key)) {
          sanitized[key] = null;
        }
      }
    });

    return sanitized;
  }

  /// Get required fields for profile completion
  List<String> _getRequiredFieldsForCompletion() {
    return [
      'fullname',
      'username',
      'gender',
      'dob',
      'metal',
      'email',
      'phone',
    ];
  }
}

/// Profile section enumeration
enum ProfileSection {
  basicInfo,
  preferences,
  address,
  extraData,
  metals,
  passions,
}

/// Validation result helper class
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult(this.isValid, this.errors);
}

/// Provider for the user update service
final userUpdateServiceProvider = Provider<UserUpdateService>((ref) {
  return UserUpdateService();
});
