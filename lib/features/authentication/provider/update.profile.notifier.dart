import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

class UpdateProfileNotifier extends StateNotifier<UpdateProfileState> {
  UpdateProfileNotifier(
    super.state,
    this.ref,
  ) {
    initMyProfile();
  }
  final Ref ref;
  UserModel model = UserModel();
//init my profile
  void initMyProfile() async {
    state = UpdateProfileState.success(UserModel());
  }

  //update usermodel from user data
  void updateUserData(UserModel userData) {
    model = userData;
    state = UpdateProfileState.success(userData);
    print(state.data!.toJson());
  }

  Future<void> sendUserUpdate(UserModel userModel) async {
    try {
      state = UpdateProfileState.loading();
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository
          .updateUser(getNonNullValues(userModel.toJson()));
      final userData = UserModel.fromJson(response.data);

      ref.read(authProvider.notifier).getUpdatedUser();
      state = UpdateProfileState.success(userData);
    } catch (e) {
      state = UpdateProfileState.error(e.toString());
    }
  }

  Future<void> updateParticularInfor(UserModel userModel) async {
    try {
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository.UpdateParticualarInfo(
          getNonNullValues(userModel.toJson()));
      final userData = UserModel.fromJson(response.data);

      ref.read(authProvider.notifier).getUpdatedUser();
      Fluttertoast.showToast(
          msg: "Profile Updated",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      state = UpdateProfileState.success(userData);
    } catch (e) {
      state = UpdateProfileState.error(e.toString());
    }
  }

  Future<void> completeUserUpdate(UserModel userModel) async {
    try {
      state = UpdateProfileState.loading();
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository
          .completeUser(getNonNullValues(userModel.toJson()));
      final userData = UserModel.fromJson(response.data);

      await ref.read(authProvider.notifier).getUpdatedUser();
      state = UpdateProfileState.success(userData);
    } catch (e) {
      print(e.toString());
      state = UpdateProfileState.error(e.toString());
    }
  }

  Map<String, dynamic> getNonNullValues(Map<String, dynamic> object) {
    Map<String, dynamic> nonNullValues = {};
    object.forEach((key, value) {
      if (value != null) {
        nonNullValues[key] = value;
      }
    });
    return nonNullValues;
  }
}

// Define a type alias
typedef UpdateProfileState = BaseState<UserModel>;

final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, UpdateProfileState>(
  (ref) => UpdateProfileNotifier(UpdateProfileState.initial(), ref),
);
