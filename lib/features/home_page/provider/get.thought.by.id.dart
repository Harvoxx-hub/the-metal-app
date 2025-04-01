import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

class GetThoughtByIdNotifier extends StateNotifier<GetThoughtByIdState> {
  GetThoughtByIdNotifier(
    super.state,
    this.ref,
  );

  final Ref ref;

  Future<void> getThought(String thoughtId) async {
    if (!mounted) return;
    try {
      state = GetThoughtByIdState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getThoughtById(thoughtId);

      if (!mounted) return;
      if (response.success == true && response.data != null) {
        final thought = ThoughtModel.fromJson(response.data);
        state = GetThoughtByIdState.success(thought);
      } else {
        state = GetThoughtByIdState.error(
          response.message ?? "Failed to retrieve thought",
        );
      }
    } catch (e, s) {
      if (!mounted) return;
      state = GetThoughtByIdState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetThoughtByIdState = BaseState<ThoughtModel>;

final getThoughtByIdProvider = StateNotifierProvider.autoDispose<
    GetThoughtByIdNotifier, GetThoughtByIdState>(
  (ref) => GetThoughtByIdNotifier(GetThoughtByIdState.initial(), ref),
);
