class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  AppException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Please check your internet connection']) : super(message);
}

class ServerException extends AppException {
  ServerException([String message = 'Server error occurred', int? statusCode]) : super(message, statusCode: statusCode);
}

class AuthException extends AppException {
  AuthException([String message = 'Authentication failed']) : super(message, statusCode: 401);
}

class ValidationException extends AppException {
  ValidationException(String message, {dynamic details}) : super(message, statusCode: 400, details: details);
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found']) : super(message, statusCode: 404);
}
