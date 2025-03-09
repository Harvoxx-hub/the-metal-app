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
    final user = ref.read(authProvider).data;
    if (user != null) {
      model = user;
      state = UpdateProfileState.success(user);
      print("SOON USER UPDATE: ${user.toJson()}");
    } else {
      print("SOON USER UPDATE: No user data available");
    }
  }

  /// Updates the state with the given [userData]
  void updateUserData(UserModel userData) {
    final currentTime = DateTime.now().toIso8601String();

    // Merge the new data with existing data
    final mergedData = model.copyWith(
      profileUpdated: userData.profileUpdated ?? model.profileUpdated,
      completedProfile: userData.completedProfile ?? model.completedProfile,
      dob: userData.dob ?? model.dob,
      address: userData.address ?? model.address,
      connectWith: userData.connectWith ?? model.connectWith,
      connectionOption: userData.connectionOption ?? model.connectionOption,
      description: userData.description ?? model.description,
      extraData: userData.extraData ?? model.extraData,
      fullname: userData.fullname ?? model.fullname,
      gender: userData.gender ?? model.gender,
      isVerified: userData.isVerified ?? model.isVerified,
      isActivated: userData.isActivated ?? model.isActivated,
      location: userData.location ?? model.location,
      metal: userData.metal ?? model.metal,
      passion: userData.passion ?? model.passion,
      phone: userData.phone ?? model.phone,
      email: userData.email ?? model.email,
      emailVerified: userData.emailVerified ?? model.emailVerified,
      preferences: userData.preferences ?? model.preferences,
      username: userData.username ?? model.username,
      refreshToken: userData.refreshToken ?? model.refreshToken,
      subscription: userData.subscription ?? model.subscription,
      sparkBalance: userData.sparkBalance,
      distance: userData.distance ?? model.distance,
      id: userData.id ?? model.id,
      referralCode: userData.referralCode ?? model.referralCode,
      referredBy: userData.referredBy ?? model.referredBy,
      showOnline: userData.showOnline,
      alwaysMetal: userData.alwaysMetal,
      receiveNotification: userData.receiveNotification,
      showMyProfile: userData.showMyProfile,
      activateVoiceNote: userData.activateVoiceNote,
      activateVoiceCall: userData.activateVoiceCall,
      activateVideoCall: userData.activateVideoCall,
      profilePhoto: userData.profilePhoto ?? model.profilePhoto,
      fcmToken: userData.fcmToken ?? model.fcmToken,
      isOnline: userData.isOnline,
      lastActive: userData.lastActive ?? model.lastActive,
      createdAt: model.createdAt ?? currentTime,
      updatedAt: currentTime, // Always update the updatedAt timestamp
    );

    model = mergedData;
    state = UpdateProfileState.success(mergedData);
  }

  /// Sends the user update to the repository and updates the state accordingly
  Future<void> sendUserUpdate(UserModel userModel) async {
    try {
      state = UpdateProfileState.loading();
      final repository = ref.read(authenticationRepositoryProvider);

      final currentTime = DateTime.now().toIso8601String();

      // Merge with existing data before sending update
      final mergedData = model.copyWith(
        profileUpdated: userModel.profileUpdated ?? model.profileUpdated,
        completedProfile: userModel.completedProfile ?? model.completedProfile,
        dob: userModel.dob ?? model.dob,
        address: userModel.address ?? model.address,
        connectWith: userModel.connectWith ?? model.connectWith,
        connectionOption: userModel.connectionOption ?? model.connectionOption,
        description: userModel.description ?? model.description,
        extraData: userModel.extraData ?? model.extraData,
        fullname: userModel.fullname ?? model.fullname,
        gender: userModel.gender ?? model.gender,
        isVerified: userModel.isVerified ?? model.isVerified,
        isActivated: userModel.isActivated ?? model.isActivated,
        location: userModel.location ?? model.location,
        metal: userModel.metal ?? model.metal,
        passion: userModel.passion ?? model.passion,
        phone: userModel.phone ?? model.phone,
        email: userModel.email ?? model.email,
        emailVerified: userModel.emailVerified ?? model.emailVerified,
        preferences: userModel.preferences ?? model.preferences,
        username: userModel.username ?? model.username,
        createdAt: model.createdAt ?? currentTime,
        updatedAt: currentTime, // Always update the updatedAt timestamp
      );

      final response =
          await repository.updateUser(getNonNullValues(mergedData.toJson()));

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
