import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/Incoming.dart';

class IncomingService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get all incoming transactions with optional filters
  static Future<Map<String, dynamic>> getIncomingTransactions({
    int page = 1,
    int perPage = 10,
    int? posTokoId,
    int? posPelangganId,
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
      if (posPelangganId != null) {
        queryParams['pos_pelanggan_id'] = posPelangganId.toString();
      }
      if (status != null) queryParams['status'] = status.toLowerCase();
      if (metodePembayaran != null) {
        queryParams['metode_pembayaran'] = metodePembayaran.toLowerCase();
      }
      if (invoice != null) queryParams['invoice'] = invoice;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('$baseUrl/api/transactions/incoming')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<Incoming> transactions = (responseBody['data'] as List)
            .map((json) => Incoming.fromJson(json))
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

  /// Get single incoming transaction by ID
  static Future<Map<String, dynamic>> getIncomingTransaction(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/incoming/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final transaction = Incoming.fromJson(responseBody['data']);
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

  /// Create new incoming transaction
  static Future<Map<String, dynamic>> createIncomingTransaction({
    required int posTokoId,
    int? posPelangganId,
    int? posTukarTambahId,
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
        'pos_pelanggan_id': posPelangganId,
        'pos_tukar_tambah_id': posTukarTambahId,
        'invoice': invoice,
        'total_harga': totalHarga,
        'keterangan': keterangan,
        'status': status.toLowerCase(),
        'metode_pembayaran': metodePembayaran.toLowerCase(),
        'items': items,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/transactions/incoming'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(data),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final transaction = Incoming.fromJson(responseBody['data']);
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

  /// Update existing incoming transaction
  static Future<Map<String, dynamic>> updateIncomingTransaction({
    required int id,
    required int posTokoId,
    int? posPelangganId,
    int? posTukarTambahId,
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
        'pos_pelanggan_id': posPelangganId,
        'pos_tukar_tambah_id': posTukarTambahId,
        'total_harga': totalHarga,
        'keterangan': keterangan,
        'status': status.toLowerCase(),
        'metode_pembayaran': metodePembayaran.toLowerCase(),
        'items': items,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/transactions/incoming/$id'),
        headers: ApiConfig.authHeaders(token),
        body: json.encode(data),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final transaction = Incoming.fromJson(responseBody['data']);
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

  /// Delete incoming transaction
  static Future<Map<String, dynamic>> deleteIncomingTransaction(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/transactions/incoming/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseBody['message'] ?? 'Failed to delete transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get transaction summary statistics
  static Future<Map<String, dynamic>> getSummary({
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

      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('$baseUrl/api/transactions/incoming/summary')
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
        'message': responseBody['message'] ?? 'Failed to load summary',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Generate new invoice number
  static Future<String> generateInvoiceNumber() async {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$timestamp';
  }
}
