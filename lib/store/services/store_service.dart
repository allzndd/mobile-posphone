import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class StoreService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get all stores with filtering and pagination
  static Future<Map<String, dynamic>> getStores({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
          'data': [],
        };
      }

      // Build query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        '$baseUrl/api/stores',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'meta': responseBody['meta'],
          'message': 'Stores loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': responseBody['message'] ?? 'Failed to load stores',
        };
      }
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'Error: $e'};
    }
  }

  /// Get store by ID
  static Future<Map<String, dynamic>> getStore(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
          'data': null,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/stores/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': 'Store loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to load store',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Create new store
  static Future<Map<String, dynamic>> createStore(
    Map<String, dynamic> storeData,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
          'data': null,
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/stores'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(storeData),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': responseBody['message'] ?? 'Store created successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to create store',
          'errors': responseBody['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Update store
  static Future<Map<String, dynamic>> updateStore(
    int id,
    Map<String, dynamic> storeData,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
          'data': null,
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/stores/$id'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(storeData),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': responseBody['message'] ?? 'Store updated successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to update store',
          'errors': responseBody['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Delete store
  static Future<Map<String, dynamic>> deleteStore(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/stores/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Store deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to delete store',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
