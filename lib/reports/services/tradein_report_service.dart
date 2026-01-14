import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class TradeInReportService {
  /// Get Trade-In Summary
  static Future<Map<String, dynamic>> getTradeInSummary({
    required DateTime startDate,
    required DateTime endDate,
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

      final url =
          '${ApiConfig.baseUrl}/api/reports/trade-in?start_date=${_formatDate(startDate)}&end_date=${_formatDate(endDate)}&per_page=100${storeId != null && storeId != 'All Stores' ? '&pos_toko_id=$storeId' : ''}';

      print('🌐 Trade-In API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Trade-In Summary API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Calculate summary from trade-ins
        final tradeIns = data['data'] ?? [];
        int totalTradeIns = tradeIns.length;
        double totalTradeInValue = 0;
        double totalNewValue = 0;
        int totalProducts = 0;

        for (var tradeIn in tradeIns) {
          // Calculate trade-in value from produkMasuk
          final produkMasuk = tradeIn['produk_masuk'];
          if (produkMasuk != null) {
            final harga = produkMasuk['harga'];
            if (harga != null) {
              totalTradeInValue += double.parse(harga.toString());
            }
            totalProducts++;
          }

          // Calculate new value from transaction
          final transaksi = tradeIn['transaksi'];
          if (transaksi != null && transaksi is List && transaksi.isNotEmpty) {
            final firstTransaction = transaksi[0];
            final totalHarga = firstTransaction['total_harga'];
            if (totalHarga != null) {
              totalNewValue += double.parse(totalHarga.toString());
            }
          }
        }

        final averageTradeInValue =
            totalTradeIns > 0 ? totalTradeInValue / totalTradeIns : 0;

        return {
          'success': true,
          'data': {
            'total_trade_ins': totalTradeIns,
            'total_trade_in_value': totalTradeInValue,
            'total_new_value': totalNewValue,
            'average_trade_in_value': averageTradeInValue,
            'total_products': totalProducts,
          },
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load trade-in summary: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getTradeInSummary: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Trade-In Transactions
  static Future<Map<String, dynamic>> getTradeInTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int page = 1,
    int perPage = 20,
    String? search,
    String? storeId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      var url =
          '${ApiConfig.baseUrl}/api/reports/trade-in?start_date=${_formatDate(startDate)}&end_date=${_formatDate(endDate)}&per_page=$perPage&page=$page';

      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      if (storeId != null && storeId != 'All Stores') {
        url += '&pos_toko_id=$storeId';
      }

      print('📡 Trade-In Transactions API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Trade-In Transactions API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'success': true,
          'data': data['data'] ?? [],
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load trade-ins: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getTradeInTransactions: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Export Trade-In Report (Excel)
  static Future<Map<String, dynamic>> exportTradeInReport({
    required DateTime startDate,
    required DateTime endDate,
    required String period,
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

      if (storeId != null && storeId != 'all') {
        queryParams['pos_toko_id'] = storeId;
      }

      final url =
          Uri.parse('${ApiConfig.baseUrl}/api/reports/trade-in/export')
              .replace(queryParameters: queryParams);

      print('📥 Downloading Trade-In Excel from: $url');

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
              'trade_in_report_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.xlsx';
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
      print('❌ Error in exportTradeInReport: $e');
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
        Uri.parse('${ApiConfig.baseUrl}/api/reports/trade-in/stores'),
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
