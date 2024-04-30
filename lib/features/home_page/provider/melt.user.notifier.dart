import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';

class MeltUsersNotifier extends StateNotifier<MeltUsersState> {
  MeltUsersNotifier(
    MeltUsersState state,
    this.ref,
    this.id,
  ) : super(state) {
     meltUser();
  }
  final Ref ref;
  final String id;

  // melt user
  void meltUser() async {
    try {
      state = MeltUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.meltUser(id);

      ref.read(getAllUserProvider.notifier).removeUser(id);
       Fluttertoast.showToast(
          msg: "Melt Request Sent",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      state = MeltUsersState.success(response.message!);
    } catch (e) {
      print(e.toString());
      state = MeltUsersState.error(e.toString());
    }
  }
}

// Define a type alias
typedef MeltUsersState = BaseState<String>;

final meltUserProvider = StateNotifierProvider.autoDispose
    .family<MeltUsersNotifier, MeltUsersState, String>(
  (ref, id) => MeltUsersNotifier(MeltUsersState.initial(), ref, id),
);
