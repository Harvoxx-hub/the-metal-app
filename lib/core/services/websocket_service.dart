import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:metal/core/constants/app_constants.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';

/// WebSocket Service
/// Manages WebSocket connection for real-time messaging
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final SecureStorageHelper _secureStorage = SecureStorageHelper();

  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  // Stream controllers for different event types
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // Getters
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<bool> connect() async {
    if (_isConnected || _isConnecting) {
      return _isConnected;
    }

    _isConnecting = true;

    try {
      // Get authentication token
      final token = await _secureStorage.getString('auth_token');
      if (token == null || token.isEmpty) {
        print('WebSocket: No auth token available');
        _isConnecting = false;
        return false;
      }

      // Build WebSocket URL
      final wsUrl = _buildWebSocketUrl(token);
      print('WebSocket: Connecting to $wsUrl');

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Use Completer to wait for connection confirmation
      final connectionCompleter = Completer<bool>();

      // Set up message listener BEFORE marking as connected
      // We'll mark as connected when we receive the 'connected' message from server
      _subscription = _channel!.stream.listen(
        (message) {
          // Handle connection confirmation first
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            if (data['type'] == 'connected') {
              // Now we're truly connected
              if (!_isConnected) {
                _isConnected = true;
                _isConnecting = false;
                _reconnectAttempts = 0;
                _connectionController.add(true);
                print('WebSocket: Connected successfully');
                _startHeartbeat();

                // Complete the connection completer
                if (!connectionCompleter.isCompleted) {
                  connectionCompleter.complete(true);
                }
              }
              return;
            }
          } catch (e) {
            // Not JSON or not a connection message, continue to normal handler
          }
          _handleMessage(message);
        },
        onError: (error) {
          if (!connectionCompleter.isCompleted) {
            connectionCompleter.complete(false);
          }
          _handleError(error);
        },
        onDone: () {
          if (!connectionCompleter.isCompleted) {
            connectionCompleter.complete(false);
          }
          _handleDisconnect();
        },
        cancelOnError: false,
      );

      // Wait for connection confirmation with timeout
      final connected = await connectionCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('WebSocket: Connection timeout - no confirmation received');
          return false;
        },
      );

      if (!connected) {
        _isConnecting = false;
        _handleDisconnect();
        return false;
      }

      return true;
    } catch (e) {
      print('WebSocket: Connection error: $e');
      _isConnecting = false;
      _handleDisconnect();
      return false;
    }
  }

  /// Build WebSocket URL with token
  String _buildWebSocketUrl(String token) {
    // Convert http/https to ws/wss
    final baseUrl = AppConstants.apiBaseUrl;
    final wsProtocol = baseUrl.startsWith('https') ? 'wss' : 'ws';

    // Parse the base URL to extract host properly
    final uri = Uri.parse(baseUrl);

    // Build WebSocket URL using Uri constructor to avoid port issues
    final wsUri = Uri(
      scheme: wsProtocol,
      host: uri.host,
      path: '/api/v1/ws',
      queryParameters: {'token': token},
    );

    return wsUri.toString();
  }

  /// Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;

      // Handle pong response (connection confirmation is handled in connect())
      if (data['type'] == 'pong') {
        return;
      }

      // Broadcast message to listeners
      _messageController.add(data);
    } catch (e) {
      print('WebSocket: Error parsing message: $e');
    }
  }

  /// Handle errors
  void _handleError(dynamic error) {
    print('WebSocket: Error: $error');
    _handleDisconnect();
  }

  /// Handle disconnection
  void _handleDisconnect() {
    if (!_isConnected) return;

    _isConnected = false;
    _isConnecting = false;
    _subscription?.cancel();
    _channel = null;
    _stopHeartbeat();
    _connectionController.add(false);

    print('WebSocket: Disconnected');

    // Attempt to reconnect
    _scheduleReconnect();
  }

  /// Schedule reconnection
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('WebSocket: Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      print(
          'WebSocket: Attempting to reconnect (${_reconnectAttempts}/$_maxReconnectAttempts)');
      connect();
    });
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected && _channel != null) {
        sendMessage({'type': 'ping'});
      }
    });
  }

  /// Stop heartbeat
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Send message through WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (!_isConnected || _channel == null) {
      print('WebSocket: Cannot send message - not connected');
      return;
    }

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('WebSocket: Error sending message: $e');
    }
  }

  /// Send typing indicator
  void sendTyping({
    required String recipientId,
    required String connectionId,
    required bool isTyping,
  }) {
    sendMessage({
      'type': 'typing',
      'data': {
        'recipientId': recipientId,
        'conversationId': connectionId,
        'isTyping': isTyping,
      },
    });
  }

  /// Send read receipt
  void sendReadReceipt({
    required String senderId,
    required String messageId,
    required String connectionId,
  }) {
    sendMessage({
      'type': 'read_receipt',
      'data': {
        'senderId': senderId,
        'messageId': messageId,
        'conversationId': connectionId,
      },
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _isConnecting = false;
    _reconnectAttempts = 0;
    _connectionController.add(false);
    print('WebSocket: Disconnected manually');
  }

  /// Reconnect to WebSocket
  Future<bool> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    return connect();
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
