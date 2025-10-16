/*
* Implementación web del servicio de autenticación:
* - Almacena datos en SharedPreferences
* - Maneja registro y login de usuarios
* - Gestiona credenciales del administrador
*/

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  static const _usersKey = 'auth_users_db';

  // Encripta la contraseña usando SHA-256
  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();

  // Carga la lista de usuarios desde el almacenamiento local
  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final List list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

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
    final users = await _loadUsers();
    final exists = users.any((u) => u['ci'] == ci || u['email'] == email);
    if (exists) {
      return {'success': false, 'error': 'CI o email ya existe'};
    }
    final id = users.isEmpty ? 1 : (users.last['id'] as int) + 1;
    final user = {
      'id': id,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'second_last_name': secondLastName,
      'ci': ci,
      'email': email,
      'password_hash': _hash(password),
      'role': role ?? 'user',
    };
    users.add(user);
    await _saveUsers(users);
    return {'success': true, 'user': user};
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

    final users = await _loadUsers();
    final user = users.firstWhere(
      (u) => u['email'] == email && u['password_hash'] == _hash(password),
      orElse: () => {},
    );
    if (user.isNotEmpty) {
      return {
        'success': true,
        'user': {
          'id': user['id'],
          'first_name': user['first_name'],
          'middle_name': user['middle_name'],
          'last_name': user['last_name'],
          'second_last_name': user['second_last_name'],
          'ci': user['ci'],
          'email': user['email'],
          'role': user['role'] ?? 'user',
        },
      };
    }
    return {'success': false, 'error': 'Usuario o contraseña incorrectos'};
  }

  @override
  Future<Map<String, dynamic>> getUsers() async {
    final users = await _loadUsers();
    return {
      'success': true,
      'users': users
          .map((user) => {
                'id': user['id'],
                'first_name': user['first_name'],
                'middle_name': user['middle_name'],
                'last_name': user['last_name'],
                'second_last_name': user['second_last_name'],
                'ci': user['ci'],
                'email': user['email'],
                'created_at':
                    user['created_at'] ?? DateTime.now().toIso8601String(),
              })
          .toList(),
    };
  }
}
