import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class StockReportService {
  /// Get Stock Summary
  static Future<Map<String, dynamic>> getStockSummary({
    String? storeId,
    String? stockFilter,
  }) async {
    try {
      final token = await AuthService.getToken();

      print(
        '🔐 Token: ${token != null ? "Found (${token.substring(0, 20)}...)" : "Not Found"}',
      );

      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      var url = '${ApiConfig.baseUrl}/api/reports/stock?per_page=1000';
      
      if (storeId != null && storeId != 'All Stores') {
        url += '&pos_toko_id=$storeId';
      }

      if (stockFilter != null && stockFilter != 'All') {
        if (stockFilter == 'Low Stock') {
          url += '&stock_filter=low_stock';
        } else if (stockFilter == 'Out of Stock') {
          url += '&stock_filter=out_of_stock';
        }
      }

      print('🌐 API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Summary API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Calculate summary from stock data
        final stocks = data['data'] ?? [];
        int totalProducts = stocks.length;
        int totalStock = 0;
        int lowStockCount = 0;
        int outOfStockCount = 0;
        double totalValue = 0;

        for (var stock in stocks) {
          final stokValue = stock['stok'];
          final stok = stokValue is String 
              ? (int.tryParse(stokValue) ?? 0)
              : (stokValue is num ? stokValue.toInt() : 0);
          
          totalStock += stok;
          
          if (stok == 0) {
            outOfStockCount++;
          } else if (stok <= 5) {
            lowStockCount++;
          }

          // Calculate total value (stock * price)
          final hargaValue = stock['produk']?['harga_jual'] ?? 0;
          final harga = hargaValue is String 
              ? (double.tryParse(hargaValue) ?? 0)
              : (hargaValue is num ? hargaValue.toDouble() : 0);
          
          totalValue += stok * harga;
        }

        return {
          'success': true,
          'data': {
            'total_products': totalProducts,
            'total_stock': totalStock,
            'low_stock_count': lowStockCount,
            'out_of_stock_count': outOfStockCount,
            'total_value': totalValue,
          },
        };
      } else if (response.statusCode == 401) {
        print('❌ 401 Unauthorized - Token invalid or expired');
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load stock summary: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getStockSummary: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Stock Items with pagination
  static Future<Map<String, dynamic>> getStockItems({
    int page = 1,
    int perPage = 20,
    String? search,
    String? storeId,
    String? stockFilter,
    String? category,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      var url =
          '${ApiConfig.baseUrl}/api/reports/stock?per_page=$perPage&page=$page';

      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      if (storeId != null && storeId != 'All Stores') {
        url += '&pos_toko_id=$storeId';
      }

      if (stockFilter != null && stockFilter != 'All') {
        if (stockFilter == 'Low Stock') {
          url += '&stock_filter=low_stock';
        } else if (stockFilter == 'Out of Stock') {
          url += '&stock_filter=out_of_stock';
        }
      }

      if (category != null && category != 'All Categories') {
        url += '&category=$category';
      }

      print('📡 Stock Items API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Stock Items API Response: ${response.statusCode}');
      print('📦 Stock Items API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Transform data to match expected format
        final stockItems = (data['data'] ?? []).map((item) {
          // Parse stock value
          final stokValue = item['stok'];
          final stok = stokValue is String 
              ? (int.tryParse(stokValue) ?? 0)
              : (stokValue is num ? stokValue.toInt() : 0);
          
          // Parse price value
          final hargaValue = item['produk']?['harga_jual'] ?? 0;
          final harga = hargaValue is String 
              ? (double.tryParse(hargaValue) ?? 0)
              : (hargaValue is num ? hargaValue.toDouble() : 0);
          
          return {
            'id': item['id'],
            'product': {
              'id': item['produk']?['id'],
              'name': item['produk']?['nama'] ?? '-',
              'sku': item['produk']?['imei'] ?? '-',  // Using IMEI as SKU
              'category': item['produk']?['kategori'] ?? '-',
              'brand': item['produk']?['merk'] ?? '-',
              'price': harga,
            },
            'store': {
              'id': item['toko']?['id'],
              'name': item['toko']?['nama'] ?? '-',
            },
            'stock': stok,
            'min_stock': item['min_stok'] ?? 5,
            'value': stok * harga,
            'status': _getStockStatus(stok),
          };
        }).toList();

        return {
          'success': true,
          'data': stockItems,
          'pagination': data['pagination'],
        };
      } else if (response.statusCode == 500) {
        final data = json.decode(response.body);
        print('❌ 500 Server Error: ${data['message']}');
        if (data['error'] != null) {
          print('❌ Error Detail: ${data['error']}');
        }
        return {
          'success': false,
          'message': 'Server error: ${data['message'] ?? 'Unknown error'}',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load stock items: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getStockItems: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Stock by Category
  static Future<Map<String, dynamic>> getStockByCategory({
    String? storeId,
    String? stockFilter,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      var url = '${ApiConfig.baseUrl}/api/reports/stock?per_page=1000';

      if (storeId != null && storeId != 'All Stores') {
        url += '&pos_toko_id=$storeId';
      }

      if (stockFilter != null && stockFilter != 'All') {
        if (stockFilter == 'Low Stock') {
          url += '&stock_filter=low_stock';
        } else if (stockFilter == 'Out of Stock') {
          url += '&stock_filter=out_of_stock';
        }
      }

      print('📡 Stock By Category API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Stock By Category API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stocks = data['data'] ?? [];

        // Group by category
        Map<String, Map<String, dynamic>> categoryMap = {};

        for (var stock in stocks) {
          final category = stock['produk']?['kategori'] ?? 'Uncategorized';
          final stokValue = stock['stok'] ?? 0;
          final stok = stokValue is String 
              ? (int.tryParse(stokValue) ?? 0)
              : (stokValue is num ? stokValue.toInt() : 0);
          
          final hargaValue = stock['produk']?['harga_jual'] ?? 0;
          final harga = hargaValue is String 
              ? (double.tryParse(hargaValue) ?? 0)
              : (hargaValue is num ? hargaValue.toDouble() : 0);

          if (!categoryMap.containsKey(category)) {
            categoryMap[category] = {
              'category': category,
              'total_items': 0,
              'total_stock': 0,
              'total_value': 0.0,
            };
          }

          categoryMap[category]!['total_items'] = 
              (categoryMap[category]!['total_items'] as int) + 1;
          categoryMap[category]!['total_stock'] = 
              (categoryMap[category]!['total_stock'] as int) + stok;
          categoryMap[category]!['total_value'] = 
              (categoryMap[category]!['total_value'] as double) + (stok * harga);
        }

        final categories = categoryMap.values.toList();
        categories.sort((a, b) => 
            (b['total_value'] as double).compareTo(a['total_value'] as double));

        return {
          'success': true,
          'data': categories,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load categories: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getStockByCategory: $e');
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

      final url = '${ApiConfig.baseUrl}/api/stores';
      print('📡 Stores API URL: $url');

      final response = await http.get(
        Uri.parse(url),
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

  /// Export Stock Report to Excel
  static Future<Map<String, dynamic>> exportStockReport({
    String? search,
    String? storeId,
    String? stockFilter,
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

      if (storeId != null && storeId != 'all') {
        queryParams['pos_toko_id'] = storeId;
      }

      if (stockFilter != null && stockFilter != 'All') {
        if (stockFilter == 'Low Stock') {
          queryParams['stock_filter'] = 'low_stock';
        } else if (stockFilter == 'Out of Stock') {
          queryParams['stock_filter'] = 'out_of_stock';
        }
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/reports/stock/export')
          .replace(queryParameters: queryParams);

      print('📥 Downloading Excel from: $url');

      final response = await http.get(
        url,
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Export Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Get downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          // Try to get external storage directory first
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Navigate to Downloads directory
            final downloadsPath = '/storage/emulated/0/Download';
            directory = Directory(downloadsPath);
            
            // Create directory if it doesn't exist
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          final fileName =
              'stock_report_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.xlsx';
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
      print('❌ Error in exportStockReport: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static String _getStockStatus(int stock) {
    if (stock == 0) {
      return 'out_of_stock';
    } else if (stock <= 5) {
      return 'low_stock';
    } else if (stock <= 20) {
      return 'medium_stock';
    } else {
      return 'high_stock';
    }
  }

  static String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
