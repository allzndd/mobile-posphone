import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/api_config.dart';

/// Service untuk mengelola autentikasi
class AuthService {

  /// Login user
  static Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.getUrl(ApiConfig.loginEndpoint)),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

        // Simpan token dan user data ke SharedPreferences
        await _saveAuthData(loginResponse);

        return loginResponse;
      } else if (response.statusCode == 422) {
        // Validation error
        final json = jsonDecode(response.body);
        final errors = json['errors'] as Map<String, dynamic>?;
        final errorMessage = errors?.values.first[0] ?? 'Login gagal';
        throw Exception(errorMessage);
      } else {
        throw Exception('Login gagal. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      final token = await getToken();

      if (token != null) {
        await http
            .post(
              Uri.parse(ApiConfig.getUrl(ApiConfig.logoutEndpoint)),
              headers: ApiConfig.authHeaders(token),
            )
            .timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      // Ignore error saat logout
      print('Error during logout: $e');
    } finally {
      // Hapus data lokal
      await _clearAuthData();
    }
  }

  /// Get current user info
  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Get saved token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save auth data to SharedPreferences
  static Future<void> _saveAuthData(LoginResponse loginResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginResponse.token);
      await prefs.setString('token_type', loginResponse.tokenType);
      await prefs.setString('user', jsonEncode(loginResponse.user.toJson()));
    } catch (e) {
      print('Error saving auth data: $e');
    }
  }

  /// Clear auth data from SharedPreferences
  static Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('token_type');
      await prefs.remove('user');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  /// Refresh user data from API
  static Future<UserModel?> refreshUserData() async {
    try {
      final token = await getToken();

      if (token == null) {
        return null;
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.getUrl(ApiConfig.userEndpoint)),
            headers: ApiConfig.authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final user = UserModel.fromJson(json['data']);

        // Update user data di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(user.toJson()));

        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Error refreshing user data: $e');
      return null;
    }
  }
}
