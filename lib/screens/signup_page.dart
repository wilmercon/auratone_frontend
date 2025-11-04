/*
* Pantalla de registro de nuevos usuarios:
* - Formulario completo para datos personales
* - Validación de campos
* - Registro de nuevos usuarios en el sistema
*/

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../widgets/common_widgets.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  static const routeName = '/signup';

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _secondLastNameCtrl = TextEditingController();
  final _ciCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  final _auth = AuthService();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _secondLastNameCtrl.dispose();
    _ciCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _auth.register(
        firstName: _firstNameCtrl.text.trim(),
        middleName: '',
        lastName: _lastNameCtrl.text.trim(),
        secondLastName: _secondLastNameCtrl.text.trim(),
        ci: _ciCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if ((result['success'] as bool?) != true) {
        throw Exception(result['error'] ?? 'Error al registrar usuario');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Botón de back personalizado con estilo azul
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
              elevation: 2,
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
        ),
      ),
      extendBodyBehindAppBar: true, // Permite que el fondo se extienda detrás del AppBar
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
          // Formulario de registro encima del fondo
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 680),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Card(
                  elevation: 8,
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          'Registro de usuario',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Formulario
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8.0),
                        child: Form(
                          key: _formKey,
                          // LayoutBuilder permite adaptar el diseño según el ancho disponible
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Si el ancho es menor a 500px, mostrar campos en columna
                              // Si es mayor, mostrar en filas de 2 columnas
                              final isSmallScreen = constraints.maxWidth < 500;
                              
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                            // Campos de nombre y cédula: en fila si hay espacio, en columna si no
                            if (isSmallScreen) ...[
                              // Pantalla pequeña: campos en columna
                              CustomTextField(
                                controller: _firstNameCtrl,
                                label: 'Primer nombre',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    Validators.validateName(v, 'primer nombre'),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: _ciCtrl,
                                label: 'Cédula de identidad',
                                icon: Icons.badge,
                                keyboardType: TextInputType.number,
                                validator: Validators.validateCI,
                              ),
                            ] else ...[
                              // Pantalla grande: campos en fila
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _firstNameCtrl,
                                      label: 'Primer nombre',
                                      icon: Icons.person_outline,
                                      validator: (v) =>
                                          Validators.validateName(v, 'primer nombre'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _ciCtrl,
                                      label: 'Cédula de identidad',
                                      icon: Icons.badge,
                                      keyboardType: TextInputType.number,
                                      validator: Validators.validateCI,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            // Campos de apellidos: en fila si hay espacio, en columna si no
                            if (isSmallScreen) ...[
                              // Pantalla pequeña: campos en columna
                              CustomTextField(
                                controller: _lastNameCtrl,
                                label: 'Primer apellido',
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    Validators.validateName(v, 'primer apellido'),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: _secondLastNameCtrl,
                                label: 'Segundo apellido (opcional)',
                                icon: Icons.person_outline,
                              ),
                            ] else ...[
                              // Pantalla grande: campos en fila
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _lastNameCtrl,
                                      label: 'Primer apellido',
                                      icon: Icons.person_outline,
                                      validator: (v) =>
                                          Validators.validateName(v, 'primer apellido'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _secondLastNameCtrl,
                                      label: 'Segundo apellido (opcional)',
                                      icon: Icons.person_outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            // Campos que siempre ocupan el ancho completo

                            CustomTextField(
                              controller: _emailCtrl,
                              label: 'Correo electrónico',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 8),
                            // Campos de contraseña: en fila si hay espacio, en columna si no
                            if (isSmallScreen) ...[
                              // Pantalla pequeña: campos en columna
                              CustomTextField(
                                controller: _passwordCtrl,
                                label: 'Contraseña',
                                icon: Icons.lock,
                                obscureText: _obscurePassword,
                                validator: Validators.validatePassword,
                                onToggleVisibility: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: _confirmPasswordCtrl,
                                label: 'Confirmar contraseña',
                                icon: Icons.lock_outline,
                                obscureText: _obscureConfirm,
                                validator: (v) => v != _passwordCtrl.text
                                    ? 'Las contraseñas no coinciden'
                                    : null,
                                onToggleVisibility: () =>
                                    setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ] else ...[
                              // Pantalla grande: campos en fila
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _passwordCtrl,
                                      label: 'Contraseña',
                                      icon: Icons.lock,
                                      obscureText: _obscurePassword,
                                      validator: Validators.validatePassword,
                                      onToggleVisibility: () => setState(
                                          () => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _confirmPasswordCtrl,
                                      label: 'Confirmar contraseña',
                                      icon: Icons.lock_outline,
                                      obscureText: _obscureConfirm,
                                      validator: (v) => v != _passwordCtrl.text
                                          ? 'Las contraseñas no coinciden'
                                          : null,
                                      onToggleVisibility: () =>
                                          setState(() => _obscureConfirm = !_obscureConfirm),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Mostrar mensaje de error si existe
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              ErrorMessage(message: _error!),
                            ],
                            const SizedBox(height: 12),
                            // Botón de registro con estilo azul
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _doSignup,
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
                                        'Registrarse',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Botón para ir a login con estilo azul sólido
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  LoginPage.routeName,
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
                                  '¿Ya tienes cuenta? Inicia sesión',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
