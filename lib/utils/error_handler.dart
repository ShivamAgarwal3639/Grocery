class ErrorHandler {
  static String getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'The phone number provided is invalid';
      case 'invalid-verification-code':
        return 'The verification code is invalid';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
