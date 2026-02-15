import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class BrandService {
  // Headers untuk HTTP requests dengan authentication
  static Future<Map<String, String>> get _headers async {
    final token = await AuthService.getToken();
    
    if (token != null) {
      return ApiConfig.authHeaders(token);
    }
    return ApiConfig.defaultHeaders;
  }

  /// Get list of brands with pagination and search
  static Future<Map<String, dynamic>> getBrands({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['merk'] = search;
      }

      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.productBrandsEndpoint)).replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'pagination': data['pagination'],
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to get brands',
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  /// Get single brand details
  static Future<Map<String, dynamic>> getBrand(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.productBrandsEndpoint)}/$id'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to get brand details',
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  /// Create new brand
  static Future<Map<String, dynamic>> createBrand({
    required String merk,
    String? nama,
  }) async {
    try {
      final body = {
        'merk': merk,
        if (nama != null && nama.isNotEmpty) 'nama': nama,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.productBrandsEndpoint)),
        headers: await _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to create brand',
          'errors': error['errors'],
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  /// Update existing brand
  static Future<Map<String, dynamic>> updateBrand({
    required int id,
    required String merk,
    String? nama,
  }) async {
    try {
      final body = {
        'merk': merk,
        if (nama != null && nama.isNotEmpty) 'nama': nama,
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.productBrandsEndpoint)}/$id'),
        headers: await _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to update brand',
          'errors': error['errors'],
          'data': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  /// Delete brand
  static Future<Map<String, dynamic>> deleteBrand(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.productBrandsEndpoint)}/$id'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to delete brand',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  /// Check if brand can be deleted (has no products)
  static Future<bool> canDeleteBrand(int id) async {
    try {
      final brandData = await getBrand(id);
      if (brandData['success'] == true) {
        final brand = brandData['data'];
        final productCount = brand['produk_count'] ?? 0;
        return productCount == 0;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get brands for dropdown (simplified data)
  static Future<List<Map<String, dynamic>>> getBrandsForDropdown() async {
    try {
      final response = await getBrands(perPage: 100); // Get more brands for dropdown
      if (response['success'] == true) {
        final brands = response['data'] as List<dynamic>;
        return brands.map((brand) => {
          'id': brand['id'],
          'merk': brand['merk'] ?? brand['nama'], // Fallback to nama for compatibility
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}