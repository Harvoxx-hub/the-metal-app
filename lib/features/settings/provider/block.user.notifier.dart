import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/thought/provider/get.thoughts.explore.dart';
import 'package:metal/features/thought/provider/get.thoughts.for.you.dart';
import 'package:metal/features/settings/data/repositories/setting.repository.dart';
import 'package:metal/features/settings/provider/get.blocked.user.notifier.dart';

class BlockUsersNotifier extends StateNotifier<BlockUsersState> {
  BlockUsersNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // Fixed method naming to follow camelCase convention
  void blockUser(String userName, String id) async {
    try {
 
      final repo = ref.watch(settingRepositoryProvider);
      final response = await repo.blockUser(id, userName);

      Fluttertoast.showToast(
          msg: "User Blocked",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      ref.read(getBlockUserProvider.notifier).getBlock();
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();
      if (mounted) {
        state = BlockUsersState.success(
            response.message ?? "User blocked successfully");
      }
    } catch (e) {
      if (mounted) {
        state = BlockUsersState.error(e.toString());
      }
    }
  }

  // Enhanced block method with reason
  void blockUserWithReason({
    required String userName,
    required String id,
    required String reasonCode,
    String? customReason,
    bool isReported = false,
    String? reportDetails,
  }) async {
    try {
 
      final repo = ref.watch(settingRepositoryProvider);
      final response = await repo.blockUserWithReason(
          id: id,
          userName: userName,
          reasonCode: reasonCode,
          customReason: customReason,
          isReported: isReported,
          reportDetails: reportDetails);

 

      String toastMsg = isReported ? "User Blocked & Reported" : "User Blocked";
      Fluttertoast.showToast(
          msg: toastMsg,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      // Refresh all relevant lists
      ref.read(getBlockUserProvider.notifier).getBlock();
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();

      if (mounted) {
        state = BlockUsersState.success(
            response.message ?? "User blocked successfully");
      }
    } catch (e) {
      if (mounted) {
        state = BlockUsersState.error(e.toString());
      }
    }
  }

  void unBlockUser(String id) async {
    try {
     
      final repo = ref.watch(settingRepositoryProvider);
      final response = await repo.unBlockUser(id);

     
      ref.read(getBlockUserProvider.notifier).getBlock();
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();

      if (mounted) {
        state = BlockUsersState.success(
            response.message ?? "User unblocked successfully");
      }
    } catch (e) {
      if (mounted) {
        state = BlockUsersState.error(e.toString());
      }
    }
  }
}

// Define a type alias
typedef BlockUsersState = BaseState<String>;

final blockUserProvider =
    StateNotifierProvider.autoDispose<BlockUsersNotifier, BlockUsersState>(
  (ref) => BlockUsersNotifier(BlockUsersState.initial(), ref),
);
