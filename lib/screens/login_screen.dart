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

  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      'Login Machine',
    );

    if (_controller == null) {
      debugPrint('Rive: No se encontro Login Machine');
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
                  onChanged: (value) {
                    _isHandsUp?.change(false);
                    _isChecking?.change(true);
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email@ejemplo.com',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    _isChecking?.change(false);
                    _isHandsUp?.change(true);
                  },
                  obscureText: _isObscure,
                  decoration: InputDecoration(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
