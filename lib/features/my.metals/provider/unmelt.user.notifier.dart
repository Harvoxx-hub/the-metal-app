import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/provider/check.melt.status.notifier.dart';
import 'package:metal/features/home_page/provider/get.thoughts.explore.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';

class DeMeltUserNotifier extends StateNotifier<DeMeltUserState> {
  DeMeltUserNotifier(
    super.state,
    this.ref,
  ) {}
  final Ref ref;

  // melt user
  void deMeltUser(id, userid) async {
    try {
      state = DeMeltUserState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.deMeltUser(id);

      //ref.read(checkMeltProvider(userid).notifier).checkStatus();

      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();
      if (mounted) state = DeMeltUserState.success(response.message!);
      
       
    } catch (e, s) {
      state = DeMeltUserState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef DeMeltUserState = BaseState<String>;

final demeltUserProvider =
    StateNotifierProvider.autoDispose<DeMeltUserNotifier, DeMeltUserState>(
  (ref) => DeMeltUserNotifier(DeMeltUserState.initial(), ref),
);
