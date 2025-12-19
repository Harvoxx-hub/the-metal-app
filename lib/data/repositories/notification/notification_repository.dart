import 'package:metal/core/state/base.state.dart';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/data/datasources/remote/notification_remote_data_source.dart';
import 'package:metal/data/repositories/notification/notification_repository_abstract.dart';
import 'package:metal/domain/entities/notification_dto.dart';

class NotificationRepository implements NotificationRepositoryAbstract {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepository({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<NotificationsResponseDto>> getNotifications({
    String? type,
    bool? unreadOnly,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _remoteDataSource.getNotifications(
        type: type,
        unreadOnly: unreadOnly ?? false,
        page: page,
        limit: limit,
      );
      final dto = response.toDomain();
      return BaseState.success(dto);
    } catch (e) {
      return ErrorHandler.handleError<NotificationsResponseDto>(e);
    }
  }

  @override
  Future<BaseState<void>> markAsRead({required String notificationId}) async {
    try {
      await _remoteDataSource.markAsRead(notificationId: notificationId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<void>> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  @override
  Future<BaseState<NotificationSettingsDto>> updateSettings({
    required NotificationSettingsDto settings,
  }) async {
    try {
      final response = await _remoteDataSource.updateSettings(
        settings: settings.toJson(),
      );
      final dto = response.toDomain();
      return BaseState.success(dto);
    } catch (e) {
      return ErrorHandler.handleError<NotificationSettingsDto>(e);
    }
  }

  @override
  Future<BaseState<void>> registerDevice({
    required String fcmToken,
    String? deviceId,
    String? deviceType,
  }) async {
    try {
      await _remoteDataSource.registerDevice(
        fcmToken: fcmToken,
        deviceId: deviceId,
        deviceType: deviceType,
      );
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }
}
