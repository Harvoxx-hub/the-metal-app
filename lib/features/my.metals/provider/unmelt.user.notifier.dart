import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.thoughts.explore.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';

class deMeltUserNotifier extends StateNotifier<DeMeltUserState> {
  deMeltUserNotifier(
    super.state,
    this.ref,
 
  ) {
  
  }
  final Ref ref;
 

  // melt user
  void deMeltUser(id) async {
    try {
      state = DeMeltUserState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.deMeltUser(id);

      Fluttertoast.showToast(
          msg: "User unMelted",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      if (mounted) state = DeMeltUserState.success(response.message!);
      
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();
    } catch (e, s) {
      state = DeMeltUserState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef DeMeltUserState = BaseState<String>;

final demeltUserProvider = StateNotifierProvider.autoDispose
    <deMeltUserNotifier, DeMeltUserState>(
  (ref) => deMeltUserNotifier(DeMeltUserState.initial(), ref),
);
