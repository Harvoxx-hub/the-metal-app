import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/chat/data/repositories/message.repository.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/melt.request.model.dart';
import 'package:metal/features/home_page/provider/check.melt.status.notifier.dart';

import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.thoughts.explore.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';

class MeltUsersNotifier extends StateNotifier<MeltUsersState> {
  MeltUsersNotifier(
    super.state,
    this.ref,
  ) {}
  final Ref ref;

  // melt user
  void meltUser(String id) async {
    try {
      state = MeltUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);

      final userData = ref.watch(authProvider).data;

      final meltRequest = MeltRequestModel(
        requesterId: userData!.id!,
        recipientId: id,
        isAnonymous: true,
        createdAt: DateTime.now().toIso8601String(),
        senderId: userData.id ?? "",
      );

      final response = await homeRepository.meltUser(meltRequest);
      ref.read(checkMeltProvider(id).notifier).checkStatus();
      state = MeltUsersState.success({"data": response.data});
    } catch (e, s) {
      state = MeltUsersState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef MeltUsersState = BaseState<Map>;

final meltUserProvider =
    StateNotifierProvider.autoDispose<MeltUsersNotifier, MeltUsersState>(
  (ref) => MeltUsersNotifier(MeltUsersState.initial(), ref),
);
