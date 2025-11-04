/*
* Punto de entrada principal de la aplicación
* Define:
* - Configuración inicial de la aplicación
* - Sistema de rutas para la navegación entre pantallas
* - Pantalla inicial 
*/

import 'package:flutter/material.dart';
import 'screens/admin_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la aplicación mostrado en la barra de tareas
      title: 'AuraTone - Instrumentos Musicales',
      // debugShowCheckedModeBanner: false elimina el banner "DEBUG" de la esquina superior derecha
      debugShowCheckedModeBanner: false,
      // Tema visual de la aplicación con Material Design 3
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // Ruta inicial que se muestra al abrir la aplicación (pantalla de login)
      initialRoute: LoginPage.routeName,
      // Definición de todas las rutas disponibles en la aplicación
      routes: {
        LoginPage.routeName: (_) => const LoginPage(),
        HomePage.routeName: (_) => const HomePage(),
        SignupPage.routeName: (_) => const SignupPage(),
        AdminPage.routeName: (_) => const AdminPage(),
      },
    );
  }
}
