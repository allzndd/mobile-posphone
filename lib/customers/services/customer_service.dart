import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/customer.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;
  CustomerService._internal();

  Future<CustomerResponse> getCustomers({
    int page = 1,
    String? search,
    String? sortBy,
    String? sortOrder,
    int perPage = 20,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan - silakan login terlebih dahulu');
      }

      print('Making API call to: ${ApiConfig.baseUrl}/api/customers');
      print('Token: ${token.substring(0, 10)}...');

      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/customers',
      ).replace(queryParameters: queryParams);

      print('Full URL: $uri');

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token invalid, user needs to login again
        await AuthService.logout();
        throw Exception('Token tidak valid - silakan login ulang');
      } else {
        throw Exception('Gagal mengambil data pelanggan: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getCustomers: $e');
      throw Exception('Error: $e');
    }
  }

  Future<CustomerResponse> getCustomer(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan - silakan login terlebih dahulu');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/customers/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Token tidak valid - silakan login ulang');
      } else {
        throw Exception('Gagal mengambil detail pelanggan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<CustomerResponse> createCustomer(Customer customer) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan - silakan login terlebih dahulu');
      }

      print('Creating customer: ${customer.toCreateJson()}');
      print('Token: ${token.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/customers'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(customer.toCreateJson()),
      );

      print('Create response status: ${response.statusCode}');
      print('Create response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Token tidak valid - silakan login ulang');
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = json.decode(response.body);
        final errors = errorData['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final errorMessages = <String>[];
          errors.forEach((field, messages) {
            if (messages is List) {
              errorMessages.addAll(messages.cast<String>());
            }
          });
          throw Exception(errorMessages.join('\n'));
        } else {
          throw Exception(errorData['message'] ?? 'Data tidak valid');
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal menambah pelanggan');
      }
    } catch (e) {
      print('Error in createCustomer: $e');
      throw Exception('Error: $e');
    }
  }

  Future<CustomerResponse> updateCustomer(int id, Customer customer) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan - silakan login terlebih dahulu');
      }

      print('Updating customer ID: $id');
      print('Update data: ${customer.toUpdateJson()}');
      print('Token: ${token.substring(0, 10)}...');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/customers/$id'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(customer.toUpdateJson()),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Token tidak valid - silakan login ulang');
      } else if (response.statusCode == 422) {
        // Validation error
        final errorData = json.decode(response.body);
        final errors = errorData['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final errorMessages = <String>[];
          errors.forEach((field, messages) {
            if (messages is List) {
              errorMessages.addAll(messages.cast<String>());
            }
          });
          throw Exception(errorMessages.join('\n'));
        } else {
          throw Exception(errorData['message'] ?? 'Data tidak valid');
        }
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal mengupdate pelanggan');
      }
    } catch (e) {
      print('Error in updateCustomer: $e');
      throw Exception('Error: $e');
    }
  }

  Future<bool> deleteCustomer(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan - silakan login terlebih dahulu');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/customers/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Token tidak valid - silakan login ulang');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Gagal menghapus pelanggan');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final result = await getCustomers(search: query, perPage: 50);
      return result.customers ?? [];
    } catch (e) {
      throw Exception('Error mencari pelanggan: $e');
    }
  }

  Future<CustomerStats> getCustomerStats() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan - silakan login terlebih dahulu');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/customers/stats'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return CustomerStats.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Gagal mengambil statistik');
        }
      } else if (response.statusCode == 401) {
        await AuthService.logout();
        throw Exception('Token tidak valid - silakan login ulang');
      } else {
        throw Exception('Gagal mengambil statistik pelanggan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}