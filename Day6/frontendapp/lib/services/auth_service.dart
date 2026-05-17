import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> roles;

  bool get isAdmin => roles.any((role) => role.toLowerCase() == 'admin');

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => role.toString())
          .toList(),
    );
  }
}

class AuthResult {
  const AuthResult({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  final String token;
  final DateTime expiresAt;
  final AppUser user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token']?.toString() ?? '',
      expiresAt:
          DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now(),
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final result = AuthResult.fromJson(response.data as Map<String, dynamic>);
    await DioClient.storage.write(key: DioClient.tokenKey, value: result.token);
    return result;
  }

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'fullName': fullName, 'email': email, 'password': password},
    );

    final result = AuthResult.fromJson(response.data as Map<String, dynamic>);
    await DioClient.storage.write(key: DioClient.tokenKey, value: result.token);
    return result;
  }

  Future<AppUser?> getCurrentUser() async {
    final token = await DioClient.storage.read(key: DioClient.tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await _dio.get('/auth/me');
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AppUser> updateProfile({
    required String fullName,
    required String email,
  }) async {
    final response = await _dio.put(
      '/auth/me',
      data: {'fullName': fullName, 'email': email},
    );

    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AppUser>> getUsers() async {
    final response = await _dio.get('/user');
    return (response.data as List<dynamic>)
        .map((item) => AppUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AppUser> createUser({
    required String fullName,
    required String email,
    required String password,
    required List<String> roles,
  }) async {
    final response = await _dio.post(
      '/user',
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'roles': roles,
      },
    );

    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<String>> getRoles() async {
    final response = await _dio.get('/user/roles');
    return (response.data as List<dynamic>)
        .map((role) => role.toString())
        .toList();
  }

  Future<void> updateUserRoles(String id, List<String> roles) async {
    await _dio.put('/user/$id/roles', data: {'roles': roles});
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete('/user/$id');
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/auth/me');
    await logout();
  }

  Future<void> logout() async {
    await DioClient.storage.delete(key: DioClient.tokenKey);
  }

  String getErrorMessage(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Khong ket noi duoc API. Hay kiem tra backend da chay va dung API_BASE_URL.';
      }

      if (error.type == DioExceptionType.connectionError) {
        return 'Khong ket noi duoc server. Neu chay tren dien thoai that, dung IP LAN cua may tinh thay cho localhost.';
      }

      final data = error.response?.data;
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }

      if (data is Map<String, dynamic> && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final messages = errors.values
            .whereType<List>()
            .expand((items) => items)
            .map((item) => item.toString())
            .where((message) => message.isNotEmpty)
            .toList();

        if (messages.isNotEmpty) {
          return messages.first;
        }
      }

      if (data is List && data.isNotEmpty) {
        final firstError = data.first;
        if (firstError is Map && firstError['description'] != null) {
          return firstError['description'].toString();
        }
      }

      if (error.response?.statusCode == 404) {
        return 'Khong tim thay API nay. Hay stop backend cu va chay lai backend moi.';
      }

      if (error.response?.statusCode == 400) {
        return 'Thong tin gui len khong hop le. Hay kiem tra lai du lieu.';
      }

      return error.message ?? 'Cannot connect to API.';
    }

    return 'Something went wrong.';
  }
}
