class AuthExceptionMessages {
  
  static const String unexpectedError =
      'Something went wrong. Please try again in a moment.';

  static const String networkError =
      'Network error. Check your connection and try again.';

  static const String requestTimedOut =
      'Request timed out. Check your connection and try again.';

  static const String invalidEmail = 'Please enter a valid email address.';

  static const String invalidCredentials =
      'Incorrect email or password. Please try again.';

  static const String emailAlreadyInUse =
      'An account already exists for this email.';

  static const String tooManyRequests =
      'Too many attempts. Please wait a bit and try again.';

  static String messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return invalidEmail;
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return invalidCredentials;
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return emailAlreadyInUse;
      case 'too-many-requests':
        return tooManyRequests;
      case 'network-request-failed':
        return networkError;
      default:
        return unexpectedError;
    }
  }
}