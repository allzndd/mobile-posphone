import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class StockHistoryService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get stock history with filtering and pagination
  static Future<Map<String, dynamic>> getStockHistory({
    int page = 1,
    int perPage = 50,
    String? search,
    String? storeId,
    String? type,
    String? startDate,
    String? endDate,
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
      if (storeId != null && storeId != 'All') {
        queryParams['store_id'] = storeId;
      }
      if (type != null && type != 'All') {
        queryParams['type'] = type;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final uri = Uri.parse('$baseUrl/api/stock-history')
          .replace(queryParameters: queryParams);

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
          'message': 'Stock history loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': responseBody['message'] ?? 'Failed to load stock history',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': [],
        'message': 'Error: $e',
      };
    }
  }

  /// Get stock history summary
  static Future<Map<String, dynamic>> getStockHistorySummary({
    String? storeId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
          'data': {},
        };
      }

      Map<String, String> queryParams = {};

      if (storeId != null && storeId != 'All') {
        queryParams['store_id'] = storeId;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final uri = Uri.parse('$baseUrl/api/stock-history/summary')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': 'Summary loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to load summary',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Error: $e',
      };
    }
  }

  /// Get all stores for filter dropdown
  static Future<Map<String, dynamic>> getStores() async {
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

      // Use stores API endpoint  
      final response = await http.get(
        Uri.parse('$baseUrl/api/stores'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
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
      return {
        'success': false,
        'data': [],
        'message': 'Error: $e',
      };
    }
  }

  /// Get stock history detail by ID
  static Future<Map<String, dynamic>> getStockHistoryDetail(int id) async {
    try {
      // Get authentication token
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
          'data': null,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/stock-history/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': 'Stock history detail loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to load stock history detail',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Error: $e',
      };
    }
  }
}