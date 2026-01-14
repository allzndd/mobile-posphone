import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class ProductReportService {
  /// Get Product Summary
  static Future<Map<String, dynamic>> getProductSummary({
    String? search,
    String? stockStatus,
    String? storeId,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      var url = '${ApiConfig.baseUrl}/api/reports/products/summary';

      final params = <String, String>{};

      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      if (stockStatus != null && stockStatus != 'Semua') {
        params['stock_status'] = stockStatus.toLowerCase().replaceAll(' ', '_');
      }

      if (storeId != null && storeId != 'all') {
        params['pos_toko_id'] = storeId;
      }

      if (params.isNotEmpty) {
        url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      print('🌐 Product Summary API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Product Summary API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Backend now returns summary directly
        if (data['success'] == true && data['data'] != null) {
          return {
            'success': true,
            'data': data['data'], // Use backend calculated summary
          };
        }

        return {
          'success': false,
          'message': 'Invalid response format',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load product summary: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getProductSummary: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Products with Pagination
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    String? stockStatus,
    String? storeId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      var url =
          '${ApiConfig.baseUrl}/api/reports/products?per_page=$perPage&page=$page';

      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      if (stockStatus != null && stockStatus != 'Semua') {
        url += '&stock_status=${stockStatus.toLowerCase().replaceAll(' ', '_')}';
      }

      if (storeId != null && storeId != 'all') {
        url += '&pos_toko_id=$storeId';
      }

      print('📡 Products API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Products API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Process products to add total_stok
        final products = data['data'] ?? [];
        for (var product in products) {
          int totalStok = 0;
          final stokList = product['stok'] ?? [];
          for (var stok in stokList) {
            final stokValue = stok['stok'];
            if (stokValue != null) {
              totalStok += int.parse(stokValue.toString());
            }
          }
          product['total_stok'] = totalStok;
        }

        return {
          'success': true,
          'data': products,
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load products: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getProducts: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Export Product Report (Excel)
  static Future<Map<String, dynamic>> exportProductReport({
    String? search,
    String? stockStatus,
    String? storeId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      final queryParams = <String, String>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (stockStatus != null && stockStatus != 'Semua') {
        queryParams['stock_status'] = stockStatus.toLowerCase().replaceAll(' ', '_');
      }

      if (storeId != null && storeId != 'all') {
        queryParams['pos_toko_id'] = storeId;
      }

      final url =
          Uri.parse('${ApiConfig.baseUrl}/api/reports/products/export')
              .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print('📥 Downloading Product Excel from: $url');

      final response = await http.get(
        url,
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Export Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Get downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            final downloadsPath = '/storage/emulated/0/Download';
            directory = Directory(downloadsPath);

            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          final fileName =
              'product_report_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.xlsx';
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);

          await file.writeAsBytes(response.bodyBytes);

          print('✅ File saved to: $filePath');

          return {
            'success': true,
            'message': 'File saved to Downloads',
            'path': filePath,
          };
        } else {
          return {
            'success': false,
            'message': 'Failed to get storage directory'
          };
        }
      } else {
        final errorBody = response.body;
        print('❌ Export failed: $errorBody');
        return {
          'success': false,
          'message': 'Failed to export report: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ Error in exportProductReport: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Stores
  static Future<Map<String, dynamic>> getStores() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/reports/products/stores'),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Stores API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load stores: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getStores: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
