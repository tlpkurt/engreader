import '../models/auth_response_model.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/storage/web_secure_storage.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final WebSecureStorage _storage;

  AuthRepository(this._remoteDataSource, this._storage);

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
    try {
      print('DEBUG Repo: Calling remote datasource...');
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      print('DEBUG Repo: Got response, saving tokens...');
      // Save tokens
      await _saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      print('DEBUG Repo: Tokens saved successfully');

      return response;
    } catch (e, stackTrace) {
      print('DEBUG Repo: Error in login: $e');
      print('DEBUG Repo: Stack: $stackTrace');
      rethrow;
    }
  }

  /// Refresh access token
  Future<AuthResponseModel> refreshToken() async {
    final refreshToken = await _storage.read(
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
    final token = await _storage.read(
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
    try {
      print('DEBUG Repo: Writing access token...');
      await _storage.write(
        key: AppConfig.accessTokenKey,
        value: accessToken,
      );
      print('DEBUG Repo: Access token written');
      
      print('DEBUG Repo: Writing refresh token...');
      await _storage.write(
        key: AppConfig.refreshTokenKey,
        value: refreshToken,
      );
      print('DEBUG Repo: Refresh token written');
    } catch (e, stackTrace) {
      print('DEBUG Repo: Error saving tokens: $e');
      print('DEBUG Repo: Stack: $stackTrace');
      rethrow;
    }
  }

  /// Clear all tokens
  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userDataKey);
  }
}
