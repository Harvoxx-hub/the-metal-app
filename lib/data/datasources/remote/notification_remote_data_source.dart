import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/datasources/base_data_source.dart';
import 'package:metal/data/models/notification_model.dart';
import 'package:metal/domain/entities/notification_dto.dart';

/// Remote data source for notification operations
/// Handles API calls for notifications system
class NotificationRemoteDataSource extends BaseRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSource(this.dioClient);

  /// Get notifications (all, read and unread). Pagination only; no filters.
  Future<NotificationsResponseModel> getNotifications({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

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
      throw Exception('Mark notification as read failed: ${e.message}');
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

  /// Update notification settings/preferences
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
      throw Exception('Update notification settings failed: ${e.message}');
    }
  }

  /// Get notification settings
  Future<NotificationSettingsModel> getNotificationSettings() async {
    try {
      final response = await dioClient.get(
        ApiRoutes.buildPath(ApiRoutes.notificationSettings),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return NotificationSettingsModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        throw Exception(data['message'] ?? 'Failed to get settings');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Get notification settings failed: ${e.message}');
    }
  }

  /// Execute notification action (Accept, Decline, Chat, etc.)
  Future<Map<String, dynamic>> executeAction({
    required String notificationId,
    required String action,
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath('${ApiRoutes.notificationAction}/$notificationId/action'),
        data: {
          'action': action,
          if (params != null) 'params': params,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
        throw Exception(data['message'] ?? 'Failed to execute action');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Execute notification action failed: ${e.message}');
    }
  }

  /// Register FCM device token for push notifications
  Future<void> registerDevice({
    required String deviceToken,
    required String platform,
    String? appVersion,
  }) async {
    try {
      final response = await dioClient.post(
        ApiRoutes.buildPath(ApiRoutes.notificationDevices),
        data: {
          'deviceToken': deviceToken,
          'platform': platform,
          if (appVersion != null) 'appVersion': appVersion,
        },
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          return;
        }
        throw Exception(data['message'] ?? 'Failed to register device token');
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Register device token failed: ${e.message}');
    }
  }
}
