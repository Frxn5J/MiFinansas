import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/fab_expandible.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets//add_button.dart';
import '../services/firestore_service.dart';

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
      floatingActionButton: FABExpandible(),
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
                            children: _categoriasGraficadas.entries.map((e) {
                              return _buildLegendItem(e.key, e.value);
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text(
                                'Balance del mes:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(text: '\$${_calcularBalanceMensual().toStringAsFixed(2)}'),
                                      const TextSpan(
                                        text: ' MXN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
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
                          ...transaccionesFiltradas.map((trans) => _buildItem(trans)).toList(),
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
                    if (index < 0 || index >= entries.length) {
                      _indiceTocado = null;
                    } else {
                      _indiceTocado = index;
                    }
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
