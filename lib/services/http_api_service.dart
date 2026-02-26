import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_services.dart';
import 'dart:async';

class HttpApiService implements ApiService {
  final String baseUrl;
  String? _authToken;

  HttpApiService({required this.baseUrl});
  String? get authToken => _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> _buildHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {};
    } else {
      String message = 'HTTP error ${response.statusCode}';
      try {
        final errorBody = jsonDecode(response.body);
        if (errorBody is Map && errorBody.containsKey('message')) {
          message = errorBody['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: _buildHeaders());
    return _handleResponse(response);
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: _buildHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: _buildHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  @override
  Future<void> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(url, headers: _buildHeaders());
    await _handleResponse(response);
  }
}
