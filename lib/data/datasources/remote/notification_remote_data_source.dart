import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';
import 'package:metal/data/models/notification_model.dart';

/// Remote data source for notification operations
/// Handles all API calls related to notifications
class NotificationRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSource(this.dioClient);

  /// Get notifications with optional filters
  Future<NotificationsResponseModel> getNotifications({
    String? type,
    bool? unreadOnly,
    required int page,
    required int limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (type != null) queryParams['type'] = type;
      if (unreadOnly != null) queryParams['unreadOnly'] = unreadOnly;

      final response = await dioClient.get(
        ApiRoutes.buildPath(ApiRoutes.notifications),
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return NotificationsResponseModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        throw Exception(data['message'] ?? 'Failed to get notifications');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Get notifications failed: ${e.message}');
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead({required String notificationId}) async {
    try {
      final response = await dioClient.put(
        ApiRoutes.buildPath('${ApiRoutes.notificationRead}/$notificationId/read'),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return;
        }
        throw Exception(data['message'] ?? 'Failed to mark notification as read');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Mark as read failed: ${e.message}');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await dioClient.put(
        ApiRoutes.buildPath(ApiRoutes.notificationReadAll),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return;
        }
        throw Exception(data['message'] ?? 'Failed to mark all as read');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Mark all as read failed: ${e.message}');
    }
  }

  /// Update notification settings
  Future<NotificationSettingsModel> updateSettings({
    required Map<String, dynamic> settings,
  }) async {
    try {
      final response = await dioClient.put(
        ApiRoutes.buildPath(ApiRoutes.notificationSettings),
        data: settings,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return NotificationSettingsModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        throw Exception(data['message'] ?? 'Failed to update settings');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Update settings failed: ${e.message}');
    }
  }

  /// Register FCM device token for push notifications
  Future<void> registerDevice({
    required String fcmToken,
    String? deviceId,
    String? deviceType,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.notificationDevices),
        data: {
          'fcmToken': fcmToken,
          if (deviceId != null) 'deviceId': deviceId,
          if (deviceType != null) 'deviceType': deviceType,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return;
        }
        throw Exception(data['message'] ?? 'Failed to register device');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Register device failed: ${e.message}');
    }
  }
}
