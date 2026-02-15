import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class ExpenseTransactionService {
  /// Get all expense transactions with pagination and search
  static Future<Map<String, dynamic>> getExpenseTransactions({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ [EXPENSE TRANSACTION SERVICE] Token not found');
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/expense-transactions',
      ).replace(queryParameters: queryParams);

      print('🔍 [EXPENSE TRANSACTION SERVICE] Request URL: $uri');
      print(
        '🔑 [EXPENSE TRANSACTION SERVICE] Token: ${token.substring(0, 20)}...',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(
        '📊 [EXPENSE TRANSACTION SERVICE] Status Code: ${response.statusCode}',
      );
      print('📦 [EXPENSE TRANSACTION SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pagination = data['pagination'] ?? {};
        
        print(
          '✅ [EXPENSE TRANSACTION SERVICE] Success - Total items: ${pagination['total']}',
        );
        print('📋 [EXPENSE TRANSACTION SERVICE] Data count: ${(data['data'] as List).length}');
        print('📄 [EXPENSE TRANSACTION SERVICE] Pagination: $pagination');
        if ((data['data'] as List).isNotEmpty) {
          print('🔍 [EXPENSE TRANSACTION SERVICE] First item: ${data['data'][0]}');
        }
        
        return {
          'success': true,
          'data': data['data'] ?? [],
          'total': pagination['total'] ?? 0,
          'current_page': pagination['current_page'] ?? 1,
          'last_page': pagination['last_page'] ?? 1,
          'per_page': pagination['per_page'] ?? perPage,
          'message': 'Expense transactions loaded successfully',
        };
      } else if (response.statusCode == 401) {
        print('⚠️ [EXPENSE TRANSACTION SERVICE] Unauthorized - logging out');
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        print(
          '❌ [EXPENSE TRANSACTION SERVICE] Error response: ${response.body}',
        );
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load expense transactions',
        };
      }
    } catch (e, stackTrace) {
      print('❌ [EXPENSE TRANSACTION SERVICE] Exception caught: $e');
      print('📍 [EXPENSE TRANSACTION SERVICE] Stack trace: $stackTrace');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get expense transaction by ID
  static Future<Map<String, dynamic>> getExpenseTransactionById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/expense-transactions/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': 'Expense transaction loaded successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {'success': false, 'message': 'Expense transaction not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Create new expense transaction
  static Future<Map<String, dynamic>> createExpenseTransaction({
    required int posKategoriExpenseId,
    required double totalHarga,
    String? keterangan,
    String? metodePembayaran,
    int? posTokoId,
    String? invoice,
    String? status,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ [EXPENSE SERVICE] Token not found');
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final requestBody = {
        'pos_kategori_expense_id': posKategoriExpenseId,
        'total_harga': totalHarga,
        if (keterangan != null) 'keterangan': keterangan,
        if (metodePembayaran != null) 'metode_pembayaran': metodePembayaran,
        if (posTokoId != null) 'pos_toko_id': posTokoId,
        if (invoice != null && invoice.isNotEmpty) 'invoice': invoice,
        if (status != null) 'status': status,
      };

      print('🔍 [EXPENSE SERVICE] Creating expense transaction');
      print('📍 URL: ${ApiConfig.baseUrl}/api/expense-transactions');
      print('📦 Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/expense-transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📊 [EXPENSE SERVICE] Status Code: ${response.statusCode}');
      print('📦 [EXPENSE SERVICE] Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ [EXPENSE SERVICE] Success: Transaction created');
        return {
          'success': true,
          'data': data['data'],
          'message':
              data['message'] ?? 'Expense transaction created successfully',
        };
      } else if (response.statusCode == 401) {
        print('⚠️ [EXPENSE SERVICE] Unauthorized - logging out');
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        print('❌ [EXPENSE SERVICE] Validation Error: ${data['errors']}');
        return {
          'success': false,
          'errors': data['errors'] ?? {},
          'message': data['message'] ?? 'Validation failed',
        };
      } else {
        final data = jsonDecode(response.body);
        print(
          '❌ [EXPENSE SERVICE] Error ${response.statusCode}: ${data['message']}',
        );
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create expense transaction',
        };
      }
    } catch (e, stackTrace) {
      print('❌ [EXPENSE SERVICE] Exception caught: $e');
      print('📍 [EXPENSE SERVICE] Stack trace: $stackTrace');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Update expense transaction
  static Future<Map<String, dynamic>> updateExpenseTransaction({
    required int id,
    required int posKategoriExpenseId,
    required double totalHarga,
    String? keterangan,
    String? metodePembayaran,
    int? posTokoId,
    String? invoice,
    String? status,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/expense-transactions/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pos_kategori_expense_id': posKategoriExpenseId,
          'total_harga': totalHarga,
          if (keterangan != null) 'keterangan': keterangan,
          if (metodePembayaran != null) 'metode_pembayaran': metodePembayaran,
          if (posTokoId != null) 'pos_toko_id': posTokoId,
          if (invoice != null && invoice.isNotEmpty) 'invoice': invoice,
          if (status != null) 'status': status,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message':
              data['message'] ?? 'Expense transaction updated successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'errors': data['errors'] ?? {},
          'message': data['message'] ?? 'Validation failed',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update expense transaction',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Delete expense transaction
  static Future<Map<String, dynamic>> deleteExpenseTransaction(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/expense-transactions/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              data['message'] ?? 'Expense transaction deleted successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete expense transaction',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
