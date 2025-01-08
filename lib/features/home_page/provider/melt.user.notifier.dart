import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/constant/enums.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/melt.request.model.dart';
import 'package:metal/features/home_page/provider/check.melt.status.notifier.dart';

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
      print("IT WAS CALLED HERE");

      final userData = ref.watch(authProvider).data;

      final meltRequest = MeltRequestModel(
        requesterId: userData!.id!,
        recipientId: id,
        isAnonymous: true,
        createdAt: DateTime.now().toIso8601String(),
        senderId: userData.id ?? "",
      );

      print("IT WAS CALLED HERE2");

      final response = await homeRepository.meltUser(meltRequest);
      ref.read(checkMeltProvider(id).notifier).checkStatus();
      state = MeltUsersState.success({"data": response.data});
    } catch (e, s) {
      print("IT WAS CALLED ERROR:$e");
      state = MeltUsersState.error(e.toString(), stackTrace: s);
    }
  }

  // // Unmelt user
  void unMeltUser(String id) async {
    try {
      state = MeltUsersState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);

      await homeRepository.unMeltUser(id);

      // Force state update to noRequest after unmelt
      state = MeltUsersState.success({"data": MeltRequestState.noRequest});

      // Update the check melt status
      if (ref.read(checkMeltProvider(id).notifier).mounted) {
        ref.read(checkMeltProvider(id).notifier).checkStatus();
      }
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
