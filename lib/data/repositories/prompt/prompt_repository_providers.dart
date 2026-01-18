import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/prompt_remote_data_source.dart';
import 'package:metal/data/repositories/prompt/prompt_repository.dart';
import 'package:metal/data/repositories/prompt/prompt_repository_abstract.dart';

/// Provider for PromptRemoteDataSource
final promptRemoteDataSourceProvider = Provider<PromptRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PromptRemoteDataSource(dioClient);
});

/// Provider for PromptRepository
final promptRepositoryProvider = Provider<PromptRepositoryAbstract>((ref) {
  final remoteDataSource = ref.watch(promptRemoteDataSourceProvider);
  return PromptRepository(remoteDataSource: remoteDataSource);
});
