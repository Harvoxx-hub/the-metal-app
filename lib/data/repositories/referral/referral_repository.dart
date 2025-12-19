import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/referral_remote_data_source.dart';
import 'package:metal/data/repositories/referral/referral_repository_abstract.dart';
import 'package:metal/domain/entities/referral_dto.dart';

/// Repository for referral operations
/// Implements business logic for referral system
class ReferralRepository implements ReferralRepositoryAbstract {
  final ReferralRemoteDataSource _remoteDataSource;

  ReferralRepository({
    required ReferralRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<ReferralDto>> getReferralInfo() async {
    try {
      final response = await _remoteDataSource.getReferralInfo();
      final dto = response.toDomain();
      return BaseState.success(dto);
    } catch (e) {
      return ErrorHandler.handleError<ReferralDto>(e);
    }
  }

  @override
  Future<BaseState<bool>> applyReferralCode({
    required String referralCode,
  }) async {
    try {
      await _remoteDataSource.applyReferralCode(referralCode: referralCode);
      return BaseState.success(true);
    } catch (e) {
      return ErrorHandler.handleError<bool>(e);
    }
  }
}
