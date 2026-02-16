import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_response.dart';

class ChatService {
  // API endpoint (bukan web route, untuk menghindari CORS issue)
  static const String baseUrl = 'https://posphonee.com/api';
  static const String chatEndpoint = '/chat-analisis/ask';

  Future<ChatResponse> sendMessage(String message) async {
    try {
      // Get token dari shared preferences (key: 'token' dari AuthService)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        return ChatResponse(
          ok: false,
          error: 'Tidak terautentikasi. Silakan login kembali.',
        );
      }

      final chatUrl = Uri.parse('$baseUrl$chatEndpoint');
      
      print('=== CHAT SERVICE DEBUG ===');
      print('URL: $chatUrl');
      print('Message: $message');
      print('Token exists: ${token.isNotEmpty}');

      final requestBody = jsonEncode({'message': message});
      print('Request Body: $requestBody');

      final response = await http.post(
        chatUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'User-Agent': 'PosPhone-Mobile/1.0',
        },
        body: requestBody,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('ERROR: REQUEST TIMEOUT');
          return http.Response(
            jsonEncode({'ok': false, 'error': 'Request timeout setelah 30 detik'}),
            408,
          );
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('=========================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return ChatResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 403) {
        return ChatResponse(
          ok: false,
          error: 'Anda tidak memiliki akses untuk mengirim pertanyaan.',
        );
      } else if (response.statusCode == 401) {
        return ChatResponse(
          ok: false,
          error: 'Sesi Anda telah berakhir. Silakan login kembali.',
        );
      } else {
        try {
          final jsonResponse = jsonDecode(response.body);
          return ChatResponse.fromJson(jsonResponse);
        } catch (e) {
          return ChatResponse(
            ok: false,
            error:
                'Terjadi kesalahan: ${response.statusCode} - ${response.reasonPhrase}',
          );
        }
      }
    } on SocketException catch (e) {
      print('SOCKET EXCEPTION: $e');
      return ChatResponse(
        ok: false,
        error: 'Gagal terhubung ke server (Network Error): ${e.message}',
      );
    } on HttpException catch (e) {
      print('HTTP EXCEPTION: $e');
      return ChatResponse(
        ok: false,
        error: 'HTTP Error: ${e.message}',
      );
    } catch (e) {
      print('GENERAL EXCEPTION: $e');
      return ChatResponse(
        ok: false,
        error: 'Gagal terhubung ke server: ${e.toString()}',
      );
    }
  }
}
