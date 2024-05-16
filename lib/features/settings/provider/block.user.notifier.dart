import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/settings/data/repositories/setting.repository.dart';

class BlockUsersNotifier extends StateNotifier<BlockUsersState> {
  BlockUsersNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // melt user
  void BlockUser(String userName, String id) async {
    try {
      state = BlockUsersState.loading();
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
      if (mounted) {
        state = BlockUsersState.success(response.message!);
      }
    } catch (e) {
      print(e.toString());
      state = BlockUsersState.error(e.toString());
    }
  }

  void unBlockUser(String id) async {
    try {
      state = BlockUsersState.loading();
      final repo = ref.watch(settingRepositoryProvider);
      final response = await repo.unBlockUser(id);
      if (mounted) {
        state = BlockUsersState.success(response.message!);
      }
    } catch (e) {
      print(e.toString());
      state = BlockUsersState.error(e.toString());
    }
  }
}

// Define a type alias
typedef BlockUsersState = BaseState<String>;

final blockUserProvider =
    StateNotifierProvider.autoDispose<BlockUsersNotifier, BlockUsersState>(
  (ref) => BlockUsersNotifier(BlockUsersState.initial(), ref),
);
