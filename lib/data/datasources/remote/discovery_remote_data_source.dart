import 'package:dio/dio.dart';
import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/domain/entities/discovery_user_dto.dart';

/// Remote data source for discovery operations
/// Handles API communication for swipe/discovery features
class DiscoveryRemoteDataSource {
  final DioClient _client;

  DiscoveryRemoteDataSource(this._client);

  /// Get users within radius (for meetup invite: everybody in broadcast radius)
  Future<DiscoveryUsersResponse> getUsersWithinRadius({
    required int radiusKm,
    double? lat,
    double? lng,
  }) async {
    final queryParams = <String, String>{
      'radiusKm': radiusKm.toString(),
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
    };
    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    try {
      final response = await _client.get(
        '${ApiRoutes.discoveryUsersInRadius}?$queryString',
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data == null) {
          return const DiscoveryUsersResponse(users: [], pagination: null);
        }
        final usersJson = data['users'] as List<dynamic>? ?? [];
        final users = usersJson
            .map((json) =>
                DiscoveryUserDto.fromJson(json as Map<String, dynamic>))
            .toList();
        final paginationJson = data['pagination'] as Map<String, dynamic>?;
        final pagination = paginationJson != null
            ? DiscoveryPaginationDto.fromJson(paginationJson)
            : null;
        return DiscoveryUsersResponse(users: users, pagination: pagination);
      }
      throw Exception(
          response.data?['error'] ?? 'Failed to get users within radius');
    } on DioException {
      rethrow;
    }
  }

  /// Get users for discovery
  /// Returns filtered users based on preferences
  Future<DiscoveryUsersResponse> getDiscoveryUsers({
    int limit = 20,
    String? cursor,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final queryString =
        queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

    try {
      final response = await _client.get(
        '${ApiRoutes.discoveryUsers}?$queryString',
      );

      if (response.statusCode == 200 && response.data != null) {
        final bodyMap = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : null;
        final apiMessage = bodyMap?['message'] as String?;

        final data = bodyMap?['data'] as Map<String, dynamic>?;

        if (data == null) {
          return DiscoveryUsersResponse(
            users: [],
            pagination: null,
            apiMessage: apiMessage,
          );
        }

        final usersJson = data['users'] as List<dynamic>? ?? [];
        final users = usersJson
            .map((json) =>
                DiscoveryUserDto.fromJson(json as Map<String, dynamic>))
            .toList();

        final paginationJson = data['pagination'] as Map<String, dynamic>?;
        final pagination = paginationJson != null
            ? DiscoveryPaginationDto.fromJson(paginationJson)
            : null;

        return DiscoveryUsersResponse(
          users: users,
          pagination: pagination,
          apiMessage: apiMessage,
        );
      }

      throw Exception(
          response.data?['error'] ?? 'Failed to get discovery users');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Record a swipe action
  Future<SwipeResultDto> recordSwipe({
    required String targetUserId,
    required SwipeAction action,
  }) async {
    try {
      final response = await _client.post(
        ApiRoutes.discoverySwipe,
        data: {
          'targetUserId': targetUserId,
          'action': action.value,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          throw Exception('Invalid response from server');
        }

        return SwipeResultDto.fromJson(data);
      }

      throw Exception(response.data?['error'] ?? 'Failed to record swipe');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Get swipe history
  Future<List<SwipeHistoryDto>> getSwipeHistory({
    int limit = 50,
    SwipeAction? action,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (action != null) 'action': action.value,
      };

      final queryString =
          queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');

      final response = await _client.get(
        '${ApiRoutes.discoveryHistory}?$queryString',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        return data
            .map((json) =>
                SwipeHistoryDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception(response.data?['error'] ?? 'Failed to get swipe history');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }

  /// Undo last swipe
  Future<SwipeHistoryDto> undoLastSwipe() async {
    try {
      final response = await _client.post(ApiRoutes.discoveryUndo);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>?;

        if (data == null) {
          throw Exception('Invalid response from server');
        }

        final undoneSwipe = data['undoneSwipe'] as Map<String, dynamic>?;
        if (undoneSwipe == null) {
          throw Exception('No swipe data returned');
        }

        return SwipeHistoryDto.fromJson(undoneSwipe);
      }

      throw Exception(response.data?['error'] ?? 'Failed to undo swipe');
    } on DioException {
      // Re-throw DioException to preserve response data for error handling
      // ErrorHandler will extract the proper error message from the response
      rethrow;
    }
  }
}

/// Response wrapper for discovery users
class DiscoveryUsersResponse {
  final List<DiscoveryUserDto> users;
  final DiscoveryPaginationDto? pagination;

  /// Top-level `message` from API (e.g. "Enable location to discover users near you").
  final String? apiMessage;

  const DiscoveryUsersResponse({
    required this.users,
    this.pagination,
    this.apiMessage,
  });
}

/// Swipe history DTO
class SwipeHistoryDto {
  final String id;
  final String targetUserId;
  final SwipeAction action;
  final String timestamp;

  const SwipeHistoryDto({
    required this.id,
    required this.targetUserId,
    required this.action,
    required this.timestamp,
  });

  factory SwipeHistoryDto.fromJson(Map<String, dynamic> json) {
    return SwipeHistoryDto(
      id: json['id'] as String? ?? '',
      targetUserId: json['targetUserId'] as String,
      action: SwipeActionExtension.fromString(json['action'] as String),
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}
