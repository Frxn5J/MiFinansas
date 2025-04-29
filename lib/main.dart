import 'package:flutter/material.dart';
import 'screens/history_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'TiltNeon', // <- Aquí se aplica la fuente global
      ),
      home: HistoryScreen(),
    );
  }
}

