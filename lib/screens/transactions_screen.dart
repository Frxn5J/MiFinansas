import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/pie_chart_widget.dart';
import '../services/firestore_service.dart';

class transactions extends StatefulWidget {
  const transactions({super.key});

  @override
  State<transactions> createState() => _transactionsState();
}

class _transactionsState extends State<transactions> {
  List<Map<String, dynamic>> _transacciones = [];
  String _graficoActual = 'Ambos';

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final data = await FirestoreService().getTransacciones();
    setState(() {
      _transacciones = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: DropdownButton<String>(
                              value: _graficoActual,
                              items: ['Gastos', 'Entradas', 'Ambos']
                                  .map((opcion) => DropdownMenuItem(
                                value: opcion,
                                child: Text(opcion),
                              ))
                                  .toList(),
                              onChanged: (valor) {
                                if (valor != null) {
                                  setState(() => _graficoActual = valor);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 240,
                            child: _buildGraficoPie(),
                          ),
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
                          const SizedBox(height: 16),
                          ..._transacciones.map((trans) => _buildItem(trans)).toList(),
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

  Widget _buildItem(Map<String, dynamic> trans) {
    final tipo = trans['tipo'] as bool;
    final titulo = trans['titulo'] ?? '';
    final monto = trans['monto'] ?? 0;
    final fecha = (trans['fecha'] as Timestamp).toDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatearFecha(fecha),
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo.toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Text(
                    '${tipo ? '+' : '-'}\$${monto.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tipo ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    tipo ? Icons.arrow_upward : Icons.arrow_downward,
                    color: tipo ? Colors.green.shade400 : Colors.red.shade400,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${_nombreDia(fecha.weekday)} ${fecha.day} de ${_nombreMes(fecha.month)} ${fecha.year}';
  }

  String _nombreDia(int d) {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return dias[d - 1];
  }

  String _nombreMes(int m) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return meses[m - 1];
  }

  Widget _buildGraficoPie() {
    List<Map<String, dynamic>> filtradas;

    if (_graficoActual == 'Gastos') {
      filtradas = _transacciones.where((t) => t['tipo'] == false).toList();
    } else if (_graficoActual == 'Entradas') {
      filtradas = _transacciones.where((t) => t['tipo'] == true).toList();
    } else {
      filtradas = _transacciones;
    }

    Map<String, double> categorias = {};
    for (var trans in filtradas) {
      final categoria = trans['categoria'] ?? 'Otros';
      final monto = (trans['monto'] as num).toDouble();
      categorias[categoria] = (categorias[categoria] ?? 0) + monto;
    }

    final colores = [
      Color(0xFFFFA07A),
      Color(0xFFFFD700),
      Color(0xFFFFB347),
      Color(0xFFF0E68C),
      Color(0xFFFF7F50),
      Color(0xFFFF6347),
      Colors.teal,
      Colors.purple,
      Colors.blueGrey,
    ];

    int index = 0;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 70,
        startDegreeOffset: 180,
        sections: categorias.entries.map((e) {
          final color = colores[index % colores.length];
          index++;
          return PieChartSectionData(
            value: e.value,
            color: color,
            showTitle: false,
            radius: 50,
          );
        }).toList(),
      ),
    );
  }

}
