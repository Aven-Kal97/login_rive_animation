import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ada_1_angel_lugo/main.dart';
import 'package:ada_1_angel_lugo/screens/login_screen.dart';

void main() {
  test('La aplicación principal se crea correctamente', () {
    const aplicacion = MainApp();

    expect(aplicacion, isA<StatelessWidget>());
  });

  test('La pantalla de inicio de sesión se crea correctamente', () {
    const pantalla = LoginScreen();

    expect(pantalla, isA<StatefulWidget>());
  });
}
