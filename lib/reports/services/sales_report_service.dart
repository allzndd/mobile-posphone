import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class SalesReportService {
  /// Get Sales Summary
  static Future<Map<String, dynamic>> getSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? paymentMethod,
    String? storeId,
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

      final url =
          '${ApiConfig.baseUrl}/api/reports/sales?start_date=${_formatDate(startDate)}&end_date=${_formatDate(endDate)}&per_page=100${paymentMethod != null && paymentMethod != 'Semua' ? '&payment_method=${paymentMethod.toLowerCase()}' : ''}${storeId != null && storeId != 'All Stores' ? '&pos_toko_id=$storeId' : ''}';
      print('🌐 API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Summary API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Calculate summary from transactions
        final transactions = data['data'] ?? [];
        double totalSales = 0;
        int totalTransactions = transactions.length;
        int totalItemsSold = 0;

        for (var trx in transactions) {
          final totalHarga = trx['total_harga'];
          if (totalHarga != null) {
            totalSales += double.parse(totalHarga.toString());
          }
          
          // Calculate total items sold from transaction items
          final items = trx['items'] ?? [];
          for (var item in items) {
            final quantityValue = item['quantity'] ?? item['jumlah'] ?? 0;
            final quantity = quantityValue is String 
                ? (int.tryParse(quantityValue) ?? 0) 
                : (quantityValue is num ? quantityValue.toInt() : 0);
            totalItemsSold += quantity;
          }
        }

        final averageTransaction =
            totalTransactions > 0 ? totalSales / totalTransactions : 0;

        return {
          'success': true,
          'data': {
            'total_sales': totalSales,
            'total_transactions': totalTransactions,
            'total_items_sold': totalItemsSold,
            'average_transaction': averageTransaction,
            'total_profit': totalSales * 0.2, // Estimate 20% profit margin
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
          'message': 'Failed to load sales summary: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getSalesSummary: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Sales Transactions
  static Future<Map<String, dynamic>> getSalesTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int perPage = 20,
    String? search,
    String? paymentMethod,
    String? storeId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      var url =
          '${ApiConfig.baseUrl}/api/reports/sales?start_date=${_formatDate(startDate)}&end_date=${_formatDate(endDate)}&per_page=$perPage&page=$page';

      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      if (paymentMethod != null && paymentMethod != 'Semua') {
        url += '&payment_method=${paymentMethod.toLowerCase()}';
      }

      if (storeId != null && storeId != 'All Stores') {
        url += '&pos_toko_id=$storeId';
      }

      print('📡 Transactions API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Transactions API Response: ${response.statusCode}');
      print('📦 Transactions API Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Transform data to match expected format
        final transactions =
            (data['data'] ?? []).map((trx) {
              return {
                'invoice_number':
                    trx['invoice'] ??
                    trx['no_invoice'] ??
                    trx['invoice_number'],
                'customer': {
                  'name':
                      trx['pelanggan']?['nama'] ??
                      trx['customer']?['name'] ??
                      'Walk-in Customer',
                },
                'toko': trx['toko'],
                'total_price': trx['total_harga'] ?? trx['total_price'] ?? 0,
                'created_at': trx['created_at'],
                'payment': {
                  'payment_method':
                      trx['metode_pembayaran'] ??
                      trx['payment_method'] ??
                      'Cash',
                  'status':
                      trx['status_pembayaran'] ??
                      trx['payment_status'] ??
                      'paid',
                },
                'items': trx['items'] ?? [],
              };
            }).toList();

        return {
          'success': true,
          'data': transactions,
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load transactions: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getSalesTransactions: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Top Products
  static Future<Map<String, dynamic>> getTopProducts({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      // Get all transactions and calculate top products
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/reports/sales?start_date=${_formatDate(startDate)}&end_date=${_formatDate(endDate)}&per_page=100',
        ),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Top Products API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transactions = data['data'] ?? [];

        // Calculate top products from transaction items
        Map<String, Map<String, dynamic>> productMap = {};

        for (var trx in transactions) {
          final items = trx['items'] ?? [];
          for (var item in items) {
            final productName =
                item['produk']?['nama'] ?? item['product_name'] ?? 'Unknown';
            final quantity = (item['quantity'] ?? item['jumlah'] ?? 0).toInt();
            final priceStr =
                item['harga_satuan'] ?? item['harga'] ?? item['price'] ?? '0';
            final price = double.parse(priceStr.toString());
            final revenue = quantity * price;

            if (productMap.containsKey(productName)) {
              productMap[productName]!['total_quantity'] += quantity;
              productMap[productName]!['total_revenue'] += revenue;
            } else {
              productMap[productName] = {
                'product_name': productName,
                'total_quantity': quantity,
                'total_revenue': revenue,
              };
            }
          }
        }

        // Sort by revenue and take top N
        final topProducts =
            productMap.values.toList()..sort(
              (a, b) => (b['total_revenue'] as double).compareTo(
                a['total_revenue'] as double,
              ),
            );

        return {'success': true, 'data': topProducts.take(limit).toList()};
      } else {
        return {'success': false, 'message': 'Failed to load top products'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Sales by Payment Method
  static Future<Map<String, dynamic>> getSalesByPaymentMethod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/reports/sales?start_date=${_formatDate(startDate)}&end_date=${_formatDate(endDate)}&per_page=100',
        ),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Payment Methods API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final transactions = data['data'] ?? [];

        // Calculate totals by payment method
        Map<String, Map<String, dynamic>> paymentMap = {};

        for (var trx in transactions) {
          final paymentMethod =
              trx['metode_pembayaran'] ?? trx['payment_method'] ?? 'Cash';
          final totalHarga = trx['total_harga'] ?? trx['total_price'] ?? '0';
          final amount = double.parse(totalHarga.toString());

          if (paymentMap.containsKey(paymentMethod)) {
            paymentMap[paymentMethod]!['total_amount'] += amount;
            paymentMap[paymentMethod]!['transaction_count'] += 1;
          } else {
            paymentMap[paymentMethod] = {
              'payment_method': paymentMethod,
              'total_amount': amount,
              'transaction_count': 1,
            };
          }
        }

        return {'success': true, 'data': paymentMap.values.toList()};
      } else {
        return {
          'success': false,
          'message': 'Failed to load payment methods: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getSalesByPaymentMethod: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Export Sales Report (Excel)
  static Future<Map<String, dynamic>> exportSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String period,
    String? paymentMethod,
    String? storeId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      final queryParams = {
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(endDate),
        'period': period,
      };

      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        queryParams['payment_method'] = paymentMethod.toLowerCase();
      }

      if (storeId != null && storeId != 'all') {
        queryParams['pos_toko_id'] = storeId;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/reports/sales/export')
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
              'sales_report_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.xlsx';
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
      print('❌ Error in exportSalesReport: $e');
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
        Uri.parse('${ApiConfig.baseUrl}/api/reports/stores'),
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

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
