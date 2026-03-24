import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../exceptions/api_exception.dart';
import 'storage_service.dart';

class ApiBaseHelper {
  static String get baseUrl => dotenv.env['BASE_URL']!;

  static Future<dynamic> get(String endpoint) async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, dynamic body) async {
    final headers = await _headers();

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['message'] ?? 'Something went wrong',
        statusCode: response.statusCode,
      );
    }
  }
}
