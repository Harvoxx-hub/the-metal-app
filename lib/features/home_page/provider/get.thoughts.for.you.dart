import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

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
        state = GetThoughtForYouState.success(_sortThoughtsByDate(thoughts));
      }
    } catch (e) {
      print(e.toString());
      state = GetThoughtForYouState.error(e.toString());
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
        state = GetThoughtForYouState.success(_sortThoughtsByDate(thoughts));
      }
    } catch (e) {
      print(e.toString());
      // Handle the error state accordingly
      state = GetThoughtForYouState.error(e.toString());
    }
  }

  // Private method to sort thoughts by date from newest to oldest
  List<ThoughtModel> _sortThoughtsByDate(List<ThoughtModel> thoughts) {
    thoughts.sort((a, b) {
      DateTime? dateA =
          a.created_at != null ? DateTime.parse(a.created_at!) : null;
      DateTime? dateB =
          b.created_at != null ? DateTime.parse(b.created_at!) : null;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return thoughts;
  }
}

// Define a type alias
typedef GetThoughtForYouState = BaseState<List<ThoughtModel>>;

final getThoughtForYouProvider = StateNotifierProvider.autoDispose<
    getThoughtForYouNotifier, GetThoughtForYouState>(
  (ref) => getThoughtForYouNotifier(GetThoughtForYouState.initial(), ref),
);
