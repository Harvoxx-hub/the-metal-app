import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/repositories/auth/auth_repository_abstract.dart';
import 'package:metal/domain/usecases/base_usecase.dart';

/// Send verification code use case
class SendVerificationCodeUseCase implements BaseUseCase<void, String> {
  final AuthRepositoryAbstract repository;

  SendVerificationCodeUseCase(this.repository);

  @override
  Future<BaseState<void>> call(String email) async {
    return await repository.sendVerificationCode(email);
  }
}

/// Verify code parameters
class VerifyCodeParams {
  final String email;
  final String code;

  VerifyCodeParams({required this.email, required this.code});
}

/// Verify code use case
class VerifyCodeUseCase implements BaseUseCase<void, VerifyCodeParams> {
  final AuthRepositoryAbstract repository;

  VerifyCodeUseCase(this.repository);

  @override
  Future<BaseState<void>> call(VerifyCodeParams params) async {
    return await repository.verifyCode(
      email: params.email,
      code: params.code,
    );
  }
}
