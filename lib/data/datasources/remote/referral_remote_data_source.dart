import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';
import 'package:metal/data/models/referral_model.dart';

/// Remote data source for referral operations
/// Handles API calls for referral system
class ReferralRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;

  ReferralRemoteDataSource(this.dioClient);

  /// Get referral information
  /// Fetches user's referral code, count, sparks earned, and history
  Future<ReferralModel> getReferralInfo() async {
    try {
      final response = await dioClient.get(
        ApiRoutes.buildPath(ApiRoutes.referrals),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return ReferralModel.fromJson(data['data'] as Map<String, dynamic>);
        }
        throw Exception(data['message'] ?? 'Failed to get referral info');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Get referral info failed: ${e.message}');
    }
  }

  /// Apply referral code
  /// Applies a referral code for the current user
  Future<Map<String, dynamic>> applyReferralCode({
    required String referralCode,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.applyReferral),
        data: {'referralCode': referralCode},
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>? ?? {};
        }
        throw Exception(data['message'] ?? 'Failed to apply referral code');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Apply referral code failed: ${e.message}');
    }
  }
}
