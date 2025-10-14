import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_response_model.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/config/app_config.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._remoteDataSource, this._secureStorage);

  /// Register new user
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? nativeLanguage,
  }) async {
    final response = await _remoteDataSource.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      nativeLanguage: nativeLanguage,
    );

    // Save tokens
    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return response;
  }

  /// Login user
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    // Save tokens
    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return response;
  }

  /// Refresh access token
  Future<AuthResponseModel> refreshToken() async {
    final refreshToken = await _secureStorage.read(
      key: AppConfig.refreshTokenKey,
    );

    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final response = await _remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );

    // Save new tokens
    await _saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return response;
  }

  /// Logout user
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _clearTokens();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(
      key: AppConfig.accessTokenKey,
    );
    return token != null;
  }

  /// Get current user info
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  /// Save tokens to secure storage
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(
      key: AppConfig.accessTokenKey,
      value: accessToken,
    );
    await _secureStorage.write(
      key: AppConfig.refreshTokenKey,
      value: refreshToken,
    );
  }

  /// Clear all tokens
  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
    await _secureStorage.delete(key: AppConfig.userDataKey);
  }
}
