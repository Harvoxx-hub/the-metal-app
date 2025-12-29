import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/services/websocket_service.dart';

/// Provider for WebSocket service (singleton)
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});


