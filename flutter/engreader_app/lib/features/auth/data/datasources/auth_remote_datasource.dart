import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  /// Register new user
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? nativeLanguage,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.authEndpoint}/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'nativeLanguage': nativeLanguage ?? 'tr',
        },
      );

      // Backend returns ApiResponse wrapper, extract data
      return AuthResponseModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.authEndpoint}/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('DEBUG Remote: Full response: ${response.data}');
      print('DEBUG Remote: Data field: ${response.data['data']}');
      
      // Backend returns ApiResponse wrapper, extract data
      final authResponse = AuthResponseModel.fromJson(response.data['data']);
      print('DEBUG Remote: Parsed successfully');
      return authResponse;
    } catch (e, stackTrace) {
      print('DEBUG Remote: Parse error: $e');
      print('DEBUG Remote: Stack: $stackTrace');
      rethrow;
    }
  }

  /// Refresh access token
  Future<AuthResponseModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiClient.post(
        '${AppConfig.authEndpoint}/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      // Backend returns ApiResponse wrapper, extract data
      return AuthResponseModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.authEndpoint}/me',
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout (optional - just for API call if needed)
  Future<void> logout() async {
    // Optional: Call logout endpoint if backend requires it
    // For now, just clear local tokens
    return;
  }
}
