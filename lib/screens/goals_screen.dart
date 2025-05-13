import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets//add_button.dart';

class GoalsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> goals = [
    {
      'icon': Icons.directions_car,
      'color': Colors.amber,
      'label': 'Carro',
      'amount': 150000.00,
      'from': '10/04/2025',
      'to': '10/04/2026'
    },
    {
      'icon': Icons.phone_iphone,
      'color': Colors.pink,
      'label': 'Celular',
      'amount': 8000.00,
      'from': '10/04/2025',
      'to': '10/04/2026'
    },
    {
      'icon': Icons.memory,
      'color': Colors.green,
      'label': 'RTX 5090',
      'amount': 60000.00,
      'from': '10/04/2025',
      'to': '10/04/2026'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(fontFamily: 'TiltNeon');

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: RegistroFAB(),
      body: ListView(
        children: [
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          // Formulario Agregar Meta
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.color_lens, color: Colors.deepOrangeAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text("AGREGAR META", style: TextStyle(fontFamily: 'TiltNeon', fontSize: 18)),
                      ),
                      Icon(Icons.add),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'NOMBRE',
                      labelStyle: labelStyle,
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text("META", style: labelStyle),
                        const SizedBox(height: 8),
                        Text("\$00.00 MXN",
                            style: TextStyle(fontFamily: 'TiltNeon', fontSize: 28, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text("Periodo", style: labelStyle),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DateBox(label: 'DE'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DateBox(label: 'HASTA'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Lista de metas
          for (var goal in goals)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: goal['color'].withOpacity(0.2),
                          child: Icon(goal['icon'], color: goal['color']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(goal['label'], style: TextStyle(fontFamily: 'TiltNeon', fontSize: 18)),
                        ),
                        Container(
                          height: 8,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: goal['color'],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text("\$${goal['amount'].toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(goal['from'], style: TextStyle(fontSize: 12)),
                        Text(goal['to'], style: TextStyle(fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Monto + botón Agregar
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text("\$00.00 MXN",
                        style: TextStyle(
                            fontFamily: 'TiltNeon', fontSize: 28, color: Colors.grey[600])),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("Agregar", style: TextStyle(fontFamily: 'TiltNeon')),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateBox extends StatelessWidget {
  final String label;

  const DateBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontFamily: 'TiltNeon')),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_today, size: 16),
              SizedBox(width: 8),
              Text("dd/mm/yyyy", style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
