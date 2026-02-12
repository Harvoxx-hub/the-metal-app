import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/referral_dto.dart';

/// Abstract repository for referral operations
abstract class ReferralRepositoryAbstract {
  /// Get referral information
  Future<BaseState<ReferralDto>> getReferralInfo();

  /// Apply referral code
  Future<BaseState<bool>> applyReferralCode({
    required String referralCode,
  });
}
