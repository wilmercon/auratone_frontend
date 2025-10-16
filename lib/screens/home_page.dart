/*
* Pantalla principal para usuarios regulares:
* - Muestra la interfaz principal del usuario
* - Gestiona la sesión del usuario
* - Permite cerrar sesión
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_user');
    setState(() =>
        _user = raw != null ? jsonDecode(raw) as Map<String, dynamic> : null);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user');
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final username = _user != null ? (_user!['username'] as String? ?? '') : '';
    final email = _user != null ? (_user!['email'] as String? ?? '') : '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Salir',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bienvenido, estás autenticado.'),
              const SizedBox(height: 12),
              if (_user != null) ...[
                Text('Usuario: $username'),
                Text('Email: $email'),
              ] else ...[
                const Text('Sesión no disponible'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
