import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const routeName = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  final _auth = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _auth.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if ((result['success'] as bool?) != true) {
        throw Exception(result['error'] ?? 'Error de autenticación');
      }

      final prefs = await SharedPreferences.getInstance();
      final userJson = result['user'] as Map<String, dynamic>;
      final user = User.fromJson(userJson);
      await prefs.setString('session_user', jsonEncode(userJson));

      if (!mounted) return;

      // Si el usuario es administrador, redirigir a la página de administración
      if (userJson['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, HomePage.routeName);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Iniciar sesión',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _emailCtrl,
                      label: 'Correo electrónico',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordCtrl,
                      label: 'Contraseña',
                      icon: Icons.lock,
                      obscureText: _obscure,
                      validator: Validators.validatePassword,
                      onToggleVisibility: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      ErrorMessage(message: _error),
                    ],
                    const SizedBox(height: 24),
                    LoadingButton(
                      loading: _loading,
                      text: 'Iniciar sesión',
                      onPressed: _doLogin,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        SignupPage.routeName,
                      ),
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
