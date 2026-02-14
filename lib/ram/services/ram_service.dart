import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class RamService {
  /// Get all rams with pagination and search
  static Future<Map<String, dynamic>> getRams({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ [RAM SERVICE] Token not found');
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
          Uri.parse('${ApiConfig.baseUrl}/api/rams')
              .replace(queryParameters: queryParams);

      print('🔍 [RAM SERVICE] Request URL: $uri');
      print('🔑 [RAM SERVICE] Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📊 [RAM SERVICE] Status Code: ${response.statusCode}');
      print('📦 [RAM SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [RAM SERVICE] Success - Total items: ${data['total']}');
        return {
          'success': true,
          'data': data['data'] ?? [],
          'total': data['total'] ?? 0,
          'current_page': data['current_page'] ?? 1,
          'last_page': data['last_page'] ?? 1,
          'per_page': data['per_page'] ?? perPage,
          'message': 'Rams loaded successfully',
        };
      } else if (response.statusCode == 401) {
        print('⚠️ [RAM SERVICE] Unauthorized - logging out');
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        print('❌ [RAM SERVICE] Error response: ${response.body}');
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load rams',
        };
      }
    } catch (e, stackTrace) {
      print('❌ [RAM SERVICE] Exception caught: $e');
      print('📍 [RAM SERVICE] Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get ram by ID
  static Future<Map<String, dynamic>> getRamById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/rams/$id'),
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
          'message': 'Ram loaded successfully',
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
          'message': 'Ram not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Create new ram
  static Future<Map<String, dynamic>> createRam({
    required String kapasitas,
    int? posProdukId,
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
        Uri.parse('${ApiConfig.baseUrl}/api/rams'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'kapasitas': kapasitas,
          if (posProdukId != null) 'pos_produk_id': posProdukId,
          'is_global': isGlobal,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Ram created successfully',
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
          'message': data['message'] ?? 'Failed to create ram',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update ram
  static Future<Map<String, dynamic>> updateRam({
    required int id,
    required String kapasitas,
    int? posProdukId,
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
        Uri.parse('${ApiConfig.baseUrl}/api/rams/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'kapasitas': kapasitas,
          if (posProdukId != null) 'pos_produk_id': posProdukId,
          if (isGlobal != null) 'is_global': isGlobal,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Ram updated successfully',
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
          'message': data['message'] ?? 'Failed to update ram',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete ram
  static Future<Map<String, dynamic>> deleteRam(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/rams/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Ram deleted successfully',
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
          'message': data['message'] ?? 'Failed to delete ram',
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
