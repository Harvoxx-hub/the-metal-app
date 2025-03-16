import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

/// Notifier for managing and updating user profiles
class UpdateProfileNotifier extends StateNotifier<UpdateProfileState> {
  final Ref ref;
  UserModel? _model;

  UpdateProfileNotifier(this.ref) : super(UpdateProfileState.initial()) {
    _initializeProfile();
  }

  /// Initializes the user profile from the auth provider
  Future<void> _initializeProfile() async {
    final user = ref.read(authProvider).data;
    if (user != null) {
      _model = user;
      
      print("SOON USER UPDATE: ${user.toJson()}");
    } else {
      print("SOON USER UPDATE: No user data available");
    }
  }

  /// Updates the state with the given [userData] map
  void updateUserData(Map<String, dynamic> userData) {
    if (_model == null) return;

    final currentTime = DateTime.now().toIso8601String();

    // Create a merged map combining existing data with new data
    final Map<String, dynamic> mergedData = _model!.toJson();

    // Update the merged data with new values from userData
    userData.forEach((key, value) {
      if (value != null) {
        mergedData[key] = value;
      }
    });

    // Ensure updatedAt is set
    mergedData['updatedAt'] = currentTime;

    // Convert back to UserModel and update state
    _model = UserModel.fromJson(mergedData);
   
  }

  /// Sends the user update to the repository and updates the state accordingly
  Future<void> sendUserUpdate() async {
    if (_model == null) return;

    try {
      state = UpdateProfileState.loading();
      final repository = ref.read(authenticationRepositoryProvider);
      final currentTime = DateTime.now().toIso8601String();

      // Create a merged map combining existing data with new data
      final Map<String, dynamic> mergedData = _model!.toJson();

      // Update the merged data with new values from userData
       

      // Ensure updatedAt is set
      mergedData['updatedAt'] = currentTime;

      final response =
          await repository.updateUser(getNonNullValues(mergedData));

      if (response.success!) {
        final updatedUser = UserModel.fromJson(response.data);
    await    ref.read(authProvider.notifier).getUpdatedUser();
        state = UpdateProfileState.success(updatedUser);
      } else {
        state =
            UpdateProfileState.error(response.message ?? 'An error occurred');
      }
    } catch (e, stackTrace) {
      state = UpdateProfileState.error(e.toString(), stackTrace: stackTrace);
    }
  }

  /// Filters out null values from a map
  Map<String, dynamic> getNonNullValues(Map<String, dynamic> object) {
    return object..removeWhere((key, value) => value == null);
  }
}

/// Type alias for the profile update state
typedef UpdateProfileState = BaseState<UserModel>;

/// Provider for the [UpdateProfileNotifier]
final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, UpdateProfileState>(
  (ref) => UpdateProfileNotifier(ref),
);
