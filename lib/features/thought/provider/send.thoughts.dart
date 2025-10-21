import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/utils/uuid_center.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';
import 'package:metal/features/community/data/domain/entries/community_metadata.model.dart';
import 'package:metal/features/thought/provider/get.thoughts.explore.dart';
import 'package:metal/features/thought/provider/get.thoughts.for.you.dart';
import 'package:metal/features/community/provider/community_thoughts_notifier.dart';

class SendThoughtNotifier extends StateNotifier<SendThoughtState> {
  SendThoughtNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  void sendThought(String content,
      {CommunityMetadata? communityMetadata}) async {
    try {
      state = SendThoughtState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final userData = ref.watch(userStateProvider).data;

      // Create author metadata from current user data for denormalization
      AuthorMetadata? authorMetadata;
      if (userData != null) {
        authorMetadata = AuthorMetadata.fromUserModel(userData);
      }

      final thought = ThoughtModel(
        id: UUIDCenter.uuid,
        userId: userData?.id ?? "",
        content: content,
        createdAt: DateTime.now().toIso8601String(),
        connectionOnly: communityMetadata ==
            null, // Only visible to connections if not a community post
        authorMetadata: authorMetadata,
        communityMetadata: communityMetadata,
      );
      final response = await homeRepository.sendThought(thought);
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();

      // Refresh community thoughts if this is a community post
      if (communityMetadata != null) {
        ref
            .read(communityThoughtsProvider(communityMetadata.communityId)
                .notifier)
            .refreshCommunityThoughts(communityMetadata.communityId);
      }

      if (mounted) {
        state = SendThoughtState.success(response.message!);
      }
    } catch (e, s) {
      state = SendThoughtState.error(e.toString(), stackTrace: s);
    }
  }

  Future<void> sendVoiceThought({
    required String caption,
    required String localFilePath,
    required int durationSeconds,
    CommunityMetadata? communityMetadata,
  }) async {
    try {
      state = SendThoughtState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final userData = ref.watch(userStateProvider).data;

      AuthorMetadata? authorMetadata;
      if (userData != null) {
        authorMetadata = AuthorMetadata.fromUserModel(userData);
      }

      final thought = ThoughtModel(
        id: UUIDCenter.uuid,
        userId: userData?.id ?? "",
        content: caption,
        type: 'voice',
        audioDuration: durationSeconds,
        createdAt: DateTime.now().toIso8601String(),
        connectionOnly: communityMetadata == null,
        authorMetadata: authorMetadata,
        communityMetadata: communityMetadata,
      );

      final userId = userData?.id ?? 'unknown';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'voice_thoughts/$userId/$timestamp.m4a';

      final response = await homeRepository.sendVoiceThought(
        thought: thought,
        storagePath: storagePath,
        localFilePath: localFilePath,
      );

      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();
      if (communityMetadata != null) {
        ref
            .read(communityThoughtsProvider(communityMetadata.communityId)
                .notifier)
            .refreshCommunityThoughts(communityMetadata.communityId);
      }

      if (mounted) {
        if (response.success == true) {
          state = SendThoughtState.success(response.message ?? 'Success');
        } else {
          state = SendThoughtState.error(response.message ?? 'Failed');
        }
      }
    } catch (e, s) {
      state = SendThoughtState.error(e.toString(), stackTrace: s);
    }
  }

  Future<void> repostThought({required String originalThoughtId}) async {
    try {
      state = SendThoughtState.loading();
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response = await homeRepository.createRepost(
        originalThoughtId: originalThoughtId,
      );

      // refresh feeds immediately
      ref.read(getThoughtForYouProvider.notifier).getThoughtUpdate();
      ref.read(getThoughtExploreProvider.notifier).getThoughtUpdate();

      if (mounted) {
        if (response.success == true) {
          state = SendThoughtState.success(response.message ?? 'Reposted');
        } else {
          state =
              SendThoughtState.error(response.message ?? 'Failed to repost');
        }
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
