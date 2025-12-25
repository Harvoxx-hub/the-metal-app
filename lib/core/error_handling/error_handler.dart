import 'package:dio/dio.dart';
import 'package:metal/core/error_handling/error_mapper.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/state/base.state.dart';

/// Error handler for Clean Architecture
/// Converts exceptions to BaseState errors
/// Note: Toast notifications should be handled in the UI layer, not here
class ErrorHandler {
  /// Handle error and return BaseState
  /// Does not show toast - let the UI layer decide how to display errors
  static BaseState<T> handleError<T>(dynamic error) {
    String errorMessage;
    Map? errorData;

    if (error is DioException) {
      errorMessage = ErrorMapper.mapDioException(error);
      // Extract error data from response if available
      if (error.response?.data is Map) {
        errorData = error.response!.data as Map;
      }
    } else if (error is Responses) {
      errorMessage = error.message ?? 'An error occurred';
      errorData = error.data;
    } else {
      errorMessage = ErrorMapper.extractErrorMessage(error);
    }

    // Return BaseState<T> with error status
    // UI layer should handle displaying toast/errors to user
    return BaseState<T>(
      status: Status.error,
      errorMessage: errorMessage,
      errorData: errorData,
    );
  }

  /// Handle error and return error message string
  static String handleErrorToString(dynamic error) {
    return ErrorMapper.extractErrorMessage(error);
  }
}
