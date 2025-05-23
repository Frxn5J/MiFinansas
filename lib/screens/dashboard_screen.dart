import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/fab_expandible.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:marquee/marquee.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  double totalEntradas = 0;
  double totalSalidas = 0;
  double saldoDisponible = 0;
  List<Map<String, dynamic>> movimientos = [];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Escuchar cambios en el saldo disponible
      FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .snapshots()
          .listen((docSnapshot) {
        final data = docSnapshot.data();
        if (data != null) {
          setState(() {
            saldoDisponible = (data['saldoDisponible'] ?? 0).toDouble();
          });
        }
      });

      // Escuchar cambios en las transacciones
      FirebaseFirestore.instance
          .collection('transacciones')
          .where('usuarioId', isEqualTo: user.uid)
          .orderBy('fecha', descending: true)
          .snapshots()
          .listen((snapshot) {
        double entradas = 0;
        double salidas = 0;
        List<Map<String, dynamic>> tempMov = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final monto = (data['monto'] ?? 0).toDouble();
          final tipo = data['tipo'];
          final titulo = data['titulo'] ?? 'Sin título';
          final fecha = (data['fecha'] as Timestamp).toDate();

          if (tipo == true) {
            entradas += monto;
          } else {
            salidas += monto;
          }

          tempMov.add({
            'titulo': titulo,
            'monto': monto,
            'tipo': tipo,
            'fecha': fecha,
          });
        }

        setState(() {
          totalEntradas = entradas;
          totalSalidas = salidas;
          movimientos = tempMov;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FABExpandible(),
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 1, color: Colors.grey.shade300),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Tarjeta resumen
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: PieChartWidget(
                                entradas: totalEntradas,
                                salidas: totalSalidas,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircleAvatar(radius: 6, backgroundColor: Color(0xFFFCD34D)),
                                SizedBox(width: 8),
                                Text('Salidas', style: TextStyle(fontWeight: FontWeight.w500)),
                                SizedBox(width: 20),
                                CircleAvatar(radius: 6, backgroundColor: Color(0xFFFFA07A)),
                                SizedBox(width: 8),
                                Text('Entradas', style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Saldo disponible',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(
                                  '\$${saldoDisponible.toStringAsFixed(2)} MXN',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Movimientos recientes
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MOVIMIENTOS RECIENTES',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            ...movimientos.map((mov) {
                              final fechaStr = DateFormat.yMMMMEEEEd('es_MX').format(mov['fecha']);
                              final monto = mov['tipo'] ? "+\$${mov['monto']}" : "-\$${mov['monto']}";
                              final icono = mov['tipo'] ? Icons.arrow_upward : Icons.arrow_downward;
                              final color = mov['tipo'] ? Colors.green : Colors.red;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fechaStr, style: const TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 10),
                                  movimientoItem(mov['titulo'], monto, icono, color),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget movimientoItem(String titulo, String monto, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          // TÍTULO CON DETECCIÓN DE OVERFLOW
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textPainter = TextPainter(
                  text: TextSpan(
                    text: titulo,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  maxLines: 1,
                  textDirection: ui.TextDirection.ltr,
                )..layout(maxWidth: constraints.maxWidth);

                final isOverflowing = textPainter.didExceedMaxLines;

                if (isOverflowing) {
                  return SizedBox(
                    height: 24,
                    child: Marquee(
                      text: titulo,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      scrollAxis: Axis.horizontal,
                      blankSpace: 20.0,
                      velocity: 30.0,
                      pauseAfterRound: const Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: const Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  );
                } else {
                  return Text(
                    titulo,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          // MONTO + ICONO
          Row(
            children: [
              Text(
                monto,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(width: 5),
              Icon(icono, color: color, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final double entradas;
  final double salidas;

  const PieChartWidget({super.key, required this.entradas, required this.salidas});

  @override
  Widget build(BuildContext context) {
    final total = entradas + salidas;
    final double entradasPercent = total == 0 ? 0 : (entradas / total) * 100;
    final double salidasPercent = total == 0 ? 0 : (salidas / total) * 100;

    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 0,
        sections: [
          PieChartSectionData(
            color: const Color(0xFFFFA07A),
            value: entradasPercent,
            title: '${entradasPercent.toStringAsFixed(0)}%',
            radius: 100,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: const Color(0xFFFCD34D),
            value: salidasPercent,
            title: '${salidasPercent.toStringAsFixed(0)}%',
            radius: 100,
            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
