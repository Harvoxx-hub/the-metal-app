import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/thought_remote_data_source.dart';
import 'package:metal/data/repositories/thought/thought_repository.dart';
import 'package:metal/presentation/viewmodels/thought/thought_feed_viewmodel.dart';

/// Provider for ThoughtRemoteDataSource
final thoughtRemoteDataSourceProvider = Provider<ThoughtRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ThoughtRemoteDataSource(dioClient);
});

/// Provider for ThoughtRepository
final thoughtRepositoryProvider = Provider<ThoughtRepository>((ref) {
  final remoteDataSource = ref.watch(thoughtRemoteDataSourceProvider);
  return ThoughtRepository(remoteDataSource: remoteDataSource);
});

/// Provider for ThoughtFeedViewModel
final thoughtFeedViewModelProvider =
    StateNotifierProvider.autoDispose<ThoughtFeedViewModel, ThoughtFeedState>((ref) {
  // Keep feed state when switching dashboard tabs so post/delete sync isn't lost.
  ref.keepAlive();
  final repository = ref.watch(thoughtRepositoryProvider);
  final viewModel = ThoughtFeedViewModel(repository: repository);
  viewModel.loadThoughts();
  return viewModel;
});
