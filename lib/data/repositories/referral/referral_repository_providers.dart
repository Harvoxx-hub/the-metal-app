import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/data/repositories/referral/referral_repository.dart';

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  final remoteDataSource = ref.watch(referralRemoteDataSourceProvider);
  return ReferralRepository(remoteDataSource: remoteDataSource);
});
