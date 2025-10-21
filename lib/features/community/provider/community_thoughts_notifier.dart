import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/community/data/repositories/community_repository.dart';

class CommunityThoughtsNotifier
    extends StateNotifier<BaseState<List<ThoughtModel>>> {
  CommunityThoughtsNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  Future<void> getCommunityThoughts(String communityId) async {
    try {
      state = BaseState.loading();
      final communityRepository = CommunityRepository();

      final response =
          await communityRepository.getCommunityThoughts(communityId);

      if (response.success == true && response.data != null) {
        final thoughts = response.data as List<ThoughtModel>;
        state = BaseState.success(thoughts);
      } else {
        state = BaseState.error(
            response.message ?? 'Failed to load community thoughts');
      }
    } catch (e, s) {
      state = BaseState.error(e.toString(), stackTrace: s);
    }
  }

  Future<void> refreshCommunityThoughts(String communityId) async {
    await getCommunityThoughts(communityId);
  }
}

final communityThoughtsProvider = StateNotifierProvider.family.autoDispose<
    CommunityThoughtsNotifier, BaseState<List<ThoughtModel>>, String>(
  (ref, communityId) => CommunityThoughtsNotifier(BaseState.initial(), ref),
);
