import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/notification/data/repositories/notification.repository.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';

class NotificationNotifier extends StateNotifier<GetNotification> {
  NotificationNotifier(
    super.state,
    this.ref,
  ) {
    getNotification();
  }
  final Ref ref;

  void getNotification() async {
    try {
      state = GetNotification.loading();
      final repo = ref.watch(notificationRepositoryProvider);
      final response = await repo.getNotification();
      final List<NotificationModel> notification = [];
      response.data.forEach((element) {
        notification.add(NotificationModel.fromJson(element));
      });
      state = GetNotification.success(notification);
    } catch (e, s) {
      state = GetNotification.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef GetNotification = BaseState<List<NotificationModel>>;

final notificationProvider =
    StateNotifierProvider.autoDispose<NotificationNotifier, GetNotification>(
  (ref) => NotificationNotifier(GetNotification.initial(), ref),
);
