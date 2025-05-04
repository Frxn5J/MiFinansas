import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/history_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/bottom_navbar.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    dashboard(),           // Home
    budget(),              // Estadísticas
    HistoryScreen(),       // Historial
    GoalsScreen(),         // Dinero
    transactions(),        // Registros
  ];

  final List<String> _titles = [
    'Resumen',
    'Presupuestos',
    'Historial',
    'Metas de ahorro',
    'Transacciones',
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: 'TiltNeon', // si estás usando esa fuente
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _goToProfile,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
