import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

class GetThoughtByUserNotifier extends StateNotifier<GetThoughtByUserState> {
  GetThoughtByUserNotifier(
    super.state,
    this.ref,
  ) {}
  final Ref ref;

  // melt user
  void getThought({String? id}) async {
    try {
      state = GetThoughtByUserState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final userData = ref.watch(authProvider).data;
      id = id ?? userData!.id;
      final response = await homeRepository.getThoughtById(id!);
      final List<ThoughtModel> thoughts = [];
      for (var thought in response.data) {
        thoughts.add(ThoughtModel.fromJson(thought));
      }
      if (mounted) {
        state = GetThoughtByUserState.success(
            MetalHelper.sortThoughtsByDate(thoughts));
      }
    } catch (e, s) {
      state = GetThoughtByUserState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetThoughtByUserState = BaseState<List<ThoughtModel>>;

final getThoughtByUserProvider = StateNotifierProvider.autoDispose<
    GetThoughtByUserNotifier, GetThoughtByUserState>(
  (ref) => GetThoughtByUserNotifier(GetThoughtByUserState.initial(), ref),
);
