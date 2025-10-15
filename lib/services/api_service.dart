import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? 'http://localhost:5000';

  final String baseUrl;

  Future<Map<String, dynamic>> login(
      {required String username, required String password}) async {
    final uri = Uri.parse('$baseUrl/api/login');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    final data = jsonDecode(resp.body);
    if (resp.statusCode == 200) {
      return data as Map<String, dynamic>;
    } else {
      throw Exception(data['error'] ?? 'Error de autenticación');
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/register');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'username': username, 'email': email, 'password': password}),
    );

    final data = jsonDecode(resp.body);
    if (resp.statusCode == 201) {
      return data as Map<String, dynamic>;
    } else {
      throw Exception(data['error'] ?? 'No se pudo registrar');
    }
  }

  Future<bool> verify(String token) async {
    final uri = Uri.parse('$baseUrl/api/verify');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    return resp.statusCode == 200;
  }
}
