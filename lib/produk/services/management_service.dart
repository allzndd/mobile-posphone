import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class StockService {
  // Headers untuk HTTP requests dengan authentication
  static Future<Map<String, String>> get _headers async {
    final token = await AuthService.getToken();
    
    if (token != null) {
      return ApiConfig.authHeaders(token);
    }
    return ApiConfig.defaultHeaders;
  }

  /// Get stock data with pagination and filters
  static Future<Map<String, dynamic>> getStocks({
    int page = 1,
    int perPage = 10,
    int? posTokoId,
    String? search,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (posTokoId != null) {
        queryParams['pos_toko_id'] = posTokoId.toString();
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.stockManagementEndpoint)).replace(
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
          'message': error['message'] ?? 'Failed to get stocks',
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

  /// Get stock summary statistics
  static Future<Map<String, dynamic>> getStockSummary() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stockManagementEndpoint)}/summary'),
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
          'message': error['message'] ?? 'Failed to get stock summary',
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

  /// Update stock quantity
  static Future<Map<String, dynamic>> updateStock({
    required int id,
    required int stok,
    required String tipe,
    String? keterangan,
  }) async {
    try {
      final body = {
        'stok': stok,
        'tipe': tipe,
        'keterangan': keterangan,
      };

      final response = await http.put(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stockManagementEndpoint)}/$id'),
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
          'message': error['message'] ?? 'Failed to update stock',
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

  /// Adjust stock (add or remove)
  static Future<Map<String, dynamic>> adjustStock({
    required int posProdukId,
    required int posTokoId,
    required int jumlah,
    required String tipe, // 'masuk', 'keluar', 'adjustment'
    String? referensi,
    String? keterangan,
  }) async {
    try {
      final body = {
        'pos_produk_id': posProdukId,
        'pos_toko_id': posTokoId,
        'jumlah': jumlah,
        'tipe': tipe,
        'referensi': referensi,
        'keterangan': keterangan,
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stockManagementEndpoint)}/adjust'),
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
          'message': error['message'] ?? 'Failed to adjust stock',
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

  /// Get stock history logs
  static Future<Map<String, dynamic>> getStockHistory({
    int page = 1,
    int perPage = 10,
    int? posProdukId,
    int? posTokoId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (posProdukId != null) {
        queryParams['pos_produk_id'] = posProdukId.toString();
      }

      if (posTokoId != null) {
        queryParams['pos_toko_id'] = posTokoId.toString();
      }

      if (startDate != null) {
        queryParams['start_date'] = startDate;
      }

      if (endDate != null) {
        queryParams['end_date'] = endDate;
      }

      final uri = Uri.parse(ApiConfig.getUrl(ApiConfig.stockHistoryEndpoint)).replace(
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
          'message': error['message'] ?? 'Failed to get stock history',
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

  /// Get stock history summary
  static Future<Map<String, dynamic>> getStockHistorySummary() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.stockHistoryEndpoint)}/summary'),
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
          'message': error['message'] ?? 'Failed to get stock history summary',
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
}