import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/core/utils/constant/firebase.firestore.collection.key.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/core/error/firebase.error.handle.dart';

/// Service to handle data migration and fix null user data issues
class UserMigrationService {
  final FirebaseServiceDb _firebaseService = FirebaseServiceDb.instance;

  /// Check if user needs data migration
  Future<bool> needsMigration(String userId) async {
    try {
      final userData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
      );

      if (userData == null) return false;

      // Check for critical null fields that should have defaults
      final criticalFields = {
        'fullname': '',
        'username': null,
        'gender': null,
        'metal': null,
        'isVerified': false,
        'sparkBalance': 0,
        'location': null,
        'profilePhoto': null,
        'completedProfile': false,
        'profileUpdated': false,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      bool needsMigration = false;

      for (final entry in criticalFields.entries) {
        final key = entry.key;
        final defaultValue = entry.value;

        if (!userData.containsKey(key)) {
          needsMigration = true;
          break;
        }

        // Special cases where null should be replaced with defaults
        if (key == 'sparkBalance' && userData[key] == null) {
          needsMigration = true;
          break;
        }

        if (key == 'isVerified' && userData[key] == null) {
          needsMigration = true;
          break;
        }

        if (key == 'completedProfile' && userData[key] == null) {
          needsMigration = true;
          break;
        }

        if (key == 'profileUpdated' && userData[key] == null) {
          needsMigration = true;
          break;
        }
      }

      return needsMigration;
    } catch (e) {
      // If we can't check, assume migration is needed
      return true;
    }
  }

  /// Migrate user data with proper defaults
  Future<Responses> migrateUserData(String userId) async {
    try {
      // Get current user data
      final currentData = await _firebaseService.readDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
      );

      if (currentData == null) {
        return Responses(
          success: false,
          message: "User data not found",
        );
      }

      // Create migrated data with proper defaults
      final migratedData = _applyDataMigration(currentData);

      // Update with migrated data
      await _firebaseService.updateDocument(
        collectionPath: FirebaseFirestoreCollectionKeys.users,
        documentId: userId,
        data: migratedData,
      );

      return Responses(
        success: true,
        message: "User data migrated successfully",
        data: migratedData,
      );
    } catch (e) {
      final errorMessage = FirebaseErrorHandler.handleFirebaseError(e);
      return Responses(
        success: false,
        message: "Migration failed: $errorMessage",
      );
    }
  }

  /// Apply migration logic to user data
  Map<String, dynamic> _applyDataMigration(Map<String, dynamic> userData) {
    final migratedData = Map<String, dynamic>.from(userData);
    final now = DateTime.now().toIso8601String();

    // Ensure essential fields have proper defaults
    final fieldDefaults = {
      'sparkBalance': 0,
      'isVerified': false,
      'completedProfile': false,
      'profileUpdated': false,
      'createdAt': now,
      'updatedAt': now,
      'status': 'active',
      'isOnline': false,
    };

    // Apply defaults for missing or null essential fields
    fieldDefaults.forEach((key, defaultValue) {
      if (!migratedData.containsKey(key) || migratedData[key] == null) {
        migratedData[key] = defaultValue;
      }
    });

    // Special handling for specific fields

    // If fullname is null but we have email, extract name from email
    if ((migratedData['fullname'] == null || migratedData['fullname'] == '') &&
        migratedData['email'] != null) {
      final email = migratedData['email'] as String;
      final emailUsername = email.split('@').first;
      migratedData['fullname'] = _generateDisplayNameFromEmail(emailUsername);
    }

    // If username is null, generate one
    if (migratedData['username'] == null || migratedData['username'] == '') {
      migratedData['username'] = _generateUsername(migratedData);
    }

    // Ensure timestamps are properly set
    if (migratedData['createdAt'] == null) {
      migratedData['createdAt'] = now;
    }
    migratedData['updatedAt'] = now;

    // Add migration marker
    migratedData['dataMigrated'] = true;
    migratedData['migrationDate'] = now;

    return migratedData;
  }

  /// Generate a display name from email
  String _generateDisplayNameFromEmail(String emailUsername) {
    // Convert email username to a readable name
    String name = emailUsername.replaceAll(RegExp(r'[^a-zA-Z]'), ' ');
    name = name.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (name.isNotEmpty) {
      // Capitalize first letter of each word
      return name.split(' ').map((word) {
        if (word.isNotEmpty) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }
        return word;
      }).join(' ');
    }

    return 'Metal User';
  }

  /// Generate a username from available data
  String _generateUsername(Map<String, dynamic> userData) {
    String baseUsername = 'metaluser';

    // Try to use email username
    if (userData['email'] != null) {
      final email = userData['email'] as String;
      final emailUsername = email.split('@').first;
      baseUsername = emailUsername.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    }

    // Try to use fullname
    else if (userData['fullname'] != null && userData['fullname'] != '') {
      final fullname = userData['fullname'] as String;
      baseUsername = fullname
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .replaceAll(' ', '');
    }

    // Try to use uid suffix
    else if (userData['uid'] != null) {
      final uid = userData['uid'] as String;
      if (uid.length > 8) {
        baseUsername = 'metaluser${uid.substring(uid.length - 8)}';
      }
    }

    // Ensure username is not too long
    if (baseUsername.length > 20) {
      baseUsername = baseUsername.substring(0, 20);
    }

    // Add random suffix if too short
    if (baseUsername.length < 3) {
      baseUsername =
          'metaluser${DateTime.now().millisecondsSinceEpoch % 10000}';
    }

    return baseUsername.toLowerCase();
  }

  /// Batch migrate multiple users
  Future<List<Responses>> batchMigrateUsers(List<String> userIds) async {
    final results = <Responses>[];

    for (final userId in userIds) {
      try {
        final needsMigration = await this.needsMigration(userId);
        if (needsMigration) {
          final result = await migrateUserData(userId);
          results.add(result);
        } else {
          results.add(Responses(
            success: true,
            message: "User $userId does not need migration",
          ));
        }
      } catch (e) {
        results.add(Responses(
          success: false,
          message: "Failed to migrate user $userId: ${e.toString()}",
        ));
      }
    }

    return results;
  }

  /// Auto-migrate current user if needed
  Future<Responses> autoMigrateCurrentUser() async {
    try {
      final userId = _firebaseService.userId;
      if (userId == null) {
        return Responses(
          success: false,
          message: "No authenticated user",
        );
      }

      final needsMigration = await this.needsMigration(userId);
      if (needsMigration) {
        return await migrateUserData(userId);
      } else {
        return Responses(
          success: true,
          message: "User data is up to date",
        );
      }
    } catch (e) {
      return Responses(
        success: false,
        message: "Auto-migration failed: ${e.toString()}",
      );
    }
  }

  /// Validate migrated data
  bool validateMigratedData(Map<String, dynamic> data) {
    final requiredFields = [
      'sparkBalance',
      'isVerified',
      'completedProfile',
      'profileUpdated',
      'createdAt',
      'updatedAt',
      'status',
    ];

    for (final field in requiredFields) {
      if (!data.containsKey(field)) {
        return false;
      }
    }

    // Type checking
    if (data['sparkBalance'] is! int) return false;
    if (data['isVerified'] is! bool) return false;
    if (data['completedProfile'] is! bool) return false;
    if (data['profileUpdated'] is! bool) return false;

    return true;
  }
}

/// Provider for user migration service
final userMigrationServiceProvider = Provider<UserMigrationService>((ref) {
  return UserMigrationService();
});
