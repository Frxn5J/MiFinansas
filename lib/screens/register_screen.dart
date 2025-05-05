import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final Color orangeColor = const Color(0xFFFFA46E);

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

              // Título
              const Text(
                'Registro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // USUARIO
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _inputField(icon: Icons.person, hint: 'Usuario', color: orangeColor),

              const SizedBox(height: 20),

              // CORREO
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Correo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _inputField(icon: Icons.email, hint: 'Correo', color: orangeColor),

              const SizedBox(height: 20),

              // CONTRASEÑA
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contraseña',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _inputField(icon: Icons.lock, hint: '*************', color: orangeColor, obscure: true),

              const SizedBox(height: 20),

              // REPITE CONTRASEÑA
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Repite Contraseña',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _inputField(icon: Icons.lock_outline, hint: '*************', color: orangeColor, obscure: true),

              const SizedBox(height: 40),

              // BOTÓN REGISTRAR
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Registrar',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required IconData icon,
    required String hint,
    required Color color,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: TextField(
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
