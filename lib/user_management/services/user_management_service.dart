import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/admin_user_model.dart';

/// Service for managing admin users
class UserManagementService {
  /// Get list of admin users
  static Future<Map<String, dynamic>> getAdminUsers() async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.getUrl('/api/users')),
            headers: ApiConfig.authHeaders(token),
          )
          .timeout(const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonResponse['data'] ?? [];
        final List<AdminUserModel> admins = data
            .map((json) => AdminUserModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Success',
          'data': admins,
        };
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Failed to get admin users',
        );
      }
    } catch (e) {
      print('Error getting admin users: $e');
      return {
        'success': false,
        'message': 'Failed to get admin users: $e',
        'data': [],
      };
    }
  }

  /// Create a new admin user
  static Future<Map<String, dynamic>> createAdminUser({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
    int? storeId,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final Map<String, dynamic> body = {
        'nama': nama,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      if (storeId != null) {
        body['store_id'] = storeId;
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.getUrl('/api/users')),
            headers: ApiConfig.authHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Admin user created successfully',
          'data': AdminUserModel.fromJson(jsonResponse['data']),
        };
      } else if (response.statusCode == 422) {
        // Validation error
        final errors = jsonResponse['errors'] as Map<String, dynamic>?;
        final errorMessage = errors?.values.first[0] ?? 'Validation failed';
        throw Exception(errorMessage);
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Failed to create admin user',
        );
      }
    } catch (e) {
      print('Error creating admin user: $e');
      return {
        'success': false,
        'message': 'Failed to create admin user: $e',
      };
    }
  }

  /// Get a specific admin user
  static Future<Map<String, dynamic>> getAdminUser(int id) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.getUrl('/api/users/$id')),
            headers: ApiConfig.authHeaders(token),
          )
          .timeout(const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Success',
          'data': AdminUserModel.fromJson(jsonResponse['data']),
        };
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Failed to get admin user',
        );
      }
    } catch (e) {
      print('Error getting admin user: $e');
      return {
        'success': false,
        'message': 'Failed to get admin user: $e',
      };
    }
  }

  /// Update an admin user
  static Future<Map<String, dynamic>> updateAdminUser({
    required int id,
    String? nama,
    String? email,
    String? password,
    String? passwordConfirmation,
    int? storeId,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final Map<String, dynamic> body = {};
      if (nama != null) body['nama'] = nama;
      if (email != null) body['email'] = email;
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
        body['password_confirmation'] = passwordConfirmation;
      }
      if (storeId != null) {
        body['store_id'] = storeId;
      }

      final response = await http
          .put(
            Uri.parse(ApiConfig.getUrl('/api/users/$id')),
            headers: ApiConfig.authHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Admin user updated successfully',
          'data': AdminUserModel.fromJson(jsonResponse['data']),
        };
      } else if (response.statusCode == 422) {
        // Validation error
        final errors = jsonResponse['errors'] as Map<String, dynamic>?;
        final errorMessage = errors?.values.first[0] ?? 'Validation failed';
        throw Exception(errorMessage);
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Failed to update admin user',
        );
      }
    } catch (e) {
      print('Error updating admin user: $e');
      return {
        'success': false,
        'message': 'Failed to update admin user: $e',
      };
    }
  }

  /// Delete an admin user
  static Future<Map<String, dynamic>> deleteAdminUser(int id) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http
          .delete(
            Uri.parse(ApiConfig.getUrl('/api/users/$id')),
            headers: ApiConfig.authHeaders(token),
          )
          .timeout(const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Admin user deleted successfully',
        };
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Failed to delete admin user',
        );
      }
    } catch (e) {
      print('Error deleting admin user: $e');
      return {
        'success': false,
        'message': 'Failed to delete admin user: $e',
      };
    }
  }
}
