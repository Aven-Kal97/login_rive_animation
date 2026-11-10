import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  StateMachineController? _controller;
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  Timer? _typingDebounce;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String? emailError;
  String? passError;

  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  void _onLogin() {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    final emailTypedError = isValidEmail(email)
        ? null
        : 'Correo electrónico inválido';

    final passwordTypedError = isValidPassword(pass)
        ? null
        : 'Contraseña inválida';

    setState(() {
      emailError = emailTypedError;
      passError = passwordTypedError;
    });

    FocusScope.of(context).unfocus();

    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0;

    if (emailTypedError == null && passwordTypedError == null) {
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _isHandsUp?.change(false);
        _numLook?.value = 50;
      } else {
        _typingDebounce?.cancel();
        _isChecking?.change(false);
      }
    });

    _passwordFocusNode.addListener(() {
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      'Login Machine',
    );

    if (_controller == null) {
      debugPrint('Rive: No se encontró Login Machine');
      return;
    }

    artboard.addController(_controller!);

    _isChecking = _controller!.findSMI('isChecking') as SMIBool?;
    _isHandsUp = _controller!.findSMI('isHandsUp') as SMIBool?;
    _trigSuccess = _controller!.findSMI('trigSuccess') as SMITrigger?;
    _trigFail = _controller!.findSMI('trigFail') as SMITrigger?;
    _numLook = _controller!.findSMI('numLook') as SMINumber?;

    debugPrint(
      'Rive inputs: '
      'isChecking=${_isChecking != null}, '
      'isHandsUp=${_isHandsUp != null}, '
      'trigSuccess=${_trigSuccess != null}, '
      'trigFail=${_trigFail != null}, '
      'numLook=${_numLook != null}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/Oso_correcto.riv',
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  focusNode: _emailFocusNode,
                  onChanged: (value) {
                    _isHandsUp?.change(false);

                    if (_isChecking == null) return;

                    _isChecking!.change(true);

                    final look = (value.length / 80 * 100).clamp(0.0, 100.0);
                    _numLook?.value = look;

                    _typingDebounce?.cancel();

                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      if (!mounted) return;
                      _isChecking?.change(false);
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    errorText: emailError,
                    hintText: 'Email@ejemplo.com',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passCtrl,
                  focusNode: _passwordFocusNode,
                  onChanged: (value) {
                    _isChecking?.change(false);
                    _isHandsUp?.change(true);
                  },
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    errorText: passError,
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: size.width,
                  child: const Text(
                    'Forgot password?',
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                const SizedBox(height: 10),
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _onLogin,
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}
