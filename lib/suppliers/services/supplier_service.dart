import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class SupplierService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get all suppliers with filtering and pagination
  static Future<Map<String, dynamic>> getSuppliers({
    int page = 1,
    int perPage = 20,
    String? nama,
    String? nomorHp,
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

      if (nama != null && nama.isNotEmpty) {
        queryParams['nama'] = nama;
      }

      if (nomorHp != null && nomorHp.isNotEmpty) {
        queryParams['nomor_hp'] = nomorHp;
      }

      final uri = Uri.parse(
        '$baseUrl/api/suppliers',
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
          'pagination': responseBody['pagination'],
          'message': 'Suppliers loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': responseBody['message'] ?? 'Failed to load suppliers',
        };
      }
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'Error: $e'};
    }
  }

  /// Get supplier by ID
  static Future<Map<String, dynamic>> getSupplier(int id) async {
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
        Uri.parse('$baseUrl/api/suppliers/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': 'Supplier loaded successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to load supplier',
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Create new supplier
  static Future<Map<String, dynamic>> createSupplier(
    Map<String, dynamic> supplierData,
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
        Uri.parse('$baseUrl/api/suppliers'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(supplierData),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': responseBody['message'] ?? 'Supplier created successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to create supplier',
          'errors': responseBody['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Update supplier
  static Future<Map<String, dynamic>> updateSupplier(
    int id,
    Map<String, dynamic> supplierData,
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
        Uri.parse('$baseUrl/api/suppliers/$id'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(supplierData),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
          'message': responseBody['message'] ?? 'Supplier updated successfully',
        };
      } else {
        return {
          'success': false,
          'data': null,
          'message': responseBody['message'] ?? 'Failed to update supplier',
          'errors': responseBody['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'data': null, 'message': 'Error: $e'};
    }
  }

  /// Delete supplier
  static Future<Map<String, dynamic>> deleteSupplier(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/suppliers/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Supplier deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to delete supplier',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
