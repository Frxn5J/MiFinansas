import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets//add_button.dart';

class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {"icon": Icons.home, "label": "Vivienda", "amount": -3000},
    {"icon": Icons.logout, "label": "Salidas", "amount": -600},
    {"icon": Icons.videogame_asset, "label": "Entretenimiento", "amount": -200},
    {"icon": Icons.work, "label": "Quincena", "amount": 5000},
    {"icon": Icons.directions_bus, "label": "Transporte", "amount": -100},
    {"icon": Icons.fastfood, "label": "Comida", "amount": -500},
    {"icon": Icons.loop, "label": "Suscripciones", "amount": -69},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: RegistroFAB(),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterButton(icon: Icons.local_offer, label: 'Categoría'),
                FilterButton(icon: Icons.calendar_today, label: 'Fecha'),
                FilterButton(icon: Icons.attach_money, label: 'Monto'),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Hoy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isIncome = item['amount'] > 0;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(item['icon'], color: Colors.orange),
                    ),
                    title: Text(
                      item['label'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("10 de Abril"),
                    trailing: Text(
                      "${isIncome ? '+' : ''}\$${item['amount'].toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green : Colors.red[800],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const FilterButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
