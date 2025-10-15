import 'auth_service_interface.dart';

// Platform-specific implementation
import 'auth_service_mobile.dart' if (dart.library.html) 'auth_service_web.dart'
    as platform;

class AuthService implements AuthServiceInterface {
  final platform.AuthService _impl = platform.AuthService();

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      _impl.login(email: email, password: password);

  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    String? middleName,
    required String lastName,
    String? secondLastName,
    required String ci,
    required String email,
    required String password,
    String? role,
  }) =>
      _impl.register(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        secondLastName: secondLastName,
        ci: ci,
        email: email,
        password: password,
        role: role,
      );

  @override
  Future<Map<String, dynamic>> getUsers() => _impl.getUsers();
}
