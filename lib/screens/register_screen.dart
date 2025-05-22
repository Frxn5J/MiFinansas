import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color orangeColor = const Color(0xFFFFA46E);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _register() async {
    final username = _usernameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm  = _confirmPasswordController.text.trim();

    if (password != confirm) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      await _firestore
          .collection('usuarios')
          .doc(uid)
          .set({
        'usuario': username,
        'email': email,
        'uid': uid,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'saldoDisponible': 0.0,
      });

      Navigator.pop(context);
    } catch (e) {
      _showError('Error al registrar: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text('Registro', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              _buildLabel('Usuario'),
              _inputField(controller: _usernameController, icon: Icons.person, hint: 'Usuario'),
              const SizedBox(height: 20),

              _buildLabel('Correo'),
              _inputField(controller: _emailController, icon: Icons.email, hint: 'Correo'),
              const SizedBox(height: 20),

              _buildLabel('Contraseña'),
              _inputField(controller: _passwordController, icon: Icons.lock, hint: '*************', obscure: true),
              const SizedBox(height: 20),

              _buildLabel('Repite Contraseña'),
              _inputField(controller: _confirmPasswordController, icon: Icons.lock_outline, hint: '*************', obscure: true),
              const SizedBox(height: 40),

              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Registrar', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: orangeColor,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(2, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
