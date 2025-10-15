import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  static const routeName = '/admin';

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<User>? _users;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadUsers();
  }

  Future<void> _checkAdminAndLoadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString('session_user');
    if (rawUser == null) {
      setState(() => _error = 'No hay sesión activa');
      return;
    }

    final user = jsonDecode(rawUser) as Map<String, dynamic>;
    if (user['role'] != 'admin') {
      setState(() => _error = 'Acceso no autorizado');
      return;
    }

    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // TODO: Implementar método en AuthService para obtener usuarios
      final result = await AuthService().getUsers();

      setState(() {
        _users =
            (result['users'] as List).map((u) => User.fromJson(u)).toList();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_user');
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: _logout,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuarios Registrados',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      ErrorMessage(message: _error!)
                    else if (_users?.isEmpty ?? true)
                      const Center(
                        child: Text('No hay usuarios registrados'),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('CI')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Fecha de Registro')),
                          ],
                          rows: _users!.map((user) {
                            return DataRow(cells: [
                              DataCell(Text(user.ci)),
                              DataCell(Text(user.fullName)),
                              DataCell(Text(user.email)),
                              DataCell(Text(
                                user.createdAt
                                    .toLocal()
                                    .toString()
                                    .split('.')[0],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadUsers,
        icon: const Icon(Icons.refresh),
        label: const Text('Actualizar'),
      ),
    );
  }
}
