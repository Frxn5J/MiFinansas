import 'package:flutter/material.dart';
import 'package:mifinanzas/screens/budget_screen.dart';
import 'package:mifinanzas/screens/dashboard_screen.dart';
import 'package:mifinanzas/screens/transactions_screen.dart';
import 'screens/history_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/profile_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'TiltNeon', // <- Aquí se aplica la fuente global
      ),
      home: budget(),
    );
  }
}

