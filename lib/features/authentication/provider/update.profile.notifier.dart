 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

class UpdateProfileNotifier extends StateNotifier<UpdateProfileState> {
  final Ref ref;
  UserModel model = UserModel();

  UpdateProfileNotifier(this.ref) : super(UpdateProfileState.initial()) {
    initMyProfile();
  }

  void initMyProfile() async {
    state = UpdateProfileState.success(UserModel());
  }

  void updateUserData(UserModel userData) {
     state = UpdateProfileState.success(userData);
    model = userData;
    

print(userData.toString());
  }

  Future<void> sendUserUpdate(UserModel userModel) async {
    try {
      state = UpdateProfileState.loading();
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository
          .updateUser(getNonNullValues(model.toJson()));
      final userData = UserModel.fromJson(response.data);

      ref.read(authProvider.notifier).getUpdatedUser();
      state = UpdateProfileState.success(userData);
    } catch (e, s) {
      state = UpdateProfileState.error(e.toString(), stackTrace: s);
    }
  }

  Future<void> updateParticularInfo(UserModel userModel) async {
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
        fontSize: 16.0,
      );
      state = UpdateProfileState.success(userData);
    } catch (e, s) {
      state = UpdateProfileState.error(e.toString(), stackTrace: s);
    }
  }

  Future<void> completeUserUpdate(UserModel userModel) async {
    try {
      state = UpdateProfileState.loading();
      final authenticationRepository =
          ref.watch(authenticationRepositoryProvider);
      final response = await authenticationRepository
          .completeUser(getNonNullValues(model.toJson()));
      final userData = UserModel.fromJson(response.data);

      await ref.read(authProvider.notifier).getUpdatedUser();
      state = UpdateProfileState.success(userData);
    } catch (e, s) {
      state = UpdateProfileState.error(e.toString(), stackTrace: s);
    }
  }

  Map<String, dynamic> getNonNullValues(Map<String, dynamic> object) {
    return object..removeWhere((key, value) => value == null);
  }
}

typedef UpdateProfileState = BaseState<UserModel>;

final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, UpdateProfileState>(
  (ref) => UpdateProfileNotifier(ref),
);
