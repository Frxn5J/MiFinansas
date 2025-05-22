import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mifinanzas/screens/login_screen.dart';
import 'package:mifinanzas/screens/verificar_pin_screen.dart';
import 'package:mifinanzas/widgets/main_navigator.dart';

class SplashRedirector extends StatelessWidget {
  const SplashRedirector({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return LoginScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, pinSnapshot) {
            if (pinSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = pinSnapshot.data!?.data() as Map<String, dynamic>?;
            final pin = data?['pin'];

            if (pin != null && pin.toString().isNotEmpty) {
              return VerificarPinScreen(pinEsperado: pin);
            } else {
              return MainNavigation();
            }
          },
        );
      },
    );
  }
}
