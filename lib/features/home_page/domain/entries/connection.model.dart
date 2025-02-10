import 'package:json_annotation/json_annotation.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

part 'connection.model.g.dart';

@JsonSerializable(explicitToJson: true)
class ConnectionModel {
  final String connectionId;
  final List<String> users;
  final String? lastMessage;
  final String? lastUpdatedAt;
  final String? game;
  final String connectedOn;
  final String status;
  final bool isAnonymous;

  /// New Field
  final UserModel? otherUser;

  ConnectionModel({
    required this.connectionId,
    required this.users,
    required this.connectedOn,
    this.status = 'active',
    this.lastMessage,
    this.lastUpdatedAt,
    this.game,
    this.isAnonymous = false,
    this.otherUser, // New field added
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) =>
      _$ConnectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionModelToJson(this);

  /// **Add `copyWith` Method**
  ConnectionModel copyWith({
    String? connectionId,
    List<String>? users,
    String? lastMessage,
    String? lastUpdatedAt,
    String? game,
    String? connectedOn,
    String? status,
    bool? isAnonymous,
    UserModel? otherUser,
  }) {
    return ConnectionModel(
      connectionId: connectionId ?? this.connectionId,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      game: game ?? this.game,
      connectedOn: connectedOn ?? this.connectedOn,
      status: status ?? this.status,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      otherUser: otherUser ?? this.otherUser,
    );
  }
}
