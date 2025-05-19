import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/fab_expandible.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _uid;
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  RangeValues? _amountRange;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser?.uid;
  }

  /// Resets all filters
  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDateRange = null;
      _amountRange = null;
    });
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterButton(
            icon: Icons.local_offer,
            label: 'Categoría',
            onPressed: _pickCategory,
          ),
          _buildFilterButton(
            icon: Icons.calendar_today,
            label: 'Fecha',
            onPressed: _pickDateRange,
          ),
          _buildFilterButton(
            icon: Icons.attach_money,
            label: 'Monto',
            onPressed: _pickAmountRange,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
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
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCategory() async {
    final categories = ['Vivienda', 'Comida', 'Transporte', 'Entretenimiento'];
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Selecciona categoría', style: TextStyle(color: Colors.black)),
        children: categories
            .map((c) => SimpleDialogOption(
                  child: Text(c, style: const TextStyle(color: Colors.black)),
                  onPressed: () => Navigator.pop(context, c),
                ))
            .toList(),
      ),
    );
    if (selected != null) setState(() => _selectedCategory = selected);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.orange,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (result != null) setState(() => _selectedDateRange = result);
  }

  Future<void> _pickAmountRange() async {
    final initial = _amountRange ?? const RangeValues(-10000, 10000);
    RangeValues tempRange = initial;
    final result = await showDialog<RangeValues>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rango de monto', style: TextStyle(color: Colors.black)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RangeSlider(
                min: -10000,
                max: 10000,
                divisions: 100,
                labels: RangeLabels(tempRange.start.toStringAsFixed(0), tempRange.end.toStringAsFixed(0)),
                values: tempRange,
                onChanged: (r) => setState(() => tempRange = r),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.black))),
          TextButton(onPressed: () => Navigator.pop(context, tempRange), child: const Text('OK', style: TextStyle(color: Colors.black))),
        ],
      ),
    );
    if (result != null) setState(() => _amountRange = result);
  }

  /// Filters docs locally after fetching by userId
  List<QueryDocumentSnapshot> _applyLocalFilters(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      bool keep = true;
      if (_selectedCategory != null) {
        keep &= (doc['categoria'] as String) == _selectedCategory;
      }
      if (_selectedDateRange != null) {
        final ts = doc['fecha'] as Timestamp;
        final date = ts.toDate();
        keep &= date.isAfter(_selectedDateRange!.start.subtract(const Duration(seconds: 1))) &&
                date.isBefore(_selectedDateRange!.end.add(const Duration(seconds: 1)));
      }
      if (_amountRange != null) {
        final amt = (doc['monto'] as num).toDouble();
        keep &= amt >= _amountRange!.start && amt <= _amountRange!.end;
      }
      return keep;
    }).toList();
  }

  /// Groups by 'categoria' and sums 'monto'
  Map<String, double> _groupByCategory(List<QueryDocumentSnapshot> docs) {
    final Map<String, double> data = {};
    for (var doc in docs) {
      final cat = doc['categoria'] as String;
      final amt = (doc['monto'] as num).toDouble();
      data[cat] = (data[cat] ?? 0) + amt;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) return const Center(child: CircularProgressIndicator());
    final filtersActive = _selectedCategory != null || _selectedDateRange != null || _amountRange != null;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FABExpandible(),
      body: Column(
        children: [
          Divider(height: 1, color: Colors.grey.shade300),
          _buildFilters(),
          if (filtersActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, color: Colors.black),
                  label: const Text('Borrar filtros', style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'De ${_selectedDateRange!.start.toShortDateString()} a ${_selectedDateRange!.end.toShortDateString()}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('transacciones')
                  .where('usuarioId', isEqualTo: _uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay transacciones', style: TextStyle(color: Colors.black)));
                }
                // Apply local filters
                final rawDocs = snapshot.data!.docs;
                final filtered = _applyLocalFilters(rawDocs);
                if (filtered.isEmpty) {
                  return const Center(child: Text('Sin resultados para estos filtros', style: TextStyle(color: Colors.black)));
                }
                // Group and display
                final grouped = _groupByCategory(filtered);
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: grouped.entries.map((e) {
                    final isIncome = e.value > 0;
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.category, color: Colors.orange)),
                        title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        subtitle: Text('${e.value.toStringAsFixed(2)} registros', style: TextStyle(color: Colors.grey.shade700)),
                        trailing: Text('${isIncome ? '+' : ''} \$${e.value.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: isIncome ? Colors.green.shade700 : Colors.red.shade800)),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension DateHelpers on DateTime {
  String toShortDateString() => '${day}/${month}/${year}';
}
