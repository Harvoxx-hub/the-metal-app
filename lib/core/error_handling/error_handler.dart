import 'package:dio/dio.dart';
import 'package:metal/core/error_handling/error_mapper.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/state/base.state.dart';

/// Error handler for Clean Architecture
/// Converts exceptions to BaseState errors
class ErrorHandler {
  /// Handle error and return BaseState
  static BaseState<T> handleError<T>(dynamic error) {
    String errorMessage;
    Map? errorData;

    if (error is DioException) {
      errorMessage = ErrorMapper.mapDioException(error);
    } else if (error is Responses) {
      errorMessage = error.message ?? 'An error occurred';
      errorData = error.data;
    } else {
      errorMessage = ErrorMapper.extractErrorMessage(error);
    }

    // Use the factory method which will infer the type
    return BaseState.error(errorMessage, errorData: errorData) as BaseState<T>;
  }

  /// Handle error and return error message string
  static String handleErrorToString(dynamic error) {
    return ErrorMapper.extractErrorMessage(error);
  }
}

