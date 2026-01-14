import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class TradeInService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get all trade-ins with filtering and pagination
  static Future<Map<String, dynamic>> getTradeIns({
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
        '$baseUrl/api/trade-in',
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
          'message': 'Trade-in data loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': responseBody['message'] ?? 'Failed to load trade-in data',
        };
      }
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'Error: $e'};
    }
  }

  /// Get trade-in by ID
  static Future<Map<String, dynamic>> getTradeIn(int id) async {
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
        Uri.parse('$baseUrl/api/trade-in/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': 'Trade-in loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to load trade-in',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Create new trade-in
  static Future<Map<String, dynamic>> createTradeIn(
    Map<String, dynamic> data,
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
        Uri.parse('$baseUrl/api/trade-in'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(data),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': responseBody['message'] ?? 'Trade-in created successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to create trade-in',
          'errors': responseBody['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Update trade-in
  static Future<Map<String, dynamic>> updateTradeIn(
    int id,
    Map<String, dynamic> data,
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
        Uri.parse('$baseUrl/api/trade-in/$id'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(data),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': responseBody['message'] ?? 'Trade-in updated successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to update trade-in',
          'errors': responseBody['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Delete trade-in
  static Future<Map<String, dynamic>> deleteTradeIn(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/trade-in/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Trade-in deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to delete trade-in',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
