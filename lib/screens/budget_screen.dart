import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navbar.dart';

class budget extends StatefulWidget {
  const budget({super.key});

  @override
  State<budget> createState() => _budgetState();
}

class _budgetState extends State<budget> {
  final user = FirebaseAuth.instance.currentUser;
  final CollectionReference presupuestosRef = FirebaseFirestore.instance.collection('presupuestos');

  Future<void> _showBudgetDialog({DocumentSnapshot? doc}) async {
    final nombreCtrl = TextEditingController(text: doc?.get('nombre') ?? '');
    final montoFijadoCtrl = TextEditingController(text: (doc?.get('montoFijado') ?? '').toString());

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(doc == null ? 'Nuevo Presupuesto' : 'Editar Presupuesto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: montoFijadoCtrl,
              decoration: const InputDecoration(labelText: 'Monto Fijado'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final montoFijado = double.tryParse(montoFijadoCtrl.text) ?? 0;
              if (doc == null) {
                await presupuestosRef.add({
                  'usuarioId': user!.uid,
                  'nombre': nombre,
                  'montoFijado': montoFijado,
                  'montoActual': 0,
                });
              } else {
                await presupuestosRef.doc(doc.id).update({
                  'nombre': nombre,
                  'montoFijado': montoFijado,
                });
              }
              Navigator.pop(context);
            },
            child: Text(doc == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resetear presupuestos'),
        content: const Text('¿Seguro que quieres resetear los presupuestos? Se restaurará el disponible al monto fijado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final batch = FirebaseFirestore.instance.batch();
    final query = await presupuestosRef.where('usuarioId', isEqualTo: user!.uid).get();
    for (var doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final nombre = data['nombre'] as String?;
      if (nombre != 'Efectivo') {
        final montoFijado = (data['montoFijado'] as num).toDouble();
        batch.update(presupuestosRef.doc(doc.id), {'montoActual': montoFijado});
      }
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        onPressed: () => _showBudgetDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(height: 1, color: Colors.grey.shade300),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PRESUPUESTOS MENSUALES',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Resetear presupuestos',
                            onPressed: _confirmReset,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista dinámica de presupuestos
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: presupuestosRef.where('usuarioId', isEqualTo: user!.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return const Center(child: Text('No hay presupuestos'));
                        }
                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final nombre = data['nombre'] ?? '';
                            final montoFijado = data['montoFijado']?.toDouble() ?? 0;
                            final montoActual = data['montoActual']?.toDouble() ?? 0;
                            return InkWell(
                              onTap: () => _showBudgetDialog(doc: doc),
                              child: _buildBudgetItem(nombre, montoFijado, montoActual),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Pie de página
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'ES TODO PARA MOSTRAR',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildBudgetItem(String category, double fixed, double available) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FIJADO', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('\$${fixed.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DISPONIBLE', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('\$${available.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
