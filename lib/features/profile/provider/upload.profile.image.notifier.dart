import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

class ProfileImageNotifier extends StateNotifier<ProfileImageState> {
  ProfileImageNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // melt user
  void UploadProfileImage(File image) async {
    try {
      state = ProfileImageState.loading();
      final repo = ref.watch(authenticationRepositoryProvider);
      final response = await repo.uploadProfileImage(image);

      if (response.success == false) {
        state = ProfileImageState.error(response.message!);
      } else {
        ref.watch(authProvider.notifier).getUpdatedUser();
        state = ProfileImageState.success("");
      }
    } catch (e, s) {
      state = ProfileImageState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef ProfileImageState = BaseState<String>;

final profileImageProvider =
    StateNotifierProvider.autoDispose<ProfileImageNotifier, ProfileImageState>(
  (ref) => ProfileImageNotifier(ProfileImageState.initial(), ref),
);
