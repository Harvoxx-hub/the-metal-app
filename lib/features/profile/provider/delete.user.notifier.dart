import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/data/repositories/authetication.repository.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class DeleteUsersNotifier extends StateNotifier<BaseState<String>> {
  DeleteUsersNotifier(super.state, this.ref);
  final Ref ref;

  Future<void> deleteUser(BuildContext context, {String? feedback}) async {
    try {
      state = BaseState<String>.loading();
      final repo = ref.watch(authenticationRepositoryProvider);

      // Send feedback if provided
      if (feedback != null && feedback.isNotEmpty) {
        await repo.sendFeedback(feedback);
      }

     

      final response = await repo.deleteUser();

      if (mounted) {
        if (response.success == true) {
          // Uninitialize services
          try {
            await ZegoUIKitPrebuiltCallInvitationService().uninit();
          } catch (e) {
            print('Error uninitializing ZegoUIKit: $e');
            // Continue even if uninit fails
          }

          state = BaseState<String>.success(
              response.message ?? "Account deleted successfully");
        } else {
          state = BaseState<String>.error(
              response.message ?? "Failed to delete account");
        }
      }
    } catch (e, s) {
      // If the error is related to user not found, consider it a success
      if (e.toString().toLowerCase().contains('user') &&
          e.toString().toLowerCase().contains('not found')) {
        state = BaseState<String>.success("Account deleted successfully");
      } else {
        state = BaseState<String>.error(e.toString(), stackTrace: s);
      }
    }
  }
}

final deleteUserProvider =
    StateNotifierProvider.autoDispose<DeleteUsersNotifier, BaseState<String>>(
  (ref) => DeleteUsersNotifier(BaseState<String>.initial(), ref),
);
