/*
* Funciones de validación:
* - Validación de email
* - Validación de contraseña
* - Validación de campos obligatorios
*/

class Validators {
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _ciRegex = RegExp(r'^\d+$');

  // Valida el formato del correo electrónico usando una expresión regular
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su correo electrónico';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  static String? validateCI(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su cédula de identidad';
    }
    if (!_ciRegex.hasMatch(value)) {
      return 'La cédula debe contener solo números';
    }
    return null;
  }

  // Valida que la contraseña cumpla con los requisitos mínimos de seguridad
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su $fieldName';
    }
    return null;
  }
}

class StringUtils {
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  static String formatName(String firstName, String? middleName,
      String lastName, String? secondLastName) {
    final parts = [
      firstName,
      if (middleName != null && middleName.isNotEmpty) middleName,
      lastName,
      if (secondLastName != null && secondLastName.isNotEmpty) secondLastName,
    ];
    return parts.map(capitalize).join(' ');
  }
}
