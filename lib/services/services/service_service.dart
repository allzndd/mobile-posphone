import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../../component/error_handler.dart';
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

  // ============================================================================
  // WRAPPER METHODS WITH BUILT-IN ERROR HANDLING
  // ============================================================================
  // Contoh implementasi yang sudah include error handling otomatis
  // Gunakan method-method ini untuk mendapatkan error handling otomatis
  
  /// Get services dengan error handling otomatis
  /// Context diperlukan untuk menampilkan error page/dialog
  static Future<Map<String, dynamic>> getServicesWithErrorHandling(
    BuildContext context, {
    int page = 1,
    int perPage = 20,
    String? search,
    int? posTokoId,
    VoidCallback? onRetry,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      // Handle missing token
      if (token == null) {
        ErrorHandler.handleApiError(
          context,
          statusCode: 401,
          errorMessage: 'Sesi Anda telah berakhir. Silakan login kembali.',
          onGoBack: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        );
        return {'success': false, 'message': 'No token'};
      }

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.isNotEmpty) 'nama': search,
        if (posTokoId != null) 'pos_toko_id': posTokoId.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/api/services').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      // Handle successful response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
          'pagination': data['pagination'],
          'message': data['message'] ?? '',
        };
      }
      
      // Handle specific error codes
      if (response.statusCode == 503) {
        // Maintenance mode
        ErrorHandler.handleApiError(
          context,
          statusCode: 503,
          errorMessage: 'Sistem sedang dalam maintenance. Silakan coba lagi nanti.',
          onRetry: onRetry,
        );
        return {'success': false, 'message': 'Service maintenance'};
      } else if (response.statusCode == 401) {
        // Unauthorized - redirect to login
        ErrorHandler.handleApiError(
          context,
          statusCode: 401,
          errorMessage: 'Sesi Anda telah berakhir. Silakan login kembali.',
          onGoBack: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        );
        return {'success': false, 'message': 'Unauthorized'};
      } else {
        // Other API errors
        final errorData = ErrorHandler.parseApiError(json.decode(response.body));
        ErrorHandler.handleApiError(
          context,
          statusCode: errorData['statusCode'],
          errorMessage: errorData['message'],
          onRetry: onRetry,
        );
        return {'success': false, 'message': errorData['message']};
      }
    } catch (e) {
      // Handle network errors
      if (ErrorHandler.isNetworkError(e.toString())) {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Koneksi Bermasalah',
          message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          onRetry: onRetry,
        );
      } else {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Error',
          message: 'Terjadi kesalahan: ${e.toString()}',
          onRetry: onRetry,
        );
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Create service dengan error handling otomatis
  static Future<Map<String, dynamic>> createServiceWithErrorHandling(
    BuildContext context,
    Service service, {
    VoidCallback? onRetry,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Authentication Error',
          message: 'Silakan login terlebih dahulu',
        );
        return {'success': false, 'message': 'No token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/services'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(service.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Service berhasil ditambahkan',
        };
      } else if (response.statusCode == 422) {
        // Validation error
        final data = json.decode(response.body);
        ErrorHandler.showErrorDialog(
          context,
          title: 'Validasi Gagal',
          message: data['message'] ?? 'Periksa kembali data yang Anda masukkan',
        );
        return {
          'success': false,
          'message': data['message'],
          'errors': data['errors'],
        };
      } else if (response.statusCode == 401) {
        ErrorHandler.handleApiError(
          context,
          statusCode: 401,
          onGoBack: () => Navigator.pushReplacementNamed(context, '/login'),
        );
        return {'success': false, 'message': 'Unauthorized'};
      } else {
        final errorData = ErrorHandler.parseApiError(json.decode(response.body));
        ErrorHandler.showErrorDialog(
          context,
          title: 'Gagal Menyimpan',
          message: errorData['message'],
          onRetry: onRetry,
        );
        return {'success': false, 'message': errorData['message']};
      }
    } catch (e) {
      if (ErrorHandler.isNetworkError(e.toString())) {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Koneksi Bermasalah',
          message: 'Tidak dapat terhubung ke server',
          onRetry: onRetry,
        );
      } else {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Error',
          message: e.toString(),
          onRetry: onRetry,
        );
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Delete service dengan error handling otomatis
  static Future<Map<String, dynamic>> deleteServiceWithErrorHandling(
    BuildContext context,
    int id, {
    VoidCallback? onRetry,
  }) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Authentication Error',
          message: 'Silakan login terlebih dahulu',
        );
        return {'success': false, 'message': 'No token'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/services/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Service berhasil dihapus',
        };
      } else if (response.statusCode == 401) {
        ErrorHandler.handleApiError(
          context,
          statusCode: 401,
          onGoBack: () => Navigator.pushReplacementNamed(context, '/login'),
        );
        return {'success': false, 'message': 'Unauthorized'};
      } else if (response.statusCode == 404) {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Data Tidak Ditemukan',
          message: 'Service yang akan dihapus tidak ditemukan',
        );
        return {'success': false, 'message': 'Not found'};
      } else {
        final errorData = ErrorHandler.parseApiError(json.decode(response.body));
        ErrorHandler.showErrorDialog(
          context,
          title: 'Gagal Menghapus',
          message: errorData['message'],
          onRetry: onRetry,
        );
        return {'success': false, 'message': errorData['message']};
      }
    } catch (e) {
      if (ErrorHandler.isNetworkError(e.toString())) {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Koneksi Bermasalah',
          message: 'Tidak dapat terhubung ke server',
          onRetry: onRetry,
        );
      } else {
        ErrorHandler.showErrorDialog(
          context,
          title: 'Error',
          message: e.toString(),
          onRetry: onRetry,
        );
      }
      return {'success': false, 'message': e.toString()};
    }
  }
}