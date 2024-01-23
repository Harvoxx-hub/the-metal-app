import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metal/core/error/error.handle.dart';
import 'package:metal/core/model/responces.dart';

class ApiService {
  ApiService();
  final String baseUrl = 'https://metal-server.vercel.app/api/v1';

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Response> _handleResponse(http.Response response) async {
    final body = jsonDecode(response.body);
    final data = Response.fromJson(body);
    if (data.success) {
      // Successful response
      return data;
    } else {
      // Error response
      ErrorHandler.handleError(_createAppError(response.statusCode, body));
      throw _createAppError(response.statusCode, body);
    }
  }

  AppError _createAppError(int statusCode, dynamic body) {
    // Customize this method to create an AppError based on your API response structure
    return AppError(
      code: body['code'] ?? 'unknown-error',
      message: body['message'] ?? 'An error occurred.',
    );
  }
}
