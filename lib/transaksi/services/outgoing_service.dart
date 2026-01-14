import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/Outgoing.dart';

class OutgoingService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get all outgoing transactions with optional filters
  static Future<Map<String, dynamic>> getOutgoingTransactions({
    int page = 1,
    int perPage = 10,
    int? posTokoId,
    int? posSupplierId,
    String? status,
    String? metodePembayaran,
    String? invoice,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (posTokoId != null) queryParams['pos_toko_id'] = posTokoId.toString();
      if (posSupplierId != null) {
        queryParams['pos_supplier_id'] = posSupplierId.toString();
      }
      if (status != null) queryParams['status'] = status.toLowerCase();
      if (metodePembayaran != null) {
        queryParams['metode_pembayaran'] = metodePembayaran.toLowerCase();
      }
      if (invoice != null) queryParams['invoice'] = invoice;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('$baseUrl/api/transactions/outgoing')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<Outgoing> transactions = (responseBody['data'] as List)
            .map((json) => Outgoing.fromJson(json))
            .toList();

        return {
          'success': true,
          'data': transactions,
          'pagination': responseBody['pagination'],
        };
      }

      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to load transactions',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get single outgoing transaction by ID
  static Future<Map<String, dynamic>> getOutgoingTransaction(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/outgoing/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final transaction = Outgoing.fromJson(responseBody['data']);
        return {
          'success': true,
          'data': transaction,
        };
      }

      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to load transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Create new outgoing transaction
  static Future<Map<String, dynamic>> createOutgoingTransaction({
    required int posTokoId,
    required int posSupplierId,
    required String invoice,
    required double totalHarga,
    String? keterangan,
    required String status,
    required String metodePembayaran,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final data = {
        'pos_toko_id': posTokoId,
        'pos_supplier_id': posSupplierId,
        'invoice': invoice,
        'total_harga': totalHarga,
        'keterangan': keterangan,
        'status': status.toLowerCase(),
        'metode_pembayaran': metodePembayaran.toLowerCase(),
        'items': items,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/transactions/outgoing'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(data),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final transaction = Outgoing.fromJson(responseBody['data']);
        return {
          'success': true,
          'data': transaction,
          'message': responseBody['message'],
        };
      }

      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to create transaction',
        'errors': responseBody['errors'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Update existing outgoing transaction
  static Future<Map<String, dynamic>> updateOutgoingTransaction({
    required int id,
    required int posTokoId,
    required int posSupplierId,
    required double totalHarga,
    String? keterangan,
    required String status,
    required String metodePembayaran,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final data = {
        'pos_toko_id': posTokoId,
        'pos_supplier_id': posSupplierId,
        'total_harga': totalHarga,
        'keterangan': keterangan,
        'status': status.toLowerCase(),
        'metode_pembayaran': metodePembayaran.toLowerCase(),
        'items': items,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/transactions/outgoing/$id'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(data),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final transaction = Outgoing.fromJson(responseBody['data']);
        return {
          'success': true,
          'data': transaction,
          'message': responseBody['message'],
        };
      }

      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to update transaction',
        'errors': responseBody['errors'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Delete outgoing transaction
  static Future<Map<String, dynamic>> deleteOutgoingTransaction(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/transactions/outgoing/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Transaction deleted successfully',
        };
      }

      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to delete transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get last transaction for invoice generation
  static Future<Map<String, dynamic>> getLastTransaction() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/outgoing/last'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
        };
      }

      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to get last transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get transaction statistics
  static Future<Map<String, dynamic>> getStatistics({
    String? startDate,
    String? endDate,
    int? posTokoId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (posTokoId != null) queryParams['pos_toko_id'] = posTokoId.toString();

      final uri = Uri.parse('$baseUrl/api/transactions/outgoing/statistics')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseBody['data'],
        };
      }

      return {
        'success': false,
        'message': responseBody['message'] ?? 'Failed to get statistics',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
