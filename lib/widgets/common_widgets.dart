/*
* Widgets comunes reutilizables:
* - CustomTextField: Campo de texto personalizado
* - LoadingButton: Botón con estado de carga
* - ErrorMessage: Mensaje de error formateado
*/

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final VoidCallback? onToggleVisibility;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onToggleVisibility,
  });

  // Construye un campo de texto personalizado con ícono y validación
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(icon, size: 18),
        ),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                ),
                onPressed: onToggleVisibility,
                padding: const EdgeInsets.all(8),
                visualDensity: VisualDensity.compact,
              )
            : null,
        isDense: true,
        floatingLabelStyle: const TextStyle(fontSize: 13),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }
}

class LoadingButton extends StatelessWidget {
  final bool loading;
  final String text;
  final VoidCallback? onPressed;

  const LoadingButton({
    super.key,
    required this.loading,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 36),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: loading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String? message;

  const ErrorMessage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
