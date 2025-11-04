/*
* Pantalla de inicio de sesión:
* - Formulario para email y contraseña
* - Validación de credenciales
* - Redirección a Home o Admin según el tipo de usuario
*/

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

  // Procesa el intento de inicio de sesión
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
      // Stack permite colocar widgets uno encima del otro
      body: Stack(
        children: [
          // Imagen de fondo del violín que cubre toda la pantalla
          Positioned.fill(
            child: Image.asset(
              'assets/images/music_login.jpg',
              fit: BoxFit.cover, // La imagen cubre toda la pantalla
              errorBuilder: (context, error, stackTrace) {
                // Si la imagen no se encuentra, mostrar un fondo degradado
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.shade300,
                        Colors.blue.shade400,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Capa semi-transparente para mejorar contraste
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // Formulario de login encima del fondo
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                margin: const EdgeInsets.all(16),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Encabezado simple con barra azul
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: const Text(
                        'Venta de Instrumentos Musicales',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Formulario
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 8),
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
                        // Botón de Iniciar sesión
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Botón de Registrarse
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              SignupPage.routeName,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              '¿No tienes cuenta? Regístrate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
