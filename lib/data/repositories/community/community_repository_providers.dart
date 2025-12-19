import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/community_remote_data_source.dart';
import 'package:metal/data/repositories/community/community_repository.dart';

final communityRemoteDataSourceProvider = Provider<CommunityRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CommunityRemoteDataSource(dioClient);
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final remoteDataSource = ref.watch(communityRemoteDataSourceProvider);
  return CommunityRepository(remoteDataSource: remoteDataSource);
});
