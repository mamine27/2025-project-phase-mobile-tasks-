import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl =
      'https://g5-flutter-learning-path-be.onrender.com/api/v2/';
  final Map<String, String> defaultHeaders;

  ApiClient({this.defaultHeaders = const {}});

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = {...defaultHeaders, ...?headers};
    return await http.get(uri, headers: mergedHeaders);
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = {
      ...defaultHeaders,
      ...?headers,
      'Content-Type': 'application/json',
    };
    return await http.post(uri, headers: mergedHeaders, body: jsonEncode(body));
  }
}
