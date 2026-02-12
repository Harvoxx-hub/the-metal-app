import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/chat_remote_data_source.dart';
import 'package:metal/data/repositories/chat/chat_repository.dart';
import 'package:metal/data/repositories/chat/chat_repository_abstract.dart';

/// Provider for ChatRemoteDataSource
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatRemoteDataSource(dioClient);
});

/// Provider for ChatRepository
final chatRepositoryProvider = Provider<ChatRepositoryAbstract>((ref) {
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepository(remoteDataSource: remoteDataSource);
});
