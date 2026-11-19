import 'package:metal/core/state/base.state.dart';

/// Abstract repository for work email verification operations
abstract class VerificationRepositoryAbstract {
  /// Request work email verification
  Future<BaseState<bool>> requestWorkEmailVerification({
    required String workEmail,
    required String company,
  });

  /// Verify work email code
  Future<BaseState<bool>> verifyWorkEmailCode({
    required String workEmail,
    required String code,
  });
}
