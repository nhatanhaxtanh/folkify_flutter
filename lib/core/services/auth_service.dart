import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class UserInfo {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final UserInfo user;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

class AuthService {
  static final _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ));

  static Future<AuthTokens> login(String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      return _parseAuthResponse(res.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<AuthTokens> register(
      String name, String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return _parseAuthResponse(res.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/api/auth/logout', data: {'refreshToken': refreshToken});
    } on DioException {
      // Ignore logout errors — local state is cleared regardless
    }
  }

  static Future<AuthTokens> loginWithGoogle(String idToken) async {
    try {
      final res = await _dio.post('/api/auth/google', data: {'idToken': idToken});
      return _parseAuthResponse(res.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/api/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post('/api/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<AuthTokens> refreshAccessToken(String refreshToken) async {
    try {
      final res = await _dio.post('/api/auth/refresh-token', data: {
        'refreshToken': refreshToken,
      });
      return _parseAuthResponse(res.data);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static AuthTokens _parseAuthResponse(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>;
    final userJson = result['user'] as Map<String, dynamic>;
    return AuthTokens(
      accessToken: result['accessToken'] as String,
      refreshToken: result['refreshToken'] as String,
      user: UserInfo(
        id: userJson['id'] as String,
        name: userJson['name'] as String,
        email: userJson['email'] as String,
        role: userJson['role'] as String,
      ),
    );
  }

  static String _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'] as String;
      }
    } catch (_) {}
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        'Kết nối quá thời gian, vui lòng thử lại',
      DioExceptionType.connectionError => 'Không thể kết nối máy chủ',
      _ => 'Lỗi không xác định',
    };
  }
}
