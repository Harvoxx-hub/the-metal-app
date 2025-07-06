import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
 
import 'package:metal/features/authentication/provider/user_state_notifier.dart';

class ProfileImageNotifier extends StateNotifier<ProfileImageState> {
  ProfileImageNotifier(
    super.state,
    this.ref,
  );

  final Ref ref;

  // Upload user profile image
  void UploadProfileImage(File image) async {
    try {
      state = ProfileImageState.loading();
      // Show uploading toast
      Fluttertoast.showToast(
        msg: "Uploading image...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      final repo = ref.read(authenticationRepositoryProvider);
      final response = await repo.uploadProfileImage(image);

      if (response.success == false) {
        state = ProfileImageState.error(response.message!);
        // Show error toast
        Fluttertoast.showToast(
          msg: response.message ?? "Upload failed",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        ref.read(userStateProvider.notifier).refreshUser();
        state = ProfileImageState.success("");
        // Show success toast
        Fluttertoast.showToast(
          msg: "Image uploaded successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e, s) {
      state = ProfileImageState.error(e.toString(), stackTrace: s);
      // Show error toast
      Fluttertoast.showToast(
        msg: "Upload failed: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}

// Define a type alias
typedef ProfileImageState = BaseState<String>;

final profileImageProvider =
    StateNotifierProvider<ProfileImageNotifier, ProfileImageState>(
  (ref) => ProfileImageNotifier(ProfileImageState.initial(), ref),
);
