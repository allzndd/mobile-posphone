import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class FinancialReportService {
  static Future<Map<String, dynamic>> getFinancialSummary({
    String period = 'month',
    String? startDate,
    String? endDate,
    String? type,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No token available');
        return {'success': false, 'message': 'Authentication required'};
      }

      final queryParams = {
        'period': period,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (type != null) 'type': type,
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/reports/financial/summary',
      ).replace(queryParameters: queryParams);

      print('📡 Summary URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Summary Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Summary Data: ${data['data']}');
        return data;
      } else {
        print('❌ Summary Error: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to fetch summary: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Summary Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFinancialItems({
    int page = 1,
    int perPage = 20,
    String period = 'month',
    String? startDate,
    String? endDate,
    String? search,
    String? type,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No token available');
        return {'success': false, 'message': 'Authentication required'};
      }

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'period': period,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (search != null && search.isNotEmpty) 'search': search,
        if (type != null && type.isNotEmpty) 'type': type,
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/reports/financial',
      ).replace(queryParameters: queryParams);

      print('📡 Items URL: $uri');
      print('📡 Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Items Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        print('❌ Items Error: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to fetch items: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Items Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> exportFinancialReport({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await AuthService.getToken();

      final queryParams = {
        'period': period,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/reports/financial/export',
      ).replace(queryParameters: queryParams);

      print('📡 Export URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept':
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Export Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Get Downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
        } else {
          directory = await getDownloadsDirectory();
        }

        // Create filename with timestamp
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final filePath = '${directory!.path}/Laporan_Keuangan_$timestamp.xlsx';

        // Save file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('✅ File saved to: $filePath');

        return {
          'success': true,
          'message': 'Export successful',
          'path': filePath,
        };
      } else {
        final errorBody = json.decode(response.body);
        print('❌ Export failed: $errorBody');
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Failed to export report',
        };
      }
    } catch (e) {
      print('💥 Export error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getDetailPerItem({
    int page = 1,
    int perPage = 20,
    String period = 'month',
    String? startDate,
    String? endDate,
    String? search,
    String? storeId,
    String? productName,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        'period': period,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (search != null && search.isNotEmpty) 'search': search,
        if (storeId != null) 'store_id': storeId,
        if (productName != null) 'product_name': productName,
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/reports/financial/detail-per-item',
      ).replace(queryParameters: queryParams);

      print('📡 Detail Per Item URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Detail Per Item Response: ${response.statusCode}');
      print('📡 Detail Per Item Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Detail Per Item Data Count: ${data['data']?.length ?? 0}');
        return data;
      } else {
        print('❌ Detail Per Item Error: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to fetch detail per item: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOperatingExpenses({
    String period = 'month',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final queryParams = {
        'period': period,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/reports/financial/operating-expenses',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Failed to fetch operating expenses: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
