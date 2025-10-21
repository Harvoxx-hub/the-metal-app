import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/features/thought/provider/get.thoughts.explore.dart';
import 'package:metal/features/thought/provider/get.thoughts.for.you.dart';

class DeleteThoughtNotifier extends StateNotifier<DeleteThoughtState> {
  DeleteThoughtNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // melt user
  void deleteThought(String id) async {
    try {
      state = DeleteThoughtState.loading();
      final repo = ref.watch(homeRepositoryProvider);
      final response = await repo.deleteThoughtById(id);
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();
      if (mounted) {
        state = DeleteThoughtState.success(response.message!);
      }
    } catch (e, s) {
      state = DeleteThoughtState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef DeleteThoughtState = BaseState<String>;

final deleteThoughtProvider = StateNotifierProvider.autoDispose<
    DeleteThoughtNotifier, DeleteThoughtState>(
  (ref) => DeleteThoughtNotifier(DeleteThoughtState.initial(), ref),
);
