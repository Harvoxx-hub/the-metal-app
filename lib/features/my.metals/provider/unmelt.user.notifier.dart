import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.thoughts.explore.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';

class UnMeltUsersNotifier extends StateNotifier<UnMeltUsersState> {
  UnMeltUsersNotifier(
    super.state,
    this.ref,
    this.id,
  ) {
    unmeltUser();
  }
  final Ref ref;
  final String id;

  // melt user
  void unmeltUser() async {
    try {
      state = UnMeltUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.unMeltUser(id);

      Fluttertoast.showToast(
          msg: "User unMelted",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      if (mounted) state = UnMeltUsersState.success(response.message!);
      ref.watch(getMeltUserProvider.notifier).updateMelt();
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();
    } catch (e, s) {
      state = UnMeltUsersState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef UnMeltUsersState = BaseState<String>;

final unmeltUserProvider = StateNotifierProvider.autoDispose
    .family<UnMeltUsersNotifier, UnMeltUsersState, String>(
  (ref, id) => UnMeltUsersNotifier(UnMeltUsersState.initial(), ref, id),
);
