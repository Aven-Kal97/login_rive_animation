import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  String? _firebaseError;

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Ingresa tu correo institucional.';
    }

    final institutionalEmail = RegExp(
      r'^[A-Za-z0-9._%+-]+@tecdesoftware\.edu\.mx$',
      caseSensitive: false,
    );

    if (!institutionalEmail.hasMatch(email)) {
      return 'Utiliza un correo @tecdesoftware.edu.mx.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Ingresa una contraseña.';
    }

    if (password.length < 8) {
      return 'Utiliza al menos 8 caracteres.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Agrega al menos una mayúscula.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Agrega al menos una minúscula.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Agrega al menos un número.';
    }

    if (!RegExp(r'[^A-Za-z0-9\s]').hasMatch(password)) {
      return 'Agrega al menos un símbolo.';
    }

    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña.';
    }

    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden.';
    }

    return null;
  }

  Future<void> _register() async {
    if (_isLoading || !_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _firebaseError = null;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'email-already-in-use' => 'Este correo electrónico ya está registrado.',
        'invalid-email' => 'El correo electrónico no es válido.',
        'weak-password' => 'La contraseña es demasiado débil.',
        'network-request-failed' =>
          'No se pudo establecer conexión con Firebase.',
        _ => 'No se pudo completar el registro.',
      };

      setState(() {
        _isLoading = false;
        _firebaseError = message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _firebaseError =
            'No se pudo completar el registro. Inténtalo nuevamente.';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Registro institucional',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crea una cuenta utilizando tu correo institucional.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Correo institucional',
                    hintText: 'usuario@tecdesoftware.edu.mx',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hidePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'La contraseña debe contener:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Mínimo 8 caracteres\n'
                  '• Una letra mayúscula\n'
                  '• Una letra minúscula\n'
                  '• Un número\n'
                  '• Un símbolo especial',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _hideConfirmation,
                  validator: _validateConfirmation,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _hideConfirmation
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _hideConfirmation = !_hideConfirmation;
                        });
                      },
                    ),
                  ),
                ),
                if (_firebaseError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _firebaseError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _register,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Crear cuenta'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Volver al Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
