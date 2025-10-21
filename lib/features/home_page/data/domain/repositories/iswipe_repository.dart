import 'package:metal/core/model/responces.dart';

abstract class ISwipeRepository {
  /// Get users for swiping based on user preferences and location
  Future<Responses> getSwipeUsers({
    int limit = 10,
    String? lastUserId,
  });

  /// Get more users for swiping (pagination)
  Future<Responses> getMoreSwipeUsers({
    required String lastUserId,
    int limit = 10,
  });

  /// Record a swipe action (like, pass, super like)
  Future<Responses> recordSwipeAction({
    required String targetUserId,
    required SwipeAction action,
  });

  /// Get swipe history for the current user
  Future<Responses> getSwipeHistory();
}

enum SwipeAction {
  like,
  pass,
  superLike,
}
