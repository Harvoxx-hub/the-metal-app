import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/features/thought/provider/get.thoughts.explore.dart';
import 'package:metal/features/thought/provider/get.thoughts.for.you.dart';
import 'package:metal/features/thought/provider/get.thought.by.id.dart';

class EditThoughtNotifier extends StateNotifier<EditThoughtState> {
  EditThoughtNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  // Edit thought
  void editThought(String id, Map<String, dynamic> updatedData) async {
    try {
      state = EditThoughtState.loading();
      final repo = ref.watch(homeRepositoryProvider);
      final response = await repo.editThought(id, updatedData);

      // Refresh all relevant thought lists
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtByIdProvider.notifier).getThought(id);

      if (mounted) {
        state = EditThoughtState.success(response.message!);
      }
    } catch (e, s) {
      state = EditThoughtState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef EditThoughtState = BaseState<String>;

final editThoughtProvider =
    StateNotifierProvider.autoDispose<EditThoughtNotifier, EditThoughtState>(
  (ref) => EditThoughtNotifier(EditThoughtState.initial(), ref),
);
