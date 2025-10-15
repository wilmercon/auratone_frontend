import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  static Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dbPath = p.join(dir.path, 'users.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            middle_name TEXT,
            last_name TEXT NOT NULL,
            second_last_name TEXT,
            ci TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'user',
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();

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
    final db = await _database;
    try {
      final id = await db.insert('users', {
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'second_last_name': secondLastName,
        'ci': ci,
        'email': email,
        'password_hash': _hash(password),
        'role': role ?? 'user',
      });
      return {
        'success': true,
        'user': {
          'id': id,
          'first_name': firstName,
          'middle_name': middleName,
          'last_name': lastName,
          'second_last_name': secondLastName,
          'ci': ci,
          'email': email,
        },
      };
    } catch (e) {
      return {'success': false, 'error': 'Usuario o email ya existe'};
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
