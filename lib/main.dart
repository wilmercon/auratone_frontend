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
      title: 'Proyecto PI - Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (_) => const LoginPage(),
        HomePage.routeName: (_) => const HomePage(),
        SignupPage.routeName: (_) => const SignupPage(),
        AdminPage.routeName: (_) => const AdminPage(),
      },
    );
  }
}
