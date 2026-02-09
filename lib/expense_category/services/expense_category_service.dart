import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';

class ExpenseCategoryService {
  /// Get all expense categories with pagination and search
  static Future<Map<String, dynamic>> getExpenseCategories({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
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
        '${ApiConfig.baseUrl}/api/expense-categories',
      ).replace(queryParameters: queryParams);

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
          'success': true,
          'data': data['data'] ?? [],
          'total': data['total'] ?? 0,
          'current_page': data['current_page'] ?? 1,
          'last_page': data['last_page'] ?? 1,
          'per_page': data['per_page'] ?? perPage,
          'message': 'Expense categories loaded successfully',
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
          'message': data['message'] ?? 'Failed to load expense categories',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get expense category by ID
  static Future<Map<String, dynamic>> getExpenseCategoryById(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/expense-categories/$id'),
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
          'message': 'Expense category loaded successfully',
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
          'message': data['message'] ?? 'Failed to load expense category',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Create new expense category
  static Future<Map<String, dynamic>> createExpenseCategory({
    required String nama,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final body = {'nama': nama};

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/expense-categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Expense category created successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': data['message'] ?? 'Validation error',
          'errors': data['errors'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create expense category',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Update expense category
  static Future<Map<String, dynamic>> updateExpenseCategory({
    required int id,
    required String nama,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final body = {'nama': nama, '_method': 'PUT'};

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/expense-categories/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Expense category updated successfully',
        };
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': data['message'] ?? 'Validation error',
          'errors': data['errors'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update expense category',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Delete expense category
  static Future<Map<String, dynamic>> deleteExpenseCategory(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token not found. Please login again.',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/expense-categories/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Expense category deleted successfully',
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
          'message': data['message'] ?? 'Failed to delete expense category',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
