import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// Service that manages user presence (online/offline status) using
/// Firebase Realtime Database's .onDisconnect() feature.
///
/// This is the recommended approach because:
/// 1. RTDB detects disconnections server-side (even on force kills/crashes)
/// 2. Automatically marks users offline when they lose connection
/// 3. Syncs the status to Firestore via Cloud Functions
class PresenceService {
  static final PresenceService _instance = PresenceService._internal();
  static PresenceService get instance => _instance;

  PresenceService._internal();

  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<DatabaseEvent>? _connectedRefSubscription;
  StreamSubscription<User?>? _authSubscription;
  DatabaseReference? _userStatusRef;
  String? _currentUserId;
  bool _isInitialized = false;

  /// Initialize presence tracking for the current user
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Listen to auth state changes to handle login/logout
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _setupPresence(user.uid);
      } else {
        _cleanupPresence();
      }
    });

    // If user is already logged in, set up presence immediately
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _setupPresence(currentUser.uid);
    }

    _isInitialized = true;
  }

  /// Set up presence tracking for a specific user
  Future<void> _setupPresence(String userId) async {
    // Clean up previous user's presence if switching accounts
    if (_currentUserId != null && _currentUserId != userId) {
      await _cleanupPresence();
    }

    _currentUserId = userId;
    _userStatusRef = _rtdb.ref('status/$userId');

    // Reference to the special '.info/connected' path in RTDB
    // This is true when the client is connected to RTDB servers
    final connectedRef = _rtdb.ref('.info/connected');

    // Cancel previous subscription if exists
    await _connectedRefSubscription?.cancel();

    _connectedRefSubscription = connectedRef.onValue.listen((event) async {
      final isConnected = event.snapshot.value as bool? ?? false;

      if (!isConnected) {
        // Not connected to RTDB - can't set up onDisconnect
        return;
      }

      try {
        // Set up the onDisconnect handler FIRST
        // This tells RTDB: "When I disconnect, set this data"
        await _userStatusRef?.onDisconnect().set({
          'isOnline': false,
          'lastActive': ServerValue.timestamp,
        });

        // Now set the user as online
        await _userStatusRef?.set({
          'isOnline': true,
          'lastActive': ServerValue.timestamp,
        });

        print('Presence set up for user: $userId');
      } catch (e) {
        print('Error setting up presence: $e');
      }
    });
  }

  /// Clean up presence tracking (on logout)
  Future<void> _cleanupPresence() async {
    if (_userStatusRef != null && _currentUserId != null) {
      try {
        // Mark as offline before cleanup
        await _userStatusRef?.set({
          'isOnline': false,
          'lastActive': ServerValue.timestamp,
        });

        // Cancel the onDisconnect handler
        await _userStatusRef?.onDisconnect().cancel();
      } catch (e) {
        print('Error cleaning up presence: $e');
      }
    }

    await _connectedRefSubscription?.cancel();
    _connectedRefSubscription = null;
    _userStatusRef = null;
    _currentUserId = null;
  }

  /// Manually mark user as online (e.g., on app resume)
  /// Uses retry mechanism for reliability
  Future<void> goOnline() async {
    if (_userStatusRef == null) return;

    await _retryOperation(
      () async {
        await _userStatusRef?.set({
          'isOnline': true,
          'lastActive': ServerValue.timestamp,
        });
      },
      operationName: 'goOnline',
    );
  }

  /// Manually mark user as offline (e.g., on app pause)
  /// Uses retry mechanism for reliability
  Future<void> goOffline() async {
    if (_userStatusRef == null) return;

    await _retryOperation(
      () async {
        await _userStatusRef?.set({
          'isOnline': false,
          'lastActive': ServerValue.timestamp,
        });
      },
      operationName: 'goOffline',
    );
  }

  /// Retry an operation with exponential backoff
  /// Retries up to [maxRetries] times with increasing delays
  Future<void> _retryOperation(
    Future<void> Function() operation, {
    required String operationName,
    int maxRetries = 3,
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        await operation();
        return; // Success, exit
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          print('$operationName failed after $maxRetries attempts: $e');
          return; // Give up after max retries
        }

        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: 1 << (attempt - 1));
        print(
            '$operationName attempt $attempt failed, retrying in ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
      }
    }
  }

  /// Dispose of all subscriptions
  Future<void> dispose() async {
    await _cleanupPresence();
    await _authSubscription?.cancel();
    _authSubscription = null;
    _isInitialized = false;
  }
}
