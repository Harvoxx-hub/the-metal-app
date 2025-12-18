import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/data/repositories/auth/auth_repository.dart';
import 'package:metal/data/repositories/auth/auth_repository_abstract.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepositoryAbstract>((ref) {
  return AuthRepository(
    authRemoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});
