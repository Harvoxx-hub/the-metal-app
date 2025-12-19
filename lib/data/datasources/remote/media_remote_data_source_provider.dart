import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/media_remote_data_source.dart';

final mediaRemoteDataSourceProvider = Provider<MediaRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MediaRemoteDataSource(dioClient);
});
