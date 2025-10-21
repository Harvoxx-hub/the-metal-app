import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/metal.helper.dart';

import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

class getThoughtForYouNotifier extends StateNotifier<GetThoughtForYouState> {
  getThoughtForYouNotifier(
    super.state,
    this.ref,
  ) {
    getThought();
  }

  final Ref ref;

  // Fetch and sort thoughts by creation date (newest to oldest)
  void getThought() async {
    try {
      state = GetThoughtForYouState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getThoughtForYou();
      final List<ThoughtModel> thoughts = [];

      for (var thought in response.data) {
        thoughts.add(ThoughtModel.fromJson(thought));
      }

      if (mounted) {
        state = GetThoughtForYouState.success(
            MetalHelper.sortThoughtsByDate(thoughts));
      }
    } catch (e, s) {
      state = GetThoughtForYouState.error(e.toString(), stackTrace: s);
    }
  }

  // Fetch updated thoughts and sort them
  void getThoughtUpdate() async {
    try {
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getThoughtForYou();
      final List<ThoughtModel> thoughts = [];

      for (var thought in response.data) {
        thoughts.add(ThoughtModel.fromJson(thought));
      }

      if (mounted) {
        state = GetThoughtForYouState.success(
            MetalHelper.sortThoughtsByDate(thoughts));
      }
    } catch (e, s) {
      state = GetThoughtForYouState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetThoughtForYouState = BaseState<List<ThoughtModel>>;

final getThoughtForYouProvider = StateNotifierProvider.autoDispose<
    getThoughtForYouNotifier, GetThoughtForYouState>(
  (ref) => getThoughtForYouNotifier(GetThoughtForYouState.initial(), ref),
);
