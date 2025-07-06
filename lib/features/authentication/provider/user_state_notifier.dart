import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/services/user_update_service.dart';
import 'package:metal/core/services/user_migration_service.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
 
/// Comprehensive user state management with improved architecture
class UserStateNotifier extends StateNotifier<UserState> {
  final Ref ref;
  final UserUpdateService _userUpdateService;
  final AuthenticationRepository _authRepository;
  final UserMigrationService _migrationService;

  UserStateNotifier(
    this.ref,
    this._userUpdateService,
    this._authRepository,
    this._migrationService,
  ) : super(UserState.initial()) {
    _initializeUser();
  }

  /// Initialize user state from current authentication with auto-migration
  Future<void> _initializeUser() async {
    try {
      state = UserState.loading();

      final response = await _authRepository.getCurrentUser();

      if (response.success! && response.data != null) {
        // Check if user needs migration
        final userId = response.data['uid'] as String?;
        if (userId != null) {
          final needsMigration = await _migrationService.needsMigration(userId);

          if (needsMigration) {
            // Perform auto-migration
            final migrationResult =
                await _migrationService.migrateUserData(userId);

            if (migrationResult.success!) {
              // Use migrated data
              final user = UserModel.fromJson(migrationResult.data);
              state = UserState.success(user);
              return;
            } else {
              // Migration failed, but continue with existing data
              print('Migration failed: ${migrationResult.message}');
            }
          }
        }

        final user = UserModel.fromJson(response.data);
        state = UserState.success(user);
      } else {
        state = UserState.error(response.message ?? 'Failed to load user');
      }
    } catch (e, stackTrace) {
      state = UserState.error(e.toString());
    }
  }

  /// Update user with single field
  Future<void> updateUserField({
    required String field,
    required dynamic value,
    bool validateRequired = false,
  }) async {
    /// add a delay of 1 second before updating the user
    await Future.delayed(const Duration(seconds: 3));

    if (state.data == null) {
      state = UserState.error('No user data available');
      return;
    }

    try {
      state = UserState.loading();

      final response = await _userUpdateService.updateUser(
        updates: {field: value},
        validateRequired: validateRequired,
      );

      if (response.success!) {
        final updatedUser =  response.data;
        state = UserState.success(updatedUser);
      
     
      } else {
        state = UserState.error(response.message ?? 'Update failed');
      }
    } catch (e, stackTrace) {
      state = UserState.error(e.toString());
    }
  }

  /// Update multiple user fields
  Future<void> updateUserFields({
    required Map<String, dynamic> updates,
    bool validateRequired = false,
  }) async {
    if (state.data == null) {
      state = UserState.error('No user data available');
      return;
    }

    try {
      state = UserState.loading();

      final response = await _userUpdateService.updateUser(
        updates: updates,
        validateRequired: validateRequired,
      );

      if (response.success!) {
        final updatedUser = UserModel.fromJson(response.data);
        state = UserState.success(updatedUser);
      } else {
        state = UserState.error(response.message ?? 'Update failed');
      }
    } catch (e, stackTrace) {
      state = UserState.error(e.toString());
    }
  }

  /// Update specific profile section
  Future<void> updateProfileSection({
    required ProfileSection section,
    required Map<String, dynamic> data,
  }) async {
    if (state.data == null) {
      state = UserState.error('No user data available');
      return;
    }

    try {
      state = UserState.loading();

      final response = await _userUpdateService.updateProfileSection(
        section: section,
        data: data,
      );

      if (response.success!) {
        final updatedUser = UserModel.fromJson(response.data);
        state = UserState.success(updatedUser);
      } else {
        state = UserState.error(response.message ?? 'Section update failed');
      }
    } catch (e, stackTrace) {
      state = UserState.error(e.toString());
    }
  }

  /// Batch update multiple sections
  Future<void> batchUpdateUser({
    required List<Map<String, dynamic>> updateBatches,
    bool validateEachBatch = false,
  }) async {
    if (state.data == null) {
      state = UserState.error('No user data available');
      return;
    }

    try {
      state = UserState.loading();

      final response = await _userUpdateService.batchUpdateUser(
        updateBatches: updateBatches,
        validateEachBatch: validateEachBatch,
      );

      if (response.success!) {
        final updatedUser = UserModel.fromJson(response.data);
        state = UserState.success(updatedUser);
      } else {
        state = UserState.error(response.message ?? 'Batch update failed');
      }
    } catch (e, stackTrace) {
      state = UserState.error(e.toString());
    }
  }

  /// Complete profile setup
  Future<void> completeProfile({
    required Map<String, dynamic> finalData,
  }) async {
    try {
      state = UserState.loading();

      final response = await _userUpdateService.completeProfile(
        finalData: finalData,
      );

      if (response.success!) {
        final updatedUser = UserModel.fromJson(response.data);
        state = UserState.success(updatedUser);
      } else {
        state =
            UserState.error(response.message ?? 'Profile completion failed');
      }
    } catch (e, stackTrace) {
      state = UserState.error(e.toString());
    }
  }

  /// Manually trigger data migration
  Future<void> migrateUserData() async {
    try {
      state = UserState.loading();

      final result = await _migrationService.autoMigrateCurrentUser();

      if (result.success!) {
        if (result.data != null) {
          final user = UserModel.fromJson(result.data);
          state = UserState.success(user);
        } else {
          // Refresh user data after migration
          await refreshUser();
        }
      } else {
        state = UserState.error(result.message ?? 'Migration failed');
      }
    } catch (e) {
      state = UserState.error('Migration error: ${e.toString()}');
    }
  }

  /// Refresh user data from server
  Future<void> refreshUser() async {
    await _initializeUser();
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    final user = state.data;
    if (user == null) return false;

    return user.completedProfile == true &&
        user.fullname != null &&
        user.username != null &&
        user.gender != null &&
        user.dob != null &&
        user.metal != null;
  }

  /// Check if profile is partially complete
  bool get isProfilePartiallyComplete {
    final user = state.data;
    if (user == null) return false;

    return user.profileUpdated == true ||
        user.fullname != null ||
        user.username != null;
  }

  /// Check if user data needs migration
  bool get needsDataMigration {
    final user = state.data;
    if (user == null) return false;

    final userData = user.toJson();

    // Check for common null/missing field issues
    return userData['sparkBalance'] == null ||
        userData['isVerified'] == null ||
        userData['completedProfile'] == null ||
        userData['profileUpdated'] == null ||
        userData['createdAt'] == null ||
        userData['status'] == null;
  }

  /// Get profile completion percentage
  double get profileCompletionPercentage {
    final user = state.data;
    if (user == null) return 0.0;

    final requiredFields = [
      'fullname',
      'username',
      'gender',
      'dob',
      'metal',
      'email',
      'phone',
    ];

    int completedFields = 0;
    for (final field in requiredFields) {
      final value = user.toJson()[field];
      if (value != null && value.toString().isNotEmpty) {
        completedFields++;
      }
    }

    return completedFields / requiredFields.length;
  }

  /// Get missing required fields
  List<String> get missingRequiredFields {
    final user = state.data;
    if (user == null) return [];

    final requiredFields = [
      'fullname',
      'username',
      'gender',
      'dob',
      'metal',
      'email',
      'phone',
    ];

    final missingFields = <String>[];
    final userData = user.toJson();

    for (final field in requiredFields) {
      final value = userData[field];
      if (value == null || value.toString().isEmpty) {
        missingFields.add(field);
      }
    }

    return missingFields;
  }
}

/// User state type alias
typedef UserState = BaseState<UserModel>;

/// Provider for user state notifier with migration support
final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  final userUpdateService = ref.watch(userUpdateServiceProvider);
  final authRepository = ref.watch(authenticationRepositoryProvider);
  final migrationService = ref.watch(userMigrationServiceProvider);

  return UserStateNotifier(
      ref, userUpdateService, authRepository, migrationService);
});

/// Provider for profile completion status
final profileCompletionProvider = Provider<double>((ref) {
  final userState = ref.watch(userStateProvider);
  if (userState.isSuccess && userState.data != null) {
    final notifier = ref.read(userStateProvider.notifier);
    return notifier.profileCompletionPercentage;
  }
  return 0.0;
});

/// Provider for missing required fields
final missingFieldsProvider = Provider<List<String>>((ref) {
  final userState = ref.watch(userStateProvider);
  if (userState.isSuccess && userState.data != null) {
    final notifier = ref.read(userStateProvider.notifier);
    return notifier.missingRequiredFields;
  }
  return [];
});

/// Provider for data migration status
final dataMigrationNeededProvider = Provider<bool>((ref) {
  final userState = ref.watch(userStateProvider);
  if (userState.isSuccess && userState.data != null) {
    final notifier = ref.read(userStateProvider.notifier);
    return notifier.needsDataMigration;
  }
  return false;
});
