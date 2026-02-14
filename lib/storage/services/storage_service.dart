import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/storage.dart';
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class StorageService {

  // Get all storages with pagination
  static Future<Map<String, dynamic>> getStorages({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
          'data': [],
        };
      }

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri =
          Uri.parse('${ApiConfig.baseUrl}/api/storages')
              .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'message': data['message'] ?? 'Success',
          'data': (data['data'] as List?)
              ?.map((item) {
                try {
                  return Storage.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing storage item: $e');
                  return null;
                }
              })
              .whereType<Storage>()
              .toList() ?? [],
          'total': (data['total'] as int?) ?? 0,
          'per_page': (data['per_page'] as int?) ?? 10,
          'current_page': (data['current_page'] as int?) ?? 1,
          'last_page': (data['last_page'] as int?) ?? 1,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch storages (${response.statusCode})',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'data': [],
      };
    }
  }

  // Get single storage by ID
  static Future<Map<String, dynamic>> getStorageById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
          'data': null,
        };
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/storages/$id');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'message': data['message'] ?? 'Success',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch storage (${response.statusCode})',
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'data': null,
      };
    }
  }

  // Create new storage
  static Future<Map<String, dynamic>> createStorage({
    required int idOwner,
    int? posProdukId,
    required String kapasitas,
    String? idGlobal,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
          'data': null,
          'errors': null,
        };
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/storages');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_owner': idOwner,
          'pos_produk_id': posProdukId,
          'kapasitas': kapasitas,
          'id_global': idGlobal,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': data['success'] == true,
          'message': data['message'] ?? 'Storage created successfully',
          'data': data['data'] != null
              ? Storage.fromJson(data['data'] as Map<String, dynamic>)
              : null,
          'errors': data['errors'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create storage',
          'data': null,
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'data': null,
      };
    }
  }

  // Update storage
  static Future<Map<String, dynamic>> updateStorage({
    required int id,
    required int idOwner,
    int? posProdukId,
    required String kapasitas,
    String? idGlobal,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
          'data': null,
          'errors': null,
        };
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/storages/$id');

      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_owner': idOwner,
          'pos_produk_id': posProdukId,
          'kapasitas': kapasitas,
          'id_global': idGlobal,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': data['success'] == true,
          'message': data['message'] ?? 'Storage updated successfully',
          'data': data['data'] != null
              ? Storage.fromJson(data['data'] as Map<String, dynamic>)
              : null,
          'errors': data['errors'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update storage',
          'data': null,
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'data': null,
      };
    }
  }

  // Delete storage
  static Future<Map<String, dynamic>> deleteStorage(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/storages/$id');

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'message': data['message'] ?? 'Storage deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete storage (${response.statusCode})',
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
