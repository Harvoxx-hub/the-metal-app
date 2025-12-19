import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/notification_remote_data_source.dart';
import 'package:metal/data/repositories/notification/notification_repository.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationRemoteDataSource(dioClient);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepository(remoteDataSource: remoteDataSource);
});
