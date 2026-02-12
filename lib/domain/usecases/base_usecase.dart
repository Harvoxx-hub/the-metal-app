import 'package:metal/core/state/base.state.dart';

/// Base use case interface
/// All use cases should implement this interface
abstract class BaseUseCase<Type, Params> {
  Future<BaseState<Type>> call(Params params);
}

/// Use case with no parameters
abstract class BaseUseCaseNoParams<Type> {
  Future<BaseState<Type>> call();
}
