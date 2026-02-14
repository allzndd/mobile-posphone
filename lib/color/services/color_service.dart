import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class ColorService {
  /// Get all colors with pagination and search
  static Future<Map<String, dynamic>> getColors({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ [COLOR SERVICE] Token not found');
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri =
          Uri.parse('${ApiConfig.baseUrl}/api/colors')
              .replace(queryParameters: queryParams);

      print('🔍 [COLOR SERVICE] Request URL: $uri');
      print('🔑 [COLOR SERVICE] Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📊 [COLOR SERVICE] Status Code: ${response.statusCode}');
      print('📦 [COLOR SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [COLOR SERVICE] Success - Total items: ${data['total']}');
        return {
          'success': true,
          'data': data['data'] ?? [],
          'total': data['total'] ?? 0,
          'current_page': data['current_page'] ?? 1,
          'last_page': data['last_page'] ?? 1,
          'per_page': data['per_page'] ?? perPage,
          'message': 'Colors loaded successfully',
        };
      } else if (response.statusCode == 401) {
        print('⚠️ [COLOR SERVICE] Unauthorized - logging out');
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        print('❌ [COLOR SERVICE] Error response: ${response.body}');
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load colors',
        };
      }
    } catch (e, stackTrace) {
      print('❌ [COLOR SERVICE] Exception caught: $e');
      print('📍 [COLOR SERVICE] Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get color by ID
  static Future<Map<String, dynamic>> getColorById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/colors/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Color loaded successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'message': 'Color not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Create new color
  static Future<Map<String, dynamic>> createColor({
    required String warna,
    bool isGlobal = false,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/colors'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'warna': warna,
          'is_global': isGlobal,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Color created successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'errors': data['errors'] ?? {},
          'message': data['message'] ?? 'Validation failed',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create color',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update color
  static Future<Map<String, dynamic>> updateColor({
    required int id,
    required String warna,
    bool? isGlobal,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/colors/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'warna': warna,
          if (isGlobal != null) 'is_global': isGlobal,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Color updated successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'errors': data['errors'] ?? {},
          'message': data['message'] ?? 'Validation failed',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update color',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete color
  static Future<Map<String, dynamic>> deleteColor(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/colors/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Color deleted successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete color',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
