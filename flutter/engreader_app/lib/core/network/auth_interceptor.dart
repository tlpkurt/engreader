import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await _storage.read(key: AppConfig.accessTokenKey);
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshToken = await _storage.read(key: AppConfig.refreshTokenKey);
      
      if (refreshToken != null) {
        try {
          // Call refresh token endpoint
          final dio = Dio();
          final response = await dio.post(
            '${AppConfig.apiBaseUrl}${AppConfig.authEndpoint}/refresh',
            data: {'refreshToken': refreshToken},
          );
          
          if (response.statusCode == 200) {
            // Save new tokens
            final newAccessToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];
            
            await _storage.write(
              key: AppConfig.accessTokenKey,
              value: newAccessToken,
            );
            await _storage.write(
              key: AppConfig.refreshTokenKey,
              value: newRefreshToken,
            );
            
            // Retry the original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed, logout user
          await _clearTokens();
          // Navigate to login (handled by exception in UI)
        }
      } else {
        // No refresh token, logout user
        await _clearTokens();
      }
    }
    
    handler.next(err);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userDataKey);
  }
}
