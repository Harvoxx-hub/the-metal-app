import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/discovery_remote_data_source.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';

/// Discovery repository
/// Provides clean interface for discovery operations
abstract class IDiscoveryRepository {
  /// Get users for discovery with server-side filtering
  Future<DiscoveryUsersResponse> getDiscoveryUsers({
    int limit = 20,
    String? cursor,
  });

  /// Record a swipe action (like, pass, superlike)
  Future<SwipeResultDto> recordSwipe({
    required String targetUserId,
    required SwipeAction action,
  });

  /// Get user's swipe history
  Future<List<SwipeHistoryDto>> getSwipeHistory({
    int limit = 50,
    SwipeAction? action,
  });

  /// Undo the last swipe
  Future<SwipeHistoryDto> undoLastSwipe();
}

/// Discovery repository implementation
class DiscoveryRepository implements IDiscoveryRepository {
  final DiscoveryRemoteDataSource _remoteDataSource;

  DiscoveryRepository(this._remoteDataSource);

  @override
  Future<DiscoveryUsersResponse> getDiscoveryUsers({
    int limit = 20,
    String? cursor,
  }) async {
    return _remoteDataSource.getDiscoveryUsers(
      limit: limit,
      cursor: cursor,
    );
  }

  @override
  Future<SwipeResultDto> recordSwipe({
    required String targetUserId,
    required SwipeAction action,
  }) async {
    return _remoteDataSource.recordSwipe(
      targetUserId: targetUserId,
      action: action,
    );
  }

  @override
  Future<List<SwipeHistoryDto>> getSwipeHistory({
    int limit = 50,
    SwipeAction? action,
  }) async {
    return _remoteDataSource.getSwipeHistory(
      limit: limit,
      action: action,
    );
  }

  @override
  Future<SwipeHistoryDto> undoLastSwipe() async {
    return _remoteDataSource.undoLastSwipe();
  }
}

/// Provider for discovery remote data source
final discoveryRemoteDataSourceProvider = Provider<DiscoveryRemoteDataSource>((ref) {
  final api = ref.watch(apiInterceptorProvider);
  return DiscoveryRemoteDataSource(api);
});

/// Provider for discovery repository
final discoveryRepositoryProvider = Provider<IDiscoveryRepository>((ref) {
  final remoteDataSource = ref.watch(discoveryRemoteDataSourceProvider);
  return DiscoveryRepository(remoteDataSource);
});

