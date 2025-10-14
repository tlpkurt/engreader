import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));
  
  // Add logging interceptor (development only)
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj),
    ),
  );

  return dio;
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please try again.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Something went wrong';
        
        switch (statusCode) {
          case 400:
            return BadRequestException(message);
          case 401:
            return UnauthorizedException('Session expired. Please login again.');
          case 403:
            return ForbiddenException('Access denied.');
          case 404:
            return NotFoundException('Resource not found.');
          case 500:
            return ServerException('Server error. Please try again later.');
          default:
            return ApiException(message);
        }
      
      case DioExceptionType.cancel:
        return NetworkException('Request cancelled.');
      
      case DioExceptionType.unknown:
        return NetworkException('Network error. Please check your connection.');
      
      default:
        return ApiException('An unexpected error occurred.');
    }
  }
}

// Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

// Custom Exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
