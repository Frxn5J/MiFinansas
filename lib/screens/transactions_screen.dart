import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/bottom_navbar.dart';

class transactions extends StatefulWidget {
  const transactions({super.key});

  @override
  State<transactions> createState() => _transactionsState();
}

class _transactionsState extends State<transactions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
            // Main content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Expense Chart Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Semi-circular chart
                          SizedBox(
                            height: 240,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20), // separa del texto
                              child: PieChartWidget(),
                            ),
                          ),
                          // Legend
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildLegendItem('VIVIENDA', const Color(0xFFFFA07A)),
                              _buildLegendItem('SALIDAS', const Color(0xFFFFD700)),
                              _buildLegendItem('ENTRETENIMIENTO', const Color(0xFFFFB347)),
                              _buildLegendItem('TRANSPORTE', const Color(0xFFF0E68C)),
                              _buildLegendItem('COMIDA', const Color(0xFFFF7F50)),
                              _buildLegendItem('SUSCRIPCIONES', const Color(0xFFFF6347)),
                            ],
                          ),

                          // Monthly expense
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text(
                                'Gasto del mes:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: '\$10,354.50'),
                                    TextSpan(
                                      text: 'MXN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Movements Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Movements header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'MOVIMIENTOS POR MES',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.calendar_month,
                                size: 28,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ],
                          ),

                          // Date header
                          const SizedBox(height: 8),
                          const Text(
                            'Miércoles 12 de febrero 2025',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),

                          // Transaction item
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'REEMBOLSO',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      '+\$240.00',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_upward,
                                      color: Colors.green.shade400,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Second date header
                          const SizedBox(height: 16),
                          const Text(
                            'Lunes 10 de febrero 2025',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),

                          // Spotify transaction
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'SPOTIFY',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      '-\$69.00',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_downward,
                                      color: Colors.red.shade400,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // H-E-B transaction
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'H-E-B AutoCobro',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      '-\$350.00',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_downward,
                                      color: Colors.red.shade400,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Empty transaction slot
                          const SizedBox(height: 8),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 70, // espacio más amplio en el centro
        startDegreeOffset: 180, // comienza desde la mitad
        sections: [
          PieChartSectionData(value: 60, color: Color(0xFFFFA07A), showTitle: false, radius: 50),
          PieChartSectionData(value: 15, color: Color(0xFFFFD700), showTitle: false, radius: 50),
          PieChartSectionData(value: 10, color: Color(0xFFFFB347), showTitle: false, radius: 50),
          PieChartSectionData(value: 8,  color: Color(0xFFF0E68C), showTitle: false, radius: 50),
          PieChartSectionData(value: 5,  color: Color(0xFFFF7F50), showTitle: false, radius: 50),
          PieChartSectionData(value: 2,  color: Color(0xFFFF6347), showTitle: false, radius: 50),
        ],
      ),
    );
  }
}
