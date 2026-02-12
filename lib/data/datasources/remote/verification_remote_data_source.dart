import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';

/// Remote data source for work email verification
/// Handles API calls for work email verification flow
class VerificationRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;

  VerificationRemoteDataSource(this.dioClient);

  /// Request work email verification
  /// Sends verification code to the provided work email
  Future<Map<String, dynamic>> requestWorkEmailVerification({
    required String workEmail,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.workEmailVerification),
        data: {'workEmail': workEmail},
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {};
        }
        throw Exception(
          data['message'] ?? 'Failed to send verification code',
        );
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Request work email verification failed: ${e.message}');
    }
  }

  /// Verify work email code
  /// Verifies the code sent to the work email
  Future<Map<String, dynamic>> verifyWorkEmailCode({
    required String workEmail,
    required String code,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.workEmailVerify),
        data: {
          'workEmail': workEmail,
          'code': code,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {};
        }
        throw Exception(data['message'] ?? 'Invalid verification code');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Verify work email code failed: ${e.message}');
    }
  }
}
