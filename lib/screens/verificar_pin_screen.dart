import 'package:flutter/material.dart';
import '../widgets/main_navigator.dart';

class VerificarPinScreen extends StatefulWidget {
  final String pinEsperado;

  const VerificarPinScreen({required this.pinEsperado});

  @override
  _VerificarPinScreenState createState() => _VerificarPinScreenState();
}

class _VerificarPinScreenState extends State<VerificarPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  void _verificarPin() async {
    if (_pinController.text == widget.pinEsperado) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainNavigation()));
    } else {
      setState(() => _error = 'PIN incorrecto');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color naranja = Color(0xFFFFA46E);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF2E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  backgroundColor: naranja,
                  radius: 36,
                  child: Icon(Icons.lock_outline, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ingresa tu PIN',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'PIN de 4 dígitos',
                    errorText: _error,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: naranja),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                  onSubmitted: (_) => _verificarPin(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verificarPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
