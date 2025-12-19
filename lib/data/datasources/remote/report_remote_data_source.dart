import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';
import 'package:metal/domain/entities/report_dto.dart';

/// Remote data source for reporting operations
/// Handles API calls for reporting users and content
class ReportRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;

  ReportRemoteDataSource(this.dioClient);

  /// Report a user
  /// Submits a report for inappropriate user behavior
  Future<Map<String, dynamic>> reportUser({
    required UserReportDto report,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.reportUser),
        data: report.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {};
        }
        throw Exception(data['message'] ?? 'Failed to report user');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Report user failed: ${e.message}');
    }
  }

  /// Report content
  /// Submits a report for inappropriate content (thought/comment/message)
  Future<Map<String, dynamic>> reportContent({
    required ContentReportDto report,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.reportContent),
        data: report.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {};
        }
        throw Exception(data['message'] ?? 'Failed to report content');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Report content failed: ${e.message}');
    }
  }
}
