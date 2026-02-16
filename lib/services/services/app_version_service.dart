import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/app_version.dart';

class AppVersionService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetch app version for specific platform
  static Future<AppVersion?> getAppVersion(String platform) async {
    try {
      final headers = await _getHeaders();
      print('🌐 API: GET /api/app-versions?platform=$platform');
      print('🌐 API: Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/app-versions?platform=$platform'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      print('🌐 API: Response Status Code: ${response.statusCode}');
      print('🌐 API: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🌐 API: Decoded JSON: $jsonData');
        
        if (jsonData['status'] == true && jsonData['data'] != null) {
          // API returns single data for specific platform
          final appVersion = AppVersion.fromJson(jsonData['data']);
          print('🌐 API: Successfully parsed AppVersion: $appVersion');
          return appVersion;
        } else {
          print('🌐 API: Invalid response format');
        }
      } else {
        print('🌐 API: Unexpected status code');
      }
      return null;
    } catch (e) {
      print('🌐 API: Error fetching app version: $e');
      return null;
    }
  }

  /// Fetch all app versions
  static Future<List<AppVersion>> getAllAppVersions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/app-versions'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['status'] == true && jsonData['data'] != null) {
          final data = jsonData['data'] as List;
          return data.map((item) => AppVersion.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching app versions: $e');
      return [];
    }
  }
}
