import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          height: 320,
          child: RiveAnimation.asset(
            'assets/login-bear-animation.riv',
            artboard: 'OsoLogin',
            animations: ['Parpadeo'],
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
