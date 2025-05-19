import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistroFAB extends StatefulWidget {
  const RegistroFAB({Key? key}) : super(key: key);

  @override
  _RegistroFABState createState() => _RegistroFABState();
}

class _RegistroFABState extends State<RegistroFAB> {
  final _formKey = GlobalKey<FormState>();
  String? _categoria;
  String? _nuevaCategoria;
  bool _crearNuevaCategoria = false;
  DateTime _fecha = DateTime.now();
  int _monto = 0;
  bool _tipo = false; // false = Gasto, true = Ingreso
  String _titulo = '';
  String? _presupuestoId;

  Future<void> _mostrarFormulario(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión.')),
      );
      return;
    }
    final presupuestosRef = FirebaseFirestore.instance.collection('presupuestos');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Categoría
                      _crearNuevaCategoria
                          ? TextFormField(
                              decoration: const InputDecoration(labelText: 'Nueva Categoría'),
                              onChanged: (val) => _nuevaCategoria = val,
                            )
                          : FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('transacciones')
                                  .where('usuarioId', isEqualTo: user.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                final categorias = snapshot.data!.docs
                                    .map((doc) => doc['categoria'].toString())
                                    .toSet()
                                    .toList();
                                return DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(labelText: 'Categoría'),
                                  items: categorias
                                      .map((cat) => DropdownMenuItem(
                                            value: cat,
                                            child: Text(cat),
                                          ))
                                      .toList(),
                                  onChanged: (val) => setModalState(() => _categoria = val),
                                );
                              },
                            ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _crearNuevaCategoria = !_crearNuevaCategoria;
                            if (!_crearNuevaCategoria) _nuevaCategoria = null;
                          });
                        },
                        child: Text(_crearNuevaCategoria
                            ? 'Seleccionar Categoría Existente'
                            : 'Crear Nueva Categoría'),
                      ),

                      // Título
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Título'),
                        onChanged: (val) => _titulo = val,
                      ),
                      
                      // Monto
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Monto'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _monto = int.tryParse(val) ?? 0,
                      ),

                      // Tipo
                      Row(
                        children: [
                          const Text('Tipo: '),
                          Switch(
                            value: _tipo,
                            onChanged: (val) => setModalState(() => _tipo = val),
                          ),
                          Text(_tipo ? 'Gasto' : 'Ingreso'),
                        ],
                      ),

                      // Fecha
                      Row(
                        children: [
                          Text('Fecha: ${_fecha.toLocal()}'.split(' ')[0]),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _fecha,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setModalState(() => _fecha = picked);
                            },
                          ),
                        ],
                      ),

                      // Presupuesto
                      FutureBuilder<QuerySnapshot>(
                        future: presupuestosRef
                            .where('usuarioId', isEqualTo: user.uid)
                            .get(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const CircularProgressIndicator();
                          final docs = snap.data!.docs;
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Presupuesto'),
                            items: docs
                                .map((d) => DropdownMenuItem(
                                      value: d.id,
                                      child: Text(d['nombre']),
                                    ))
                                .toList(),
                            onChanged: (val) => setModalState(() => _presupuestoId = val),
                            validator: (val) => val == null ? 'Selecciona un presupuesto' : null,
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final categoriaFinal =
                              _crearNuevaCategoria ? _nuevaCategoria : _categoria;
                          if (categoriaFinal == null || categoriaFinal.isEmpty) return;

                          // Agregar transacción
                          final transRef = FirebaseFirestore.instance.collection('transacciones');
                          await transRef.add({
                            'categoria': categoriaFinal,
                            'fecha': Timestamp.fromDate(_fecha),
                            'monto': _monto,
                            'tipo': _tipo,
                            'titulo': _titulo,
                            'usuarioId': user.uid,
                            'presupuestoId': _presupuestoId,
                          });

                          // Actualizar presupuesto
                          final budgetDoc = presupuestosRef.doc(_presupuestoId);
                          final delta = _tipo ? -_monto : _monto;
                          await budgetDoc.update({'montoActual': FieldValue.increment(delta)});

                          Navigator.of(context).pop();
                        },
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _mostrarFormulario(context),
      child: const Icon(Icons.add),
    );
  }
}
