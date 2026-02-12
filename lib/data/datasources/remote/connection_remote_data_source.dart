import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';

/// Remote data source for connection and melt operations
class ConnectionRemoteDataSource {
  final DioClient _client;

  ConnectionRemoteDataSource(this._client);

  // ============ Connection Methods ============

  /// Get all connections for current user
  Future<ConnectionsResponseModel> getConnections({
    String? status,
    String? meltStatus,
    int limit = 50,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (status != null) 'status': status,
      if (meltStatus != null) 'meltStatus': meltStatus,
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.connections),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ConnectionsResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get connections');
  }

  /// Get a single connection by ID
  Future<ConnectionDetailModel> getConnectionById(String connectionId) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.connectionById)}/$connectionId',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return ConnectionDetailModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get connection');
  }

  /// Update a connection (game, etc.)
  Future<void> updateConnection(String connectionId, Map<String, dynamic> updates) async {
    final response = await _client.patch(
      '${ApiRoutes.buildPath(ApiRoutes.connectionById)}/$connectionId',
      data: updates,
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to update connection');
    }
  }

  /// Block a connection
  Future<void> blockConnection(String connectionId) async {
    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.blockConnection)}/$connectionId/block',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to block connection');
    }
  }

  /// Delete a connection
  Future<void> deleteConnection(String connectionId) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.connectionById)}/$connectionId',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to delete connection');
    }
  }

  // ============ Melt Methods ============

  /// Create a melt request
  Future<MeltResponseModel> createMeltRequest(String recipientId) async {
    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.melt),
      data: {'recipientId': recipientId},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MeltResponseModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to create melt request');
  }

  /// Check melt status with a user
  Future<MeltStatusModel> checkMeltStatus(String userId) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.meltStatus)}/$userId',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return MeltStatusModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to check melt status');
  }

  /// Get pending melt requests
  Future<PendingMeltRequestsModel> getPendingMeltRequests() async {
    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.meltPending),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return PendingMeltRequestsModel.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to get pending requests');
  }

  /// Cancel a melt request
  Future<void> cancelMeltRequest(String userId) async {
    final response = await _client.delete(
      '${ApiRoutes.buildPath(ApiRoutes.meltCancel)}/$userId',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to cancel melt request');
    }
  }

  /// Unmelt from a user (disconnect)
  Future<void> unmeltUser(String userId) async {
    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.meltUnmelt)}/$userId',
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to unmelt user');
    }
  }

  /// Request to unmelt (reveal identities) for a connection
  /// This sends an unmelt request that the other user must approve
  Future<UnmeltRequestResponse> requestUnmelt(String connectionId) async {
    final response = await _client.patch(
      '${ApiRoutes.buildPath(ApiRoutes.connectionById)}/$connectionId',
      data: {'requestUnmelt': true},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as Map<String, dynamic>? ?? response.data;
      return UnmeltRequestResponse.fromJson(data);
    }

    throw Exception(response.data?['error'] ?? 'Failed to request unmelt');
  }

  /// Approve or reject an unmelt request
  /// Action can be 'approve' or 'reject'
  Future<void> processUnmeltAction(
    String connectionId,
    String messageId,
    String action,
  ) async {
    final response = await _client.post(
      '${ApiRoutes.buildPath(ApiRoutes.unmeltAction)}/$connectionId/unmelt',
      data: {
        'messageId': messageId,
        'action': action,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(response.data?['error'] ?? 'Failed to process unmelt action');
    }
  }
}

/// Response model for unmelt request
class UnmeltRequestResponse {
  final bool unmeltRequested;
  final String? message;

  UnmeltRequestResponse({
    this.unmeltRequested = false,
    this.message,
  });

  factory UnmeltRequestResponse.fromJson(Map<String, dynamic> json) {
    return UnmeltRequestResponse(
      unmeltRequested: json['unmeltRequested'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

// ============ Response Models ============

/// Connection model from API
class ConnectionApiModel {
  final String id;
  final List<String> users;
  final String status;
  final String? meltStatus;
  final bool isAnonymous;
  final String? connectedOn;
  final String? lastMessage;
  final String? lastSenderId;
  final String? lastUpdatedAt;
  final OtherUserModel? otherUser;
  final bool canUnmelt;

  ConnectionApiModel({
    required this.id,
    required this.users,
    required this.status,
    this.meltStatus,
    this.isAnonymous = true,
    this.connectedOn,
    this.lastMessage,
    this.lastSenderId,
    this.lastUpdatedAt,
    this.otherUser,
    this.canUnmelt = false,
  });

  factory ConnectionApiModel.fromJson(Map<String, dynamic> json) {
    return ConnectionApiModel(
      id: json['id'] as String,
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String? ?? 'active',
      meltStatus: json['meltStatus'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      connectedOn: json['connectedOn'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastSenderId: json['lastSenderId'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] as String?,
      otherUser: json['otherUser'] != null
          ? OtherUserModel.fromJson(json['otherUser'] as Map<String, dynamic>)
          : null,
      canUnmelt: json['canUnmelt'] as bool? ?? false,
    );
  }
}

/// Other user info in connection
class OtherUserModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? gender;
  final String? profilePhoto;
  final List<String>? photos;
  final String? bio;
  final String? metal;
  final bool isOnline;
  final String? lastSeen;
  final bool isVerified;
  final int? age;
  final List<String>? passion;
  final List<String>? connectionOption;
  final String? email;
  final Map<String, dynamic>? location;

  OtherUserModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.gender,
    this.profilePhoto,
    this.photos,
    this.bio,
    this.metal,
    this.isOnline = false,
    this.lastSeen,
    this.isVerified = false,
    this.age,
    this.passion,
    this.connectionOption,
    this.email,
    this.location,
  });

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    return OtherUserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      username: json['username'] as String?,
      gender: json['gender'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
      bio: json['bio'] as String?,
      metal: json['metal'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      age: json['age'] as int?,
      passion: (json['passion'] as List<dynamic>?)?.map((e) => e as String).toList(),
      connectionOption: (json['connectionOption'] as List<dynamic>?)?.map((e) => e as String).toList(),
      email: json['email'] as String?,
      location: json['location'] as Map<String, dynamic>?,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? 'Anonymous';
  }

  String? get locationAddress {
    if (location == null) return null;
    return location!['address'] as String?;
  }
}

/// Response for connections list
class ConnectionsResponseModel {
  final List<ConnectionApiModel> connections;
  final PaginationModel pagination;

  ConnectionsResponseModel({
    required this.connections,
    required this.pagination,
  });

  factory ConnectionsResponseModel.fromJson(Map<String, dynamic> json) {
    final connectionsJson = json['connections'] as List<dynamic>? ?? [];
    return ConnectionsResponseModel(
      connections: connectionsJson
          .map((c) => ConnectionApiModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Connection detail model (with canUnmelt)
class ConnectionDetailModel extends ConnectionApiModel {
  final bool canUnmelt;

  ConnectionDetailModel({
    required super.id,
    required super.users,
    required super.status,
    super.meltStatus,
    super.isAnonymous,
    super.connectedOn,
    super.lastMessage,
    super.lastSenderId,
    super.lastUpdatedAt,
    super.otherUser,
    this.canUnmelt = false,
  });

  factory ConnectionDetailModel.fromJson(Map<String, dynamic> json) {
    return ConnectionDetailModel(
      id: json['id'] as String,
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String? ?? 'active',
      meltStatus: json['meltStatus'] as String?,
      isAnonymous: json['isAnonymous'] as bool? ?? true,
      connectedOn: json['connectedOn'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastSenderId: json['lastSenderId'] as String?,
      lastUpdatedAt: json['lastUpdatedAt'] as String?,
      otherUser: json['otherUser'] != null
          ? OtherUserModel.fromJson(json['otherUser'] as Map<String, dynamic>)
          : null,
      canUnmelt: json['canUnmelt'] as bool? ?? false,
    );
  }
}

/// Pagination model
class PaginationModel {
  final bool hasMore;
  final String? nextCursor;
  final int? totalCount;

  PaginationModel({
    required this.hasMore,
    this.nextCursor,
    this.totalCount,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      hasMore: json['hasMore'] as bool? ?? false,
      nextCursor: json['nextCursor'] as String?,
      totalCount: json['totalCount'] as int?,
    );
  }
}

/// Melt request response
class MeltResponseModel {
  final String? connectionId;
  final String? requestId;
  final String status; // 'connected', 'pending'
  final bool mutual;
  final String? createdAt;
  final String? connectedAt;

  MeltResponseModel({
    this.connectionId,
    this.requestId,
    required this.status,
    this.mutual = false,
    this.createdAt,
    this.connectedAt,
  });

  factory MeltResponseModel.fromJson(Map<String, dynamic> json) {
    return MeltResponseModel(
      connectionId: json['connectionId'] as String?,
      requestId: json['id'] as String?,
      status: json['status'] as String? ?? 'pending',
      mutual: json['mutual'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      connectedAt: json['connectedAt'] as String?,
    );
  }
}

/// Melt status model
class MeltStatusModel {
  final String status; // 'connected', 'pending', 'none'
  final String? connectionId;
  final String? requestId;
  final String? direction; // 'incoming', 'outgoing' for pending
  final String? connectedOn;
  final bool? isAnonymous;
  final bool? canUnmelt;
  final String? createdAt;

  MeltStatusModel({
    required this.status,
    this.connectionId,
    this.requestId,
    this.direction,
    this.connectedOn,
    this.isAnonymous,
    this.canUnmelt,
    this.createdAt,
  });

  factory MeltStatusModel.fromJson(Map<String, dynamic> json) {
    return MeltStatusModel(
      status: json['status'] as String? ?? 'none',
      connectionId: json['connectionId'] as String?,
      requestId: json['requestId'] as String?,
      direction: json['direction'] as String?,
      connectedOn: json['connectedOn'] as String?,
      isAnonymous: json['isAnonymous'] as bool?,
      canUnmelt: json['canUnmelt'] as bool?,
      createdAt: json['createdAt'] as String?,
    );
  }

  bool get isConnected => status == 'connected';
  bool get isPending => status == 'pending';
  bool get isNone => status == 'none';
  bool get isIncoming => direction == 'incoming';
  bool get isOutgoing => direction == 'outgoing';
}

/// Pending melt requests response
class PendingMeltRequestsModel {
  final List<MeltRequestModel> requests;
  final int count;

  PendingMeltRequestsModel({
    required this.requests,
    required this.count,
  });

  factory PendingMeltRequestsModel.fromJson(Map<String, dynamic> json) {
    final requestsJson = json['requests'] as List<dynamic>? ?? [];
    return PendingMeltRequestsModel(
      requests: requestsJson
          .map((r) => MeltRequestModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int? ?? 0,
    );
  }
}

/// Single melt request model
class MeltRequestModel {
  final String id;
  final String requesterId;
  final String recipientId;
  final String status;
  final String createdAt;
  final MeltRequesterModel? requester;

  MeltRequestModel({
    required this.id,
    required this.requesterId,
    required this.recipientId,
    required this.status,
    required this.createdAt,
    this.requester,
  });

  factory MeltRequestModel.fromJson(Map<String, dynamic> json) {
    return MeltRequestModel(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      recipientId: json['recipientId'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] as String,
      requester: json['requester'] != null
          ? MeltRequesterModel.fromJson(json['requester'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Requester user info in melt request
class MeltRequesterModel {
  final String id;
  final String? username;
  final String? profilePhoto;
  final String? metal;
  final bool isVerified;

  MeltRequesterModel({
    required this.id,
    this.username,
    this.profilePhoto,
    this.metal,
    this.isVerified = false,
  });

  factory MeltRequesterModel.fromJson(Map<String, dynamic> json) {
    return MeltRequesterModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      metal: json['metal'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}
