import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/connection_remote_data_source.dart';
import 'package:metal/data/repositories/connection/connection_repository.dart';
import 'package:metal/presentation/viewmodels/connection/connection_viewmodel.dart';
import 'package:metal/presentation/viewmodels/connection/melt_viewmodel.dart';

/// Provider for ConnectionRemoteDataSource
final connectionRemoteDataSourceProvider = Provider<ConnectionRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ConnectionRemoteDataSource(dioClient);
});

/// Provider for ConnectionRepository
final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  final remoteDataSource = ref.watch(connectionRemoteDataSourceProvider);
  return ConnectionRepository(remoteDataSource: remoteDataSource);
});

/// Provider for ConnectionViewModel (connections list)
final connectionViewModelProvider =
    StateNotifierProvider.autoDispose<ConnectionViewModel, ConnectionViewState>((ref) {
  final repository = ref.watch(connectionRepositoryProvider);
  final viewModel = ConnectionViewModel(repository: repository);
  viewModel.loadConnections();
  return viewModel;
});

/// Provider for MeltViewModel - keyed by userId for checking melt status
final meltStatusProvider = StateNotifierProvider.autoDispose
    .family<MeltStatusViewModel, MeltStatusState, String>((ref, userId) {
  final repository = ref.watch(connectionRepositoryProvider);
  return MeltStatusViewModel(
    repository: repository,
    targetUserId: userId,
  );
});

/// Provider for MeltActionViewModel (for melt actions)
final meltActionProvider =
    StateNotifierProvider.autoDispose<MeltActionViewModel, MeltActionState>((ref) {
  final repository = ref.watch(connectionRepositoryProvider);
  return MeltActionViewModel(repository: repository);
});
