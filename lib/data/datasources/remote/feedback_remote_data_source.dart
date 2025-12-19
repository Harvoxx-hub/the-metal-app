import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';
import 'package:metal/domain/entities/feedback_dto.dart';

/// Remote data source for feedback operations
/// Handles API calls for submitting user feedback
class FeedbackRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;

  FeedbackRemoteDataSource(this.dioClient);

  /// Submit feedback
  /// Sends user feedback to the backend
  Future<Map<String, dynamic>> submitFeedback({
    required FeedbackSubmissionDto feedback,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.feedback),
        data: feedback.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {};
        }
        throw Exception(data['message'] ?? 'Failed to submit feedback');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Submit feedback failed: ${e.message}');
    }
  }
}
