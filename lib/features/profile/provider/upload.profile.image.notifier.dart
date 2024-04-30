import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

class ProfileImageNotifier extends StateNotifier<ProfileImageState> {
  ProfileImageNotifier(
    ProfileImageState state,
    this.ref,
  ) : super(state) {}
  final Ref ref;

  // melt user
  void UploadProfileImage(File image) async {
    try {
      state = ProfileImageState.loading();
      final repo = ref.watch(authenticationRepositoryProvider);
      final response = await repo.uploadProfileImage(image);
      ref.watch(authProvider.notifier).getUpdatedUser();
      if (mounted) {
        state = ProfileImageState.success(response.message!);
      }
    } catch (e) {
      print(e.toString());
      state = ProfileImageState.error(e.toString());
    }
  }
}

// Define a type alias
typedef ProfileImageState = BaseState<String>;

final profileImageProvider =
    StateNotifierProvider.autoDispose<ProfileImageNotifier, ProfileImageState>(
  (ref) => ProfileImageNotifier(ProfileImageState.initial(), ref),
);
