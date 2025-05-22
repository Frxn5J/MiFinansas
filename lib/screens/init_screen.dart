import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import '../widgets/main_navigator.dart';

class InitScreen extends StatefulWidget {
  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  Widget _pantalla = const CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => _pantalla = LoginScreen());
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final pinValidado = prefs.getBool('pinValidado') ?? false;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    final tienePin = doc.data()?['pin'] != null;

    if (tienePin && !pinValidado) {
      setState(() => _pantalla = _PantallaPedirPin(user.uid, doc.data()?['pin']));
    } else {
      setState(() => _pantalla = MainNavigation());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pantalla),
    );
  }
}

class _PantallaPedirPin extends StatefulWidget {
  final String uid;
  final String pinGuardado;

  const _PantallaPedirPin(this.uid, this.pinGuardado);

  @override
  State<_PantallaPedirPin> createState() => _PantallaPedirPinState();
}

class _PantallaPedirPinState extends State<_PantallaPedirPin> {
  final pinController = TextEditingController();

  void _validarPin() async {
    if (pinController.text.trim() == widget.pinGuardado) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pinValidado', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN incorrecto")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Ingresa tu PIN para continuar", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 4,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _validarPin,
            child: const Text("Ingresar"),
          )
        ],
      ),
    );
  }
}

