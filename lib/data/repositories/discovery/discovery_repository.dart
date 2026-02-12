import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/di/provider_setup.dart';
import 'package:metal/data/datasources/remote/discovery_remote_data_source.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';

/// Discovery repository
/// Provides clean interface for discovery operations
abstract class IDiscoveryRepository {
  /// Get users within radius (for meetup invite: everybody in broadcast radius)
  Future<DiscoveryUsersResponse> getUsersWithinRadius({
    required int radiusKm,
    double? lat,
    double? lng,
  });

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
  Future<DiscoveryUsersResponse> getUsersWithinRadius({
    required int radiusKm,
    double? lat,
    double? lng,
  }) async {
    try {
      return await _remoteDataSource.getUsersWithinRadius(
        radiusKm: radiusKm,
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DiscoveryUsersResponse> getDiscoveryUsers({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      return await _remoteDataSource.getDiscoveryUsers(
        limit: limit,
        cursor: cursor,
      );
    } catch (e) {
      // Re-throw to let ViewModel handle with ErrorHandler
      rethrow;
    }
  }

  @override
  Future<SwipeResultDto> recordSwipe({
    required String targetUserId,
    required SwipeAction action,
  }) async {
    try {
      return await _remoteDataSource.recordSwipe(
        targetUserId: targetUserId,
        action: action,
      );
    } catch (e) {
      // Re-throw to let ViewModel handle with ErrorHandler
      rethrow;
    }
  }

  @override
  Future<List<SwipeHistoryDto>> getSwipeHistory({
    int limit = 50,
    SwipeAction? action,
  }) async {
    try {
      return await _remoteDataSource.getSwipeHistory(
        limit: limit,
        action: action,
      );
    } catch (e) {
      // Re-throw to let ViewModel handle with ErrorHandler
      rethrow;
    }
  }

  @override
  Future<SwipeHistoryDto> undoLastSwipe() async {
    try {
      return await _remoteDataSource.undoLastSwipe();
    } catch (e) {
      // Re-throw to let ViewModel handle with ErrorHandler
      rethrow;
    }
  }
}

/// Provider for discovery remote data source
final discoveryRemoteDataSourceProvider =
    Provider<DiscoveryRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiscoveryRemoteDataSource(dioClient);
});

/// Provider for discovery repository
final discoveryRepositoryProvider = Provider<IDiscoveryRepository>((ref) {
  final remoteDataSource = ref.watch(discoveryRemoteDataSourceProvider);
  return DiscoveryRepository(remoteDataSource);
});
