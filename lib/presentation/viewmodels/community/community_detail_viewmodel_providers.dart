import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/community/community_repository_providers.dart';
import 'package:metal/presentation/viewmodels/community/community_detail_viewmodel.dart';

final communityDetailViewModelProvider = StateNotifierProvider.family
    .autoDispose<CommunityDetailViewModel, CommunityDetailState, String>(
  (ref, communityId) {
    final repository = ref.watch(communityRepositoryProvider);
    final viewModel = CommunityDetailViewModel(repository: repository);
    viewModel.loadCommunityDetails(communityId);
    return viewModel;
  },
);
