/// API endpoint definitions
/// Centralized location for all API routes
/// Add your endpoints here as they become available
class ApiRoutes {
  // Base API version
  static const String apiVersion = '/api/v1';

  // Helper methods to build full paths
  static String buildPath(String endpoint) {
    return '$apiVersion$endpoint';
  }

  static String buildPathWithId(String endpoint, String id) {
    return '$apiVersion$endpoint/$id';
  }

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String sendVerificationCode = '/auth/send-verification-code';
  static const String verifyCode = '/auth/verify-code';
  static const String resetPassword = '/auth/reset-password';

  // User/Profile endpoints
  static const String getUserProfile = '/users/me';
  static const String updateUserProfile = '/users/me';
  static const String completeProfile = '/users/me/profile/complete';
  static const String getUserById = '/users'; // /users/:id

  // Discovery endpoints
  static const String discoveryUsers = '/discovery/users';
  static const String discoverySwipe = '/discovery/swipe';
  static const String discoveryHistory = '/discovery/history';
  static const String discoveryUndo = '/discovery/undo';

  // Connection endpoints
  static const String connections = '/connections';
  static const String connectionById = '/connections'; // /connections/:id

  // Message endpoints
  static const String messages = '/messages';
  static const String messagesByConnection = '/messages'; // /messages/:connectionId
  static const String messageById = '/messages'; // /messages/:id
  static const String markMessageRead = '/messages'; // /messages/:id/read
  static const String clearChat = '/connections'; // /connections/:id/clear
}
