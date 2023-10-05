import 'dart:io';

import 'package:dio/dio.dart';
 
import 'package:metal/utils/try_cast.dart';

bool isNetworkError(Object error) {
  if (error is DioError) {
    final errorCode =
        tryCast<SocketException>(error.error)?.osError?.errorCode ?? -1;

    return errorCode == 7 ||
        errorCode == 8 ||
        (error.response?.statusCode ?? -1) == 410;
  } else {
    return false;
  }
}
