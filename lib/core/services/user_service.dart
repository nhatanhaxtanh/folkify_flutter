import 'package:dio/dio.dart';
import 'api_client.dart';
import 'auth_service.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        createdAt: json['createdAt'] as String?,
      );
}

class UserService {
  static final _dio = ApiClient.instance;

  static Future<UserProfile> getProfile() async {
    try {
      final res = await _dio.get('/api/users/me');
      return UserProfile.fromJson(res.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<UserProfile> updateProfile(String name) async {
    try {
      final res = await _dio.put('/api/users/me', data: {'name': name});
      return UserProfile.fromJson(res.data['result'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await _dio.put('/api/users/me/password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  static Future<void> deleteAccount() async {
    try {
      await _dio.delete('/api/users/me');
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
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
