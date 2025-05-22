import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'screens/splash_redirector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es_MX', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'TiltNeon'),
      home: FlutterSplashScreen(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.white,
        nextScreen: const SplashRedirector(),
        splashScreenBody: Center(
          child: Image.asset(
            'assets/logo.png',
            width: 256,
            height: 256,
          ),
        ),
      ),
    );
  }
}
