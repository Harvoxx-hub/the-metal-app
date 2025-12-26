import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/metal_properties_model.dart';

/// Remote data source for metal operations
/// Handles API communication for metals
class MetalRemoteDataSource {
  final DioClient _client;

  MetalRemoteDataSource(this._client);

  /// Get all metals from the API
  Future<List<Metal>> getMetals() async {
    try {
      final response = await _client.get(
        ApiRoutes.buildPath(ApiRoutes.metals),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        if (data['success'] == true && data['data'] != null) {
          final metalsJson = data['data'] as List<dynamic>;
          return metalsJson
              .map((json) => Metal.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        throw Exception(data['message'] ?? 'Failed to get metals');
      }

      throw Exception('Invalid response format');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }
}

