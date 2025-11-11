import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/web_secure_storage.dart';

// Web Secure Storage Provider
final webSecureStorageProvider = Provider<WebSecureStorage>((ref) {
  return WebSecureStorage();
});

// Auth Remote DataSource Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final storage = ref.watch(webSecureStorageProvider);
  return AuthRepository(remoteDataSource, storage);
});

// Auth State Provider
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        // Optionally fetch current user data
        // final userData = await _authRepository.getCurrentUser();
        // final user = UserModel.fromJson(userData);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Register new user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? nativeLanguage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        nativeLanguage: nativeLanguage,
      );

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Login user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.logout();
      state = AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh token
  Future<void> refreshToken() async {
    try {
      final response = await _authRepository.refreshToken();
      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
      );
    } catch (e) {
      // If refresh fails, logout
      await logout();
      rethrow;
    }
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
