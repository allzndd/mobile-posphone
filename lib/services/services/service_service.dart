import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/service.dart';

class ServiceService {
  static const String baseUrl = ApiConfig.baseUrl;
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getServices({
    int page = 1,
    int perPage = 20,
    String? search,
    int? posTokoId,
  }) async {
    try {
      final headers = await _getHeaders();
      
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.isNotEmpty) 'nama': search,
        if (posTokoId != null) 'pos_toko_id': posTokoId.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/api/services').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 401) {
        // Token expired, user needs to login again
        throw Exception('Token tidak valid. Silakan login ulang.');
      }
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': data['success'] ?? false,
          'data': data['data'] ?? [],
          'pagination': data['pagination'],
          'message': data['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'data': [],
          'message': data['message'] ?? 'Failed to load services',
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

  static Future<Map<String, dynamic>> getService(int id) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/services/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 401) {
        // Token expired, user needs to login again
        throw Exception('Token tidak valid. Silakan login ulang.');
      }
      
      final data = json.decode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'data': data['data'],
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> createService(Service service) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/services'),
        headers: headers,
        body: json.encode(service.toJson()),
      );
      
      if (response.statusCode == 401) {
        // Token expired, user needs to login again
        throw Exception('Token tidak valid. Silakan login ulang.');
      }
      
      final data = json.decode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'data': data['data'],
        'message': data['message'] ?? '',
        'errors': data['errors'],
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateService(Service service) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/services/${service.id}'),
        headers: headers,
        body: json.encode(service.toJson()),
      );
      
      if (response.statusCode == 401) {
        // Token expired, user needs to login again
        throw Exception('Token tidak valid. Silakan login ulang.');
      }
      
      final data = json.decode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'data': data['data'],
        'message': data['message'] ?? '',
        'errors': data['errors'],
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteService(int id) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/services/$id'),
        headers: headers,
      );
      
      if (response.statusCode == 401) {
        // Token expired, user needs to login again
        throw Exception('Token tidak valid. Silakan login ulang.');
      }
      
      final data = json.decode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}