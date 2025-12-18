import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';

/// Base ViewModel class
/// All ViewModels should extend this
abstract class BaseViewModel<T> extends StateNotifier<BaseState<T>> {
  BaseViewModel() : super(BaseState.initial());

  /// Set loading state
  void setLoading() {
    state = BaseState.loading();
  }

  /// Set success state
  void setSuccess(T data, {Map? action}) {
    state = BaseState.success(data, action: action);
  }

  /// Set error state
  void setError(String errorMessage, {Map? errorData}) {
    state = BaseState.error(errorMessage, errorData: errorData);
  }

  /// Reset to initial state
  void reset() {
    state = BaseState.initial();
  }
}

