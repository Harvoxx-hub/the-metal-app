import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          await ZegoUIKitPrebuiltCallInvitationService().uninit();

          state = BaseState<String>.success(
              response.message ?? "Account deleted successfully");

        } else {
          state = BaseState<String>.error(
              response.message ?? "Failed to delete account");
        }
      }
    } catch (e, s) {
      state = BaseState<String>.error(e.toString(), stackTrace: s);
    }
  }
}

final deleteUserProvider =
    StateNotifierProvider.autoDispose<DeleteUsersNotifier, BaseState<String>>(
  (ref) => DeleteUsersNotifier(BaseState<String>.initial(), ref),
);
