import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/verification_remote_data_source.dart';
import 'package:metal/data/repositories/verification/verification_repository_abstract.dart';

/// Repository for work email verification operations
/// Implements business logic for work email verification
class VerificationRepository implements VerificationRepositoryAbstract {
  final VerificationRemoteDataSource _remoteDataSource;

  VerificationRepository({
    required VerificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<bool>> requestWorkEmailVerification({
    required String workEmail,
    required String company,
  }) async {
    try {
      await _remoteDataSource.requestWorkEmailVerification(
        workEmail: workEmail,
        company: company,
      );
      return BaseState.success(true);
    } catch (e) {
      return ErrorHandler.handleError<bool>(e);
    }
  }

  @override
  Future<BaseState<bool>> verifyWorkEmailCode({
    required String workEmail,
    required String code,
  }) async {
    try {
      await _remoteDataSource.verifyWorkEmailCode(
        workEmail: workEmail,
        code: code,
      );
      return BaseState.success(true);
    } catch (e) {
      return ErrorHandler.handleError<bool>(e);
    }
  }
}
