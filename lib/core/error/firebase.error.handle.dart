import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  /// Returns a user-friendly error message based on the Firebase exception type and code.
  static String handleFirebaseError(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    } else if (error is FirebaseException) {
      return _handleGeneralFirebaseError(error);
    } else {
      return "An unknown error occurred: ${error.toString()}";
    }
  }

  /// Handles Firebase Authentication errors.
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "The email address is not valid.";
      case 'user-disabled':
        return "This user account has been disabled.";
      case 'user-not-found':
        return "No user found with this email address.";
      case 'wrong-password':
        return "The password is incorrect.";
      case 'email-already-in-use':
        return "The email address is already in use by another account.";
      case 'weak-password':
        return "The password is too weak.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      default:
        return "An authentication error occurred: ${e.message}";
    }
  }

  /// Handles general Firebase errors.
  static String _handleGeneralFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return "You don't have permission to perform this action.";
      case 'unavailable':
        return "The service is currently unavailable. Please try again later.";
      case 'cancelled':
        return "The operation was cancelled.";
      case 'not-found':
        return "The requested resource was not found.";
      case 'deadline-exceeded':
        return "The operation took too long to complete. Please try again.";
      case 'already-exists':
        return "The resource you're trying to create already exists.";
      default:
        return "A Firebase error occurred: ${e.message}";
    }
  }
}
