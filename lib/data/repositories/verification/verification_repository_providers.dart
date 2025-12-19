import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/data/repositories/verification/verification_repository.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  final remoteDataSource = ref.watch(verificationRemoteDataSourceProvider);
  return VerificationRepository(remoteDataSource: remoteDataSource);
});
