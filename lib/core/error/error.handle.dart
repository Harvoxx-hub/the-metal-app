 
 
 
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/core/model/responces.dart';

class ErrorHandler implements Exception {
  late Responses failure;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      
      // Handle Dio-specific error
      failure = _handleError(error);


    } else {
      // Handle default error
      failure = Responses(
        success: false,
        message: error.message ?? "An unknown error occurred",
        data: error.data,
      );
    }
    Fluttertoast.showToast(
          msg: failure.message.toString(),
          
          fontSize: 16.0);
  }
}

Responses _handleError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return DataSource.CONNECT_TIMEOUT.getResponse();
    case DioExceptionType.sendTimeout:
      return DataSource.SEND_TIMEOUT.getResponse();
    case DioExceptionType.receiveTimeout:
      return DataSource.RECEIVE_TIMEOUT.getResponse();
    case DioExceptionType.badResponse:
      if (error.response != null &&
          error.response?.statusCode != null &&
          error.response?.statusMessage != null) {
      print(error.response?.data);
        return Responses(
          success: false,
          message: "An error occurred, try again",
          data: error.response?.data,
        );
      } else {
        return DataSource.DEFAULT.getResponse();
      }
    case DioExceptionType.cancel:
      return DataSource.CANCEL.getResponse();
    default:
      return DataSource.DEFAULT.getResponse();
  }
}

enum DataSource {
  SUCCESS,
  NO_CONTENT,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTHORIZED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  CONNECT_TIMEOUT,
  CANCEL,
  RECEIVE_TIMEOUT,
  SEND_TIMEOUT,
  CACHE_ERROR,
  NO_INTERNET_CONNECTION,
  DEFAULT
}

extension DataSourceExtension on DataSource {
  Responses getResponse() {
    switch (this) {
      case DataSource.SUCCESS:
        return Responses(
          success: true,
          message: ResponseMessage.SUCCESS,
          data: null,
        );
      case DataSource.NO_CONTENT:
        return Responses(
          success: true,
          message: ResponseMessage.NO_CONTENT,
          data: null,
        );
      case DataSource.BAD_REQUEST:
        return Responses(
          success: false,
          message: ResponseMessage.BAD_REQUEST,
          data: null,
        );
      case DataSource.FORBIDDEN:
        return Responses(
          success: false,
          message: ResponseMessage.FORBIDDEN,
          data: null,
        );
      case DataSource.UNAUTHORIZED:
        return Responses(
          success: false,
          message: ResponseMessage.UNAUTHORIZED,
          data: null,
        );
      case DataSource.NOT_FOUND:
        return Responses(
          success: false,
          message: ResponseMessage.NOT_FOUND,
          data: null,
        );
      case DataSource.INTERNAL_SERVER_ERROR:
        return Responses(
          success: false,
          message: ResponseMessage.INTERNAL_SERVER_ERROR,
          data: null,
        );
      case DataSource.CONNECT_TIMEOUT:
        return Responses(
          success: false,
          message: ResponseMessage.CONNECT_TIMEOUT,
          data: null,
        );
      case DataSource.CANCEL:
        return Responses(
          success: false,
          message: ResponseMessage.CANCEL,
          data: null,
        );
      case DataSource.RECEIVE_TIMEOUT:
        return Responses(
          success: false,
          message: ResponseMessage.RECEIVE_TIMEOUT,
          data: null,
        );
      case DataSource.SEND_TIMEOUT:
        return Responses(
          success: false,
          message: ResponseMessage.SEND_TIMEOUT,
          data: null,
        );
      case DataSource.CACHE_ERROR:
        return Responses(
          success: false,
          message: ResponseMessage.CACHE_ERROR,
          data: null,
        );
      case DataSource.NO_INTERNET_CONNECTION:
        return Responses(
          success: false,
          message: ResponseMessage.NO_INTERNET_CONNECTION,
          data: null,
        );
      case DataSource.DEFAULT:
        return Responses(
          success: false,
          message: ResponseMessage.DEFAULT,
          data: null,
        );
    }
  }
}

class ResponseMessage {
  static const String SUCCESS = "Success with data";
  static const String NO_CONTENT = "Success with no data (no content)";
  static const String BAD_REQUEST = "Failure, API rejected request";
  static const String UNAUTHORIZED = "Failure, user is not authorized";
  static const String FORBIDDEN = "Failure, API rejected request";
  static const String INTERNAL_SERVER_ERROR = "Failure, crash in server side";
  static const String NOT_FOUND = "Failure, not found";

  // Local status code messages
  static const String CONNECT_TIMEOUT = "TimeoutError";
  static const String CANCEL = "DefaultError";
  static const String RECEIVE_TIMEOUT = "TimeoutError";
  static const String SEND_TIMEOUT = "TimeoutError";
  static const String CACHE_ERROR = "CacheError";
  static const String NO_INTERNET_CONNECTION = "NoInternetError";
  static const String DEFAULT = "DefaultError";
}

 