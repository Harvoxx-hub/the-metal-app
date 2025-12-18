import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/connection_remote_data_source.dart';

/// Repository for connection and melt operations
class ConnectionRepository {
  final ConnectionRemoteDataSource _remoteDataSource;

  ConnectionRepository({
    required ConnectionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  // ============ Connection Methods ============

  /// Get all connections
  Future<BaseState<ConnectionsResponseDto>> getConnections({
    String? status,
    String? meltStatus,
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final response = await _remoteDataSource.getConnections(
        status: status,
        meltStatus: meltStatus,
        limit: limit,
        cursor: cursor,
      );

      return BaseState.success(ConnectionsResponseDto(
        connections: response.connections,
        hasMore: response.pagination.hasMore,
        nextCursor: response.pagination.nextCursor,
      ));
    } catch (e) {
      return ErrorHandler.handleError<ConnectionsResponseDto>(e);
    }
  }

  /// Get a single connection by ID
  Future<BaseState<ConnectionDetailModel>> getConnectionById(
    String connectionId,
  ) async {
    try {
      final response = await _remoteDataSource.getConnectionById(connectionId);
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<ConnectionDetailModel>(e);
    }
  }

  /// Update a connection
  Future<BaseState<void>> updateConnection(
    String connectionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _remoteDataSource.updateConnection(connectionId, updates);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  /// Block a connection
  Future<BaseState<void>> blockConnection(String connectionId) async {
    try {
      await _remoteDataSource.blockConnection(connectionId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  /// Delete a connection
  Future<BaseState<void>> deleteConnection(String connectionId) async {
    try {
      await _remoteDataSource.deleteConnection(connectionId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  // ============ Melt Methods ============

  /// Create a melt request
  Future<BaseState<MeltResponseModel>> createMeltRequest(
    String recipientId,
  ) async {
    try {
      final response = await _remoteDataSource.createMeltRequest(recipientId);
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<MeltResponseModel>(e);
    }
  }

  /// Check melt status with a user
  Future<BaseState<MeltStatusModel>> checkMeltStatus(String userId) async {
    try {
      final response = await _remoteDataSource.checkMeltStatus(userId);
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<MeltStatusModel>(e);
    }
  }

  /// Get pending melt requests
  Future<BaseState<PendingMeltRequestsModel>> getPendingMeltRequests() async {
    try {
      final response = await _remoteDataSource.getPendingMeltRequests();
      return BaseState.success(response);
    } catch (e) {
      return ErrorHandler.handleError<PendingMeltRequestsModel>(e);
    }
  }

  /// Cancel a melt request
  Future<BaseState<void>> cancelMeltRequest(String userId) async {
    try {
      await _remoteDataSource.cancelMeltRequest(userId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }

  /// Unmelt from a user
  Future<BaseState<void>> unmeltUser(String userId) async {
    try {
      await _remoteDataSource.unmeltUser(userId);
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<void>(e);
    }
  }
}

// ============ DTOs ============

/// DTO for connections list response
class ConnectionsResponseDto {
  final List<ConnectionApiModel> connections;
  final bool hasMore;
  final String? nextCursor;

  ConnectionsResponseDto({
    required this.connections,
    required this.hasMore,
    this.nextCursor,
  });
}
