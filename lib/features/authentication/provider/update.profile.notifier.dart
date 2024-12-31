import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

/// Notifier for managing and updating user profiles
class UpdateProfileNotifier extends StateNotifier<UpdateProfileState> {
  final Ref ref;
  late UserModel model;

  UpdateProfileNotifier(this.ref) : super(UpdateProfileState.initial()) {
    _initializeProfile();
  }

  /// Initializes the user profile from the auth provider
  Future<void> _initializeProfile() async {
    final user = ref.watch(authProvider).data;
    if (user != null) {
      model = user;
      state = UpdateProfileState.success(user);
    }
  }

  /// Updates the state with the given [userData]
  void updateUserData(UserModel userData) {
    model = userData;
    state = UpdateProfileState.success(userData);
  }

  /// Sends the user update to the repository and updates the state accordingly
  Future<void> sendUserUpdate(UserModel userModel) async {
    try {
      state = UpdateProfileState.loading();
      final repository = ref.read(authenticationRepositoryProvider);
      final response =
          await repository.updateUser(getNonNullValues(userModel.toJson()));

      if (response.success!) {
        final updatedUser = UserModel.fromJson(response.data);
        ref.read(authProvider.notifier).getUpdatedUser();
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
    // Ensure nested objects are serialized
    object.forEach((key, value) {
      if (value is Map) {
        object[key] = getNonNullValues(value as Map<String, dynamic>);
      } else if (value is List) {
        object[key] = value.map((item) {
          if (item is Map) {
            return getNonNullValues(item as Map<String, dynamic>);
          }
          return item;
        }).toList();
      }
    });

    // Remove null values
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
