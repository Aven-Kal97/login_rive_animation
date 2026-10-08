import 'package:flutter/material.dart';
import 'package:ada_1_angel_lugo/screens/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inicio de sesión con Rive',
      home: LoginScreen(),
    );
  }
}
