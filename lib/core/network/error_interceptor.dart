import 'package:dio/dio.dart';
import '../models/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException('Connection timed out');
      case DioExceptionType.badResponse:
        _handleBadResponse(err.response);
        break;
      case DioExceptionType.connectionError:
        throw NetworkException('No internet connection');
      case DioExceptionType.cancel:
        throw AppException('Request cancelled');
      case DioExceptionType.badCertificate:
        throw AppException('Bad certificate');
      case DioExceptionType.unknown:
        throw AppException('An unknown error occurred');
    }
    
    // Pass the original error if it wasn't converted
    handler.next(err);
  }

  void _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    String message = 'Unknown error';
    
    if (response?.data is Map<String, dynamic>) {
      message = response?.data['message'] ?? 'Unknown error';
    } else if (response?.data is String) {
      message = 'Server Error: ${response?.data}'.substring(0, 100); // truncate HTML
    }

    if (statusCode == 400) {
      final details = response?.data is Map<String, dynamic> ? response?.data['errors'] : null;
      throw ValidationException(message, details: details);
    } else if (statusCode == 401 || statusCode == 403) {
      throw AuthException(message);
    } else if (statusCode == 404) {
      throw NotFoundException(message);
    } else if (statusCode != null && statusCode >= 500) {
      throw ServerException(message, statusCode);
    } else {
      throw AppException(message, statusCode: statusCode);
    }
  }
}
