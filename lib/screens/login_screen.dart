import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMINumber? _numLook;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;

  @override
  void initState() {
    super.initState();

    _emailFocus.addListener(_updateFocus);
    _passwordFocus.addListener(_updateFocus);
  }

  void _updateFocus() {
    _isChecking?.value = _emailFocus.hasFocus;
    _isHandsUp?.value = _passwordFocus.hasFocus;
  }

  void _onRiveInit(Artboard artboard) {
    debugPrint('RIVE ARTBOARD: ${artboard.name}');

    final controller = StateMachineController.fromArtboard(
      artboard,
      'Login Machine',
    );

    if (controller == null) {
      debugPrint('ERROR: No se encontro Login Machine');
      return;
    }

    artboard.addController(controller);

    _isChecking = controller.findInput<bool>('isChecking') as SMIBool?;

    _isHandsUp = controller.findInput<bool>('isHandsUp') as SMIBool?;

    _numLook = controller.findInput<double>('numLook') as SMINumber?;

    _trigSuccess = controller.findInput<bool>('trigSuccess') as SMITrigger?;

    _trigFail = controller.findInput<bool>('trigFail') as SMITrigger?;

    debugPrint('RIVE: Login Machine cargada');
    debugPrint(
      'RIVE INPUTS: '
      '${controller.inputs.map((input) => input.name).join(", ")}',
    );

    _updateFocus();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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

                const SizedBox(height: 25),

                const Text(
                  'Inicio de sesion',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                TextField(
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electronico',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _numLook?.value = value.length.clamp(0, 30).toDouble();
                  },
                ),

                const SizedBox(height: 20),

                TextField(
                  focusNode: _passwordFocus,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contrasena',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _trigSuccess?.fire();
                  },
                  child: const Text('Probar exito'),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _trigFail?.fire();
                  },
                  child: const Text('Probar error'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
