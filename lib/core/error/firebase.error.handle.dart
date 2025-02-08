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

  /// Handles Firebase Authentication errors and returns user-friendly messages.
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "The email address is not valid.";
      case 'user-disabled':
        return "This account has been disabled. Contact support.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'email-already-in-use':
        return "An account already exists with this email.";
      case 'operation-not-allowed':
        return "This operation is not allowed. Contact support.";
      case 'weak-password':
        return "The password is too weak. Use a stronger password.";
      case 'network-request-failed':
        return "A network error occurred. Check your connection.";
      case 'too-many-requests':
        return "Too many failed attempts. Try again later.";
      case 'account-exists-with-different-credential':
        return "An account with this email exists but with a different sign-in method.";
      case 'invalid-credential':
        return "Invalid credentials. Please try again.";
      case 'credential-already-in-use':
        return "This credential is already associated with a different user account.";
      case 'requires-recent-login':
        return "Please re-authenticate before performing this action.";
      case 'provider-already-linked':
        return "This account is already linked to another provider.";
      case 'captcha-check-failed':
        return "Failed security check. Try again.";
      case 'session-expired':
        return "Your session has expired. Please sign in again.";
      default:
        return "An authentication error occurred: ${e.message}";
    }
  }

  /// Handles general Firebase errors.
  static String _handleGeneralFirebaseError(FirebaseException e) {
    switch (e.code) {
      // **Permission & Authentication Errors**
      case 'permission-denied':
        return "You don't have permission to perform this action.";
      case 'unauthenticated':
        return "You must be signed in to perform this action.";
      case 'user-disabled':
        return "Your account has been disabled. Contact support.";
      case 'invalid-credential':
        return "Invalid credentials. Please check your login details.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'user-not-found':
        return "No user found with this email.";
      case 'email-already-in-use':
        return "This email is already associated with another account.";
      case 'account-exists-with-different-credential':
        return "An account already exists with the same email but different sign-in method.";

      // **Network & Availability Errors**
      case 'unavailable':
        return "The service is currently unavailable. Please try again later.";
      case 'network-request-failed':
        return "A network error occurred. Check your internet connection.";
      case 'timeout':
      case 'deadline-exceeded':
        return "The operation took too long to complete. Please try again.";
      case 'cancelled':
        return "The operation was cancelled.";

      // **Database & Storage Errors**
      case 'not-found':
        return "The requested resource was not found.";
 
      case 'deadline-exceeded':
        return "The operation took too long to complete. Please try again.";
      case 'user-not-found':
        return "No user found with this email. Please sign up first.";
 
      case 'already-exists':
        return "The resource you're trying to create already exists.";
      case 'resource-exhausted':
        return "Quota exceeded. Please try again later.";
      case 'failed-precondition':
        return "The operation was rejected due to failed conditions.";
      case 'aborted':
        return "The operation was aborted due to a conflict.";
      case 'data-loss':
        return "Data loss or corruption detected.";

      // **Firebase Storage Specific Errors**
      case 'object-not-found':
        return "The requested file does not exist in Firebase Storage.";
      case 'bucket-not-found':
        return "The specified storage bucket does not exist.";
      case 'unauthorized':
        return "You do not have permission to access this file.";
      case 'storage/quota-exceeded':
        return "Storage quota exceeded. Upgrade your plan.";

      // **General Firebase Errors**
      case 'invalid-argument':
        return "Invalid argument provided. Please check your input.";
      case 'internal':
        return "An internal server error occurred. Try again later.";
      case 'unknown':
      default:
        return "An unexpected Firebase error occurred: ${e.message}";
    }
  }
}
