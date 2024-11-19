import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/model/responces.dart';
import 'package:metal/core/services/api.service.dart';

import '../../domain/repositories/inotification_repository.dart';

class NotificationRepository implements INotificationRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Responses> getNotification() async {
    try {
      final response = await _apiService.get("user/get-notification");

      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final notificationepositoryProvider = Provider((ref) {
  return NotificationRepository();
});
