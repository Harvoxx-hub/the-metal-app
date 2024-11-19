import 'package:metal/core/model/responces.dart';

abstract class INotificationRepository {
  Future<Responses> getNotification();
}
