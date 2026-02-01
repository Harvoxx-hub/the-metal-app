import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/notification_dto.dart';

abstract class NotificationRepositoryAbstract {
  Future<BaseState<NotificationsResponseDto>> getNotifications({
    String? type,
    bool? unreadOnly,
    required int page,
    required int limit,
  });

  Future<BaseState<void>> markAsRead({required String notificationId});

  Future<BaseState<void>> markAllAsRead();

  Future<BaseState<Map<String, dynamic>>> executeAction({
    required String notificationId,
    required String action,
    Map<String, dynamic>? params,
  });

  Future<BaseState<NotificationSettingsDto>> updateSettings({
    required NotificationSettingsDto settings,
  });

  Future<BaseState<void>> registerDevice({
    required String deviceToken,
    required String platform,
    String? appVersion,
  });
}
