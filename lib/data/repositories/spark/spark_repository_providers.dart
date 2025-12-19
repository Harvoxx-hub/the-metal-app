import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/spark_remote_data_source.dart';
import 'package:metal/data/repositories/spark/spark_repository.dart';

final sparkRemoteDataSourceProvider = Provider<SparkRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SparkRemoteDataSource(dioClient);
});

final sparkRepositoryProvider = Provider<SparkRepository>((ref) {
  final remoteDataSource = ref.watch(sparkRemoteDataSourceProvider);
  return SparkRepository(remoteDataSource: remoteDataSource);
});
