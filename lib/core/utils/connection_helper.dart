 
import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/connection.model.dart';

/// Helper class for connection-related utilities
class ConnectionHelper {
  final HomeRepository _homeRepository;
  

  ConnectionHelper(this._homeRepository);

  /// Get the connection status between two users
  Future<bool> getConnectionStatus(
      String user1Id, String user2Id) async {
    return await _homeRepository.getConnectionStatus(user1Id, user2Id);
  }

 

  /// Get the other user ID from a connection
  String getOtherUserId(ConnectionModel connection, String currentUserId) {
    return connection.users.firstWhere(
      (userId) => userId != currentUserId,
      orElse: () => '',
    );
  }

  

  /// Check if two users are either in a mutual melt state or already connected
 }
