import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    
    // Don't add auth header for login/register endpoints
    if (token != null && !options.path.contains('/auth/')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // If we get a 401 Unauthorized, try to refresh the token
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains(ApiEndpoints.refresh)) {
      final success = await _refreshToken();
      
      if (success) {
        // Retry the failed request with the new token
        final opts = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
        );
        
        try {
          final response = await dio.request(
            err.requestOptions.path,
            options: opts,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      } else {
        // Refresh failed, let the error pass through (which logs user out via auth provider listening to this)
        return handler.next(err);
      }
    }
    
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      
      if (refreshToken == null) return false;
      
      final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        
        await prefs.setString(AppConstants.tokenKey, newAccessToken);
        await prefs.setString(AppConstants.refreshTokenKey, newRefreshToken);
        
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}
