/*
* Define la interfaz base de autenticación:
* - Métodos requeridos para autenticación
* - Credenciales del administrador
* - Estructura común para ambas implementaciones
*/

abstract class AuthServiceInterface {
  Future<Map<String, dynamic>> register({
    required String firstName,
    String? middleName,
    required String lastName,
    String? secondLastName,
    required String ci,
    required String email,
    required String password,
    String? role,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> getUsers();

  // Static admin credentials
  static const adminEmail = 'admin@gmail.com';
  static const adminPassword = 'admin123';
}
