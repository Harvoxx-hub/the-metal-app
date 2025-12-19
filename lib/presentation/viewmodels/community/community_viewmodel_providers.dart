import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/community/community_repository_providers.dart';
import 'package:metal/presentation/viewmodels/community/community_viewmodel.dart';

final communityViewModelProvider =
    StateNotifierProvider.autoDispose<CommunityViewModel, CommunityState>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  final viewModel = CommunityViewModel(repository: repository);
  viewModel.loadCommunities();
  return viewModel;
});
