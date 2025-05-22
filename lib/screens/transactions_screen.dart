import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/fab_expandible.dart';

class transactions extends StatefulWidget {
  const transactions({super.key});
  @override
  State<transactions> createState() => _transactionsState();
}

class _transactionsState extends State<transactions> {
  List<Map<String, dynamic>> _transacciones = [];
  String _graficoActual = 'Ambos';
  Map<String, Color> _categoriasGraficadas = {};
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _indiceTocado;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('transacciones')
          .where('usuarioId', isEqualTo: user.uid)
          .orderBy('fecha', descending: true)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _transacciones = snapshot.docs.map((doc) => doc.data()).toList();
        });
      });
    }
  }

  double _calcularBalanceMensual() {
    final ahora = DateTime.now();
    double entradas = 0;
    double salidas = 0;

    for (var trans in _transacciones) {
      final fecha = (trans['fecha'] as Timestamp).toDate();
      if (fecha.month == ahora.month && fecha.year == ahora.year) {
        final monto = (trans['monto'] as num).toDouble();
        final tipo = trans['tipo'] as bool;
        if (tipo) {
          entradas += monto;
        } else {
          salidas += monto;
        }
      }
    }
    return entradas - salidas;
  }

  bool _esMismaFecha(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> transaccionesFiltradas = _transacciones.where((trans) {
      final fecha = (trans['fecha'] as Timestamp).toDate();

      if (_fechaInicio == null) return true;
      if (_fechaInicio != null && _fechaFin == null) {
        return _esMismaFecha(fecha, _fechaInicio!);
      }
      if (_fechaInicio != null && _fechaFin != null) {
        return fecha.isAfter(_fechaInicio!.subtract(const Duration(days: 1))) &&
            fecha.isBefore(_fechaFin!.add(const Duration(days: 1)));
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FABExpandible(),
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 1, color: Colors.grey.shade300),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
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
                        SizedBox(height: 240, child: _buildGraficoPie(transaccionesFiltradas)),
                        const SizedBox(height: 16),
                        Center(
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _categoriasGraficadas.entries.map((e) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 12, height: 12, color: e.value),
                                  const SizedBox(width: 4),
                                  Text(
                                    e.key,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Balance del mes:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${_calcularBalanceMensual().toStringAsFixed(2)} MXN',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MOVIMIENTOS POR MES',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_month, size: 28),
                              onPressed: () => _seleccionarRangoFecha(context),
                            ),
                          ],
                        ),
                        if (_fechaInicio != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _fechaFin == null
                                ? 'Fecha: ${_formatearFecha(_fechaInicio!)}'
                                : 'De ${_formatearFecha(_fechaInicio!)} a ${_formatearFecha(_fechaFin!)}',
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ...transaccionesFiltradas.map((trans) {
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
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        titulo,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Row(
                                      children: [
                                        Text(
                                          '${tipo ? '+' : '-'}\$${monto.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: tipo ? Colors.green : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Icon(
                                          tipo ? Icons.arrow_upward : Icons.arrow_downward,
                                          color: tipo ? Colors.green : Colors.red,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ],
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

  String _formatearFecha(DateTime fecha) {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]} ${fecha.year}';
  }

  Widget _buildGraficoPie(List<Map<String, dynamic>> filtradas) {
    List<Map<String, dynamic>> datosGraficar;
    if (_graficoActual == 'Gastos') {
      datosGraficar = filtradas.where((t) => t['tipo'] == false).toList();
    } else if (_graficoActual == 'Entradas') {
      datosGraficar = filtradas.where((t) => t['tipo'] == true).toList();
    } else {
      datosGraficar = filtradas;
    }

    Map<String, double> categorias = {};
    for (var trans in datosGraficar) {
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

    double total = categorias.values.fold(0, (a, b) => a + b);
    int index = 0;
    _categoriasGraficadas.clear();

    final entries = categorias.entries.toList();

    final sections = entries.map((e) {
      final color = colores[index % colores.length];
      _categoriasGraficadas[e.key] = color;
      final touched = _indiceTocado == index;
      final radius = touched ? 60.0 : 50.0;
      index++;
      return PieChartSectionData(
        value: e.value,
        color: color,
        radius: radius,
        title: '',
      );
    }).toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sections: sections,
            sectionsSpace: 2,
            centerSpaceRadius: 70,
            startDegreeOffset: 180,
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                if (event is FlTapUpEvent) {
                  final index = response?.touchedSection?.touchedSectionIndex ?? -1;
                  setState(() {
                    _indiceTocado = (index >= 0 && index < entries.length) ? index : null;
                  });
                }
              },
            ),
          ),
        ),
        if (_indiceTocado != null && _indiceTocado! >= 0 && _indiceTocado! < entries.length)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entries[_indiceTocado!].key,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${entries[_indiceTocado!].value.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '${(entries[_indiceTocado!].value / total * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _seleccionarRangoFecha(BuildContext context) async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _fechaInicio != null && _fechaFin != null
          ? DateTimeRange(start: _fechaInicio!, end: _fechaFin!)
          : null,
    );

    if (rango != null) {
      setState(() {
        _fechaInicio = rango.start;
        _fechaFin = rango.end;
      });
    }
  }
}
