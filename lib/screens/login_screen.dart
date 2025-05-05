import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
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

              // Icono circular
              CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey.shade300,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: orangeColor,
                  child: const Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              // Título
              Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // Etiqueta Usuario
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Usuario',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // Campo Usuario
              Container(
                decoration: BoxDecoration(
                  color: orangeColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    hintText: 'Usuario',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              // Etiqueta Contraseña
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contraseña',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),

              // Campo Contraseña
              Container(
                decoration: BoxDecoration(
                  color: orangeColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                    hintText: 'Contraseña',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 12),

              // Olvidaste...
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: RichText(
                  text: TextSpan(
                    text: '¿Olvidaste tu ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'contraseña',
                        style: TextStyle(
                          color: orangeColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' o '),
                      TextSpan(
                        text: 'usuario',
                        style: TextStyle(
                          color: orangeColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '?'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botón Entrar
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 6,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Línea Google
              const Text('O inicia sesión con:'),

              const SizedBox(height: 16),

              // Botón Google
              CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                radius: 28,
                child: Image.asset(
                  'assets/google_logo.png',
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
