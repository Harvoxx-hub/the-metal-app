import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/metal.helper.dart';
 

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

class GetThoughtExploreNotifier extends StateNotifier<GetThoughtExploreState> {
  GetThoughtExploreNotifier(
    super.state,
    this.ref,
  ) {
    getThought();
  }
  final Ref ref;

  // melt user
  void getThought() async {
    try {
      state = GetThoughtExploreState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getThoughtExplore();
      final List<ThoughtModel> thoughts = [];
      for (var thought in response.data) {
        thoughts.add(ThoughtModel.fromJson(thought));
      }
      if (mounted) {
        state = GetThoughtExploreState.success(MetalHelper.sortThoughtsByDate(thoughts));
      }
    } catch (e, s) {
 
      state = GetThoughtExploreState.error(e.toString(), stackTrace: s);
    }
  }

   void getThoughtUpdate() async {
    try {
      
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.getThoughtExplore();
      final List<ThoughtModel> thoughts = [];
      for (var thought in response.data) {
        thoughts.add(ThoughtModel.fromJson(thought));
      }
      if (mounted) {
        state = GetThoughtExploreState.error(MetalHelper.sortThoughtsByDate(thoughts).toString());
      }
    } catch (e, s) {
     
      state = GetThoughtExploreState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetThoughtExploreState = BaseState<List<ThoughtModel>>;

final getThoughtExploreProvider = StateNotifierProvider.autoDispose<
    GetThoughtExploreNotifier, GetThoughtExploreState>(
  (ref) => GetThoughtExploreNotifier(GetThoughtExploreState.initial(), ref),
);
