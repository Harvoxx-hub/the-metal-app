import 'package:metal/features/thought/repositories/home.repository.dart';
import 'package:metal/features/thought/data/domain/entries/connection.model.dart';

/// Helper class for connection-related utilities
class ConnectionHelper {
  final HomeRepository _homeRepository;

  ConnectionHelper(this._homeRepository);

  /// Get the connection status between two users
  Future<bool> getConnectionStatus(String user1Id, String user2Id) async {
    return await _homeRepository.getConnectionStatus(user1Id, user2Id);
  }

  /// Get the other user ID from a connection
  String getOtherUserId(ConnectionModel connection, String currentUserId) {
    return connection.users.firstWhere(
      (userId) => userId != currentUserId,
      orElse: () => '',
    );
  }

  /// Get the metalId (other userId) from a connectionId string
  static String? getOtherUserIdFromConnectionId(
      String connectionId, String currentUserId) {
    // Split connectionId by '_', expecting [id1, id2]
    final parts = connectionId.split('_');
    if (parts.length != 2) return null;
    // Return the part that is NOT the current user
    return parts[0] == currentUserId ? parts[1] : parts[0];
  }

  /// Check if two users are either in a mutual melt state or already connected
}
