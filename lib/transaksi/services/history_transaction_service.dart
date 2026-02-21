import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/history_transaction.dart';

class HistoryTransactionService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Get all history transactions with optional filters
  static Future<Map<String, dynamic>> getHistoryTransactions({
    int page = 1,
    int perPage = 10,
    int? posTokoId,
    int? posPelangganId,
    int? posSupplierId,
    String? type, // 'incoming', 'outgoing', or null for all
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

      if (type != null) queryParams['type'] = type.toLowerCase();
      if (status != null) queryParams['status'] = status.toLowerCase();
      if (posTokoId != null) queryParams['pos_toko_id'] = posTokoId.toString();
      if (posPelangganId != null) {
        queryParams['pos_pelanggan_id'] = posPelangganId.toString();
      }
      if (posSupplierId != null) {
        queryParams['pos_supplier_id'] = posSupplierId.toString();
      }
      if (metodePembayaran != null) {
        queryParams['metode_pembayaran'] = metodePembayaran;
      }
      if (invoice != null) queryParams['invoice'] = invoice;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('$baseUrl/api/transactions')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> dataList = responseBody['data'] ?? [];
        final List<HistoryTransaction> transactions =
            dataList.map((json) => HistoryTransaction.fromJson(json)).toList();

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

  /// Get single transaction by ID
  static Future<Map<String, dynamic>> getHistoryTransaction(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/transactions/$id'),
        headers: ApiConfig.authHeaders(token),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        final HistoryTransaction transaction =
            HistoryTransaction.fromJson(responseBody['data']);

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

  /// Get transaction summary statistics
  static Future<Map<String, dynamic>> getHistorySummary({
    int? posTokoId,
    String? type,
    String? status,
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

      if (type != null) queryParams['type'] = type.toLowerCase();
      if (status != null) queryParams['status'] = status.toLowerCase();
      if (posTokoId != null) queryParams['pos_toko_id'] = posTokoId.toString();
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('$baseUrl/api/transactions/summary')
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
}
