import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/spark_model.dart';

/// Remote data source for spark operations
/// Handles all API calls related to sparks (virtual currency)
class SparkRemoteDataSource {
  final DioClient _client;

  SparkRemoteDataSource(this._client);

  /// Get spark balance and transaction history
  /// Supports pagination for transaction history
  Future<SparkModel> getSparks({
    bool includeHistory = true,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'includeHistory': includeHistory,
      'page': page,
      'limit': limit,
    };

    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.sparks),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return SparkModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get sparks');
  }

  /// Send sparks to another user
  /// Returns new balance and transaction details
  Future<SendSparkResponseModel> sendSparks({
    required String recipientId,
    required int amount,
    String? message,
  }) async {
    final requestData = <String, dynamic>{
      'recipientId': recipientId,
      'amount': amount,
      if (message != null && message.isNotEmpty) 'message': message,
    };

    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.sparksSend),
      data: requestData,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return SendSparkResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to send sparks');
  }
}
