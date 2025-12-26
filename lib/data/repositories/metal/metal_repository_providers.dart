import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/data/repositories/metal/metal_repository.dart';

/// Metal Remote Data Source Provider
final metalRepositoryProvider = Provider<IMetalRepository>((ref) {
  final remoteDataSource = ref.watch(metalRemoteDataSourceProvider);
  return MetalRepository(remoteDataSource);
});

