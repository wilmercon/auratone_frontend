/*
* Implementación móvil del servicio de autenticación:
* - Se conecta al backend Flask para autenticación
* - Maneja registro y login de usuarios
* - Gestiona tokens JWT
*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  static Database? _db;

  // Obtiene la instancia de la base de datos SQLite
  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static const String _baseUrl = 'http://localhost:5000/api';

  Future<Map<String, dynamic>> register({
    required String firstName,
    String? middleName,
    required String lastName,
    String? secondLastName,
    required String ci,
    required String email,
    required String password,
    String? role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'middleName': middleName,
          'lastName': lastName,
          'secondLastName': secondLastName,
          'ci': ci,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Error al registrar usuario',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getUsers() async {
    final db = await _database;
    final List<Map<String, Object?>> users = await db.query(
      'users',
      orderBy: 'created_at DESC',
    );

    return {
      'success': true,
      'users': users,
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Check admin credentials first
    if (email == AuthServiceInterface.adminEmail &&
        password == AuthServiceInterface.adminPassword) {
      return {
        'success': true,
        'user': {
          'id': 0,
          'first_name': 'Admin',
          'middle_name': null,
          'last_name': 'Sistema',
          'second_last_name': null,
          'ci': 'ADMIN',
          'email': AuthServiceInterface.adminEmail,
          'role': 'admin',
        },
      };
    }

    final db = await _database;
    final List<Map<String, Object?>> res = await db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email, _hash(password)],
      limit: 1,
    );

    if (res.isNotEmpty) {
      final u = res.first;
      return {
        'success': true,
        'user': {
          'id': u['id'],
          'first_name': u['first_name'],
          'middle_name': u['middle_name'],
          'last_name': u['last_name'],
          'second_last_name': u['second_last_name'],
          'ci': u['ci'],
          'email': u['email'],
        },
      };
    }
    return {'success': false, 'error': 'Usuario o contraseña incorrectos'};
  }
}
