import 'package:flutter/material.dart';
import '../models/user_model.dart';
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
  final _middleNameCtrl = TextEditingController();
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
    _middleNameCtrl.dispose();
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
        middleName: _middleNameCtrl.text.trim(),
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
      appBar: AppBar(title: const Text('Registro')),
      body: Center(
        child: SingleChildScrollView(
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
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _middleNameCtrl,
                              label: 'Segundo nombre (opcional)',
                              icon: Icons.person_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _secondLastNameCtrl,
                              label: 'Segundo apellido (opcional)',
                              icon: Icons.person_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _ciCtrl,
                        label: 'Cédula de identidad',
                        icon: Icons.badge,
                        keyboardType: TextInputType.number,
                        validator: Validators.validateCI,
                      ),
                      const SizedBox(height: 16),
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
                        obscureText: _obscurePassword,
                        validator: Validators.validatePassword,
                        onToggleVisibility: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 16),
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
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        ErrorMessage(message: _error!),
                      ],
                      const SizedBox(height: 24),
                      LoadingButton(
                        loading: _loading,
                        text: 'Registrarse',
                        onPressed: _doSignup,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          LoginPage.routeName,
                        ),
                        child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
