import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class CustomerReportService {
  /// Get Customer Summary
  static Future<Map<String, dynamic>> getCustomerSummary({
    String? search,
    String? sortBy,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      var url = '${ApiConfig.baseUrl}/api/reports/customers/summary';

      print('📡 Customer Summary API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Summary API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'data': data['data'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to load summary',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to load customer summary: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getCustomerSummary: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get Customer Items with pagination
  static Future<Map<String, dynamic>> getCustomerItems({
    int page = 1,
    int perPage = 20,
    String? search,
    String? sortBy,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Token not found'};
      }

      var url =
          '${ApiConfig.baseUrl}/api/reports/customers?per_page=$perPage&page=$page';

      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }

      if (sortBy != null && sortBy.isNotEmpty) {
        url += '&sort_by=$sortBy';
      }

      print('📡 Customer Items API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Customer Items API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Transform data to match expected format
        final customerItems = (data['data'] ?? []).map((item) {
          return {
            'id': item['id'],
            'name': item['name'] ?? '-',
            'email': item['email'] ?? '-',
            'phone': item['phone'] ?? '-',
            'address': item['address'] ?? '-',
            'total_purchases': item['total_purchases'] ?? 0,
            'total_value': _parseValue(item['total_value']),
            'average_purchase': _parseValue(item['average_purchase']),
            'last_purchase_date': item['last_purchase_date'],
            'status': item['status'] ?? 'new',
            'created_at': item['created_at'],
          };
        }).toList();

        return {
          'success': true,
          'data': customerItems,
          'pagination': data['pagination'],
        };
      } else if (response.statusCode == 500) {
        final data = json.decode(response.body);
        print('❌ 500 Server Error: ${data['message']}');
        return {
          'success': false,
          'message': 'Server error: ${data['message'] ?? 'Unknown error'}',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load customer items: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in getCustomerItems: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Export Customer Report to Excel
  static Future<Map<String, dynamic>> exportCustomerReport({
    String? search,
    String? sortBy,
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

      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/reports/customers/export')
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
              'customer_report_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.xlsx';
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
      print('❌ Error in exportCustomerReport: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static double _parseValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
