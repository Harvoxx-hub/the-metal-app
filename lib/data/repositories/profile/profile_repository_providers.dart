import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/data/repositories/profile/profile_repository.dart';
import 'package:metal/data/repositories/profile/profile_repository_abstract.dart';

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepositoryAbstract>((ref) {
  return ProfileRepository(
    profileRemoteDataSource: ref.read(profileRemoteDataSourceProvider),
  );
});

