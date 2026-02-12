import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/story_remote_data_source.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source.dart';
import 'package:metal/data/repositories/story/story_repository.dart';

final storyRemoteDataSourceProvider = Provider<StoryRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return StoryRemoteDataSource(dioClient);
});

final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MediaRemoteDataSource(dioClient);
});

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final storyRemoteDataSource = ref.watch(storyRemoteDataSourceProvider);
  final mediaRemoteDataSource = ref.watch(mediaRemoteDataSourceProvider);
  return StoryRepository(
    storyRemoteDataSource: storyRemoteDataSource,
    mediaRemoteDataSource: mediaRemoteDataSource,
  );
});
