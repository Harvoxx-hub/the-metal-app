import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/uuid_center.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/home_page/provider/get.thoughts.explore.dart';
import 'package:metal/features/home_page/provider/get.thoughts.for.you.dart';

class SendThoughtNotifier extends StateNotifier<SendThoughtState> {
  SendThoughtNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // melt user
  void sendThought(String content) async {
    try {
      state = SendThoughtState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final userData = ref.watch(authProvider).data;
      final thought = ThoughtModel(
        id: UUIDCenter.uuid,
        userId: userData?.id ?? "",
        content: content,
        createdAt: DateTime.now().toIso8601String(),
        connectionOnly: true, // Only visible to connections
      );
      final response = await homeRepository.sendThought(thought);
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();
      if (mounted) {
        state = SendThoughtState.success(response.message!);
      }
    } catch (e, s) {
      state = SendThoughtState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef SendThoughtState = BaseState<String>;

final sendThoughtProvider =
    StateNotifierProvider.autoDispose<SendThoughtNotifier, SendThoughtState>(
  (ref) => SendThoughtNotifier(SendThoughtState.initial(), ref),
);
