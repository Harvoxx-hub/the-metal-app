import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
 
import 'package:metal/route/routes.dart';
import 'package:metal/core/storage/secure_storage_helper.dart';
import 'package:metal/core/storage/shared_prefs_helper.dart';

/// Service to handle deep links and universal links
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService _instance = DeepLinkService._();
  static DeepLinkService get instance => _instance;

  StreamSubscription? _linkSubscription;
  BuildContext? _context;
  final AppLinks _appLinks = AppLinks();
  SecureStorageHelper? _secureStorage;
  SharedPrefsHelper? _sharedPrefs;
  
  static const String _pendingUriKey = 'pending_deep_link_uri';

  /// Initialize deep link handling
  void initialize(
    BuildContext context, {
    SecureStorageHelper? secureStorage,
    SharedPrefsHelper? sharedPrefs,
  }) {
    _context = context;
    _secureStorage = secureStorage;
    _sharedPrefs = sharedPrefs;
    _initAppLinks();
    // Process any pending links from previous session
    _processPendingLinks();
  }

  /// Initialize app_links for handling incoming links
  void _initAppLinks() {
    // Handle app links while the app is already started - be it in
    // the foreground or in the background.
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleIncomingUri(uri);
      },
      onError: (err) {
        print('DeepLinkService: Error handling link: $err');
      },
    );

    // Handle app links while the app is closed
    _appLinks.getInitialLink().then((Uri? initialUri) {
      if (initialUri != null) {
        _handleIncomingUri(initialUri);
      }
    });
  }

  /// Handle incoming deep links
  void _handleIncomingUri(Uri uri) {
    print('DeepLinkService: Received URI: $uri');

    if (_context == null) {
      print('DeepLinkService: Context not available, storing link for later');
      _storePendingUri(uri);
      return;
    }

    // Check authentication before handling deep link
    _checkAuthAndNavigate(uri);
  }
  
  /// Check authentication and navigate accordingly
  Future<void> _checkAuthAndNavigate(Uri uri) async {
    final isAuthenticated = await _isUserAuthenticated();
    
    if (!isAuthenticated) {
      print('DeepLinkService: User not authenticated, storing link and redirecting to login');
      await _storePendingUri(uri);
      if (_context != null && _context!.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          _context!,
          AppRoutes.login,
          (route) => false,
        );
      }
      return;
    }

    // User is authenticated, proceed with navigation
    try {
      _navigateFromUri(uri);
    } catch (e) {
      print('DeepLinkService: Error handling URI: $e');
      // Fallback: navigate to dashboard
      if (_context != null && _context!.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          _context!,
          AppRoutes.dashboardPage,
          (route) => false,
        );
      }
    }
  }
  
  /// Check if user is authenticated by checking for auth token
  Future<bool> _isUserAuthenticated() async {
    if (_secureStorage == null) {
      print('DeepLinkService: SecureStorage not available, assuming not authenticated');
      return false;
    }
    
    try {
      final token = await _secureStorage!.getString('auth_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('DeepLinkService: Error checking authentication: $e');
      return false;
    }
  }

  /// Navigate based on URI path
  void _navigateFromUri(Uri uri) {
    if (_context == null) return;

    final pathSegments = uri.pathSegments;
    final scheme = uri.scheme;
    final host = uri.host;
    print('DeepLinkService: URI: $uri');
    print('DeepLinkService: Scheme: $scheme');
    print('DeepLinkService: Host: $host');
    print('DeepLinkService: Path segments: $pathSegments');

    if (pathSegments.isEmpty && host.isEmpty) {
      // Root path - navigate to dashboard
      Navigator.pushNamedAndRemoveUntil(
        _context!,
        AppRoutes.dashboardPage,
        (route) => false,
      );
      return;
    }

    // Handle custom scheme URLs (e.g., metal://thought/123)
    if (scheme == 'metal') {
      _handleCustomSchemeUri(uri, pathSegments, host);
      return;
    }

    // Handle HTTP/HTTPS URLs (e.g., https://domain.com/thought/123)
    _handleHttpUri(uri, pathSegments);
  }

  /// Handle custom scheme URLs like metal://thought/123
  void _handleCustomSchemeUri(Uri uri, List<String> pathSegments, String host) {
    print(
        'DeepLinkService: Handling custom scheme - Host: $host, Path segments: $pathSegments');

    String contentType;
    String contentId;

    // For custom schemes, the structure can vary:
    // metal://thought/123 -> host = "thought", pathSegments = ["123"]
    // metal://thought/123 -> host = "", pathSegments = ["thought", "123"]

    if (host.isNotEmpty) {
      // Case 1: metal://thought/123 -> host = "thought", pathSegments = ["123"]
      contentType = host;
      contentId = pathSegments.isNotEmpty ? pathSegments[0] : '';
    } else if (pathSegments.length >= 2) {
      // Case 2: metal://thought/123 -> host = "", pathSegments = ["thought", "123"]
      contentType = pathSegments[0];
      contentId = pathSegments[1];
    } else {
      print('DeepLinkService: Invalid custom scheme URL format');
      Navigator.pushNamedAndRemoveUntil(
        _context!,
        AppRoutes.dashboardPage,
        (route) => false,
      );
      return;
    }

    print(
        'DeepLinkService: Custom scheme - Type: $contentType, ID: $contentId');

    switch (contentType) {
      case 'thought':
        if (contentId.isNotEmpty) {
          _navigateToThought(contentId);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            _context!,
            AppRoutes.dashboardPage,
            (route) => false,
          );
        }
        break;
      case 'user':
        if (contentId.isNotEmpty) {
          _navigateToUser(contentId);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            _context!,
            AppRoutes.dashboardPage,
            (route) => false,
          );
        }
        break;
      case 'community':
        if (contentId.isNotEmpty) {
          _navigateToCommunity(contentId);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            _context!,
            AppRoutes.dashboardPage,
            (route) => false,
          );
        }
        break;
      case 'meetup':
        if (contentId.isNotEmpty) {
          _navigateToMeetup(contentId);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            _context!,
            AppRoutes.dashboardPage,
            (route) => false,
          );
        }
        break;
      default:
        print('DeepLinkService: Unknown content type: $contentType');
        Navigator.pushNamedAndRemoveUntil(
          _context!,
          AppRoutes.dashboardPage,
          (route) => false,
        );
    }
  }

  /// Handle HTTP/HTTPS URLs like https://domain.com/thought/123
  void _handleHttpUri(Uri uri, List<String> pathSegments) {
    // Check the first path segment to determine the type of content
    final firstSegment = pathSegments[0];
    print('DeepLinkService: First segment: $firstSegment');

    switch (firstSegment) {
      case 'thought':
        if (pathSegments.length > 1) {
          final thoughtId = pathSegments[1];
          _navigateToThought(thoughtId);
        } else {
          // Invalid thought URL - navigate to dashboard
          Navigator.pushNamedAndRemoveUntil(
            _context!,
            AppRoutes.dashboardPage,
            (route) => false,
          );
        }
        break;
      case 'user':
        if (pathSegments.length > 1) {
          final userId = pathSegments[1];
          _navigateToUser(userId);
        } else {
          // Invalid user URL - navigate to dashboard
          Navigator.pushNamedAndRemoveUntil(
            _context!,
            AppRoutes.dashboardPage,
            (route) => false,
          );
        }
        break;
      case 'community':
        if (pathSegments.length > 1) {
          final communityId = pathSegments[1];
          _navigateToCommunity(communityId);
        } else {
          // Invalid community URL - navigate to dashboard
          Navigator.pushNamedAndRemoveUntil(
            _context!,
            AppRoutes.dashboardPage,
            (route) => false,
          );
        }
        break;
      case 'meetup':
        if (pathSegments.length > 1) {
          final meetupId = pathSegments[1];
          _navigateToMeetup(meetupId);
        } else {
          // Invalid meetup URL - navigate to dashboard
          Navigator.pushNamedAndRemoveUntil(
            _context!,
            AppRoutes.dashboardPage,
            (route) => false,
          );
        }
        break;
      default:
        // Unknown path - navigate to dashboard
        Navigator.pushNamedAndRemoveUntil(
          _context!,
          AppRoutes.dashboardPage,
          (route) => false,
        );
    }
  }

  /// Navigate to thought details page
  void _navigateToThought(String thoughtId) {
    if (_context == null) {
      print(
          'DeepLinkService: Context is null, cannot navigate to thought: $thoughtId');
      return;
    }

    print('DeepLinkService: Navigating to thought: $thoughtId');

    // Use a more robust navigation approach
    // First navigate to dashboard, then to thought details
    Navigator.pushNamedAndRemoveUntil(
      _context!,
      AppRoutes.dashboardPage,
      (route) => false,
    );

    // Navigate to thought details after dashboard is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_context != null && _context!.mounted) {
        Navigator.pushNamed(
          _context!,
          AppRoutes.thoughtDetails,
          arguments: thoughtId,
        );
      }
    });
  }

  /// Navigate to user profile
  void _navigateToUser(String userId) {
    if (_context == null) return;
    Navigator.pushNamedAndRemoveUntil(
      _context!,
      AppRoutes.dashboardPage,
      (route) => false,
    );

    // Navigate to user profile after dashboard is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_context != null && _context!.mounted) {
        Navigator.pushNamed(
          _context!,
          AppRoutes.userProfile,
          arguments: userId,
        );
      }
    });
  }

  /// Navigate to community profile
  void _navigateToCommunity(String communityId) {
    if (_context == null) return;

    Navigator.pushNamedAndRemoveUntil(
      _context!,
      AppRoutes.dashboardPage,
      (route) => false,
    );

    // Navigate to community details after dashboard is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_context != null && _context!.mounted) {
        Navigator.pushNamed(
          _context!,
          AppRoutes.communityDetails,
          arguments: communityId,
        );
      }
    });
  }

  /// Store pending URI for later processing
  Future<void> _storePendingUri(Uri uri) async {
    if (_sharedPrefs == null) {
      print('DeepLinkService: SharedPrefs not available, cannot store pending URI');
      return;
    }
    
    try {
      await _sharedPrefs!.setString(_pendingUriKey, uri.toString());
      print('DeepLinkService: Stored pending URI: $uri');
    } catch (e) {
      print('DeepLinkService: Error storing pending URI: $e');
    }
  }

  /// Process any pending links when context becomes available
  Future<bool> _processPendingLinks() async {
    if (_sharedPrefs == null || _context == null) {
      return false;
    }
    
    try {
      final pendingUriString = _sharedPrefs!.getString(_pendingUriKey);
      if (pendingUriString != null && pendingUriString.isNotEmpty) {
        final uri = Uri.parse(pendingUriString);
        print('DeepLinkService: Processing pending URI: $uri');
        
        // Clear the pending URI
        await _sharedPrefs!.remove(_pendingUriKey);
        
        // User is now authenticated, proceed with navigation
        try {
          _navigateFromUri(uri);
          return true; // Pending link was processed
        } catch (e) {
          print('DeepLinkService: Error navigating from pending URI: $e');
          // Fallback: navigate to dashboard
          if (_context != null && _context!.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              _context!,
              AppRoutes.dashboardPage,
              (route) => false,
            );
          }
          return true; // Still processed, even if navigation failed
        }
      }
      return false; // No pending link
    } catch (e) {
      print('DeepLinkService: Error processing pending links: $e');
      return false;
    }
  }
  
  /// Process pending links after successful login
  /// Call this method after user successfully logs in
  /// Returns true if a pending link was processed, false otherwise
  Future<bool> processPendingLinks() async {
    return await _processPendingLinks();
  }

  /// Generate shareable URL for a thought
  static String generateThoughtUrl(String thoughtId) {
    return 'https://themetalapp.com/thought/$thoughtId';
  }

  /// Generate shareable URL for a user
  static String generateUserUrl(String userId) {
    return 'https://themetalapp.com/user/$userId';
  }

  /// Generate shareable URL for a community
  static String generateCommunityUrl(String communityId) {
    return 'https://themetalapp.com/community/$communityId';
  }

  /// Navigate to meetup details page
  void _navigateToMeetup(String meetupId) {
    if (_context == null) return;

    Navigator.pushNamedAndRemoveUntil(
      _context!,
      AppRoutes.dashboardPage,
      (route) => false,
    );

    // Navigate to meetup details after dashboard is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_context != null && _context!.mounted) {
        Navigator.pushNamed(
          _context!,
          AppRoutes.meetupDetails,
          arguments: meetupId,
        );
      }
    });
  }

  /// Generate shareable URL for a meetup
  static String generateMeetupUrl(String meetupId) {
    return 'https://themetalapp.com/meetup/$meetupId';
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _context = null;
  }
}
