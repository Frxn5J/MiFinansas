import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RegistroFAB extends StatefulWidget {
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
  bool _tipo = false;
  String _titulo = '';
  String? _presupuestoSeleccionado;

  void _mostrarFormulario(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes iniciar sesión para continuar.')),
      );
      return;
    }

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Registrar transacción",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Categoría
                      _crearNuevaCategoria
                          ? TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Nueva Categoría',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) => _nuevaCategoria = value,
                            )
                          : FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('transacciones')
                                  .where('usuarioId', isEqualTo: user.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const CircularProgressIndicator();
                                final categorias = snapshot.data!.docs
                                    .map((doc) => doc['categoria'].toString())
                                    .toSet()
                                    .toList();
                                return DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Categoría',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: categorias
                                      .map((cat) => DropdownMenuItem(
                                            value: cat,
                                            child: Text(cat),
                                          ))
                                      .toList(),
                                  onChanged: (val) => _categoria = val,
                                  validator: (val) => val == null && !_crearNuevaCategoria
                                      ? 'Selecciona una categoría'
                                      : null,
                                );
                              },
                            ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              _crearNuevaCategoria = !_crearNuevaCategoria;
                              if (!_crearNuevaCategoria) _nuevaCategoria = null;
                            });
                          },
                          child: Text(
                            _crearNuevaCategoria
                                ? 'Seleccionar Categoría Existente'
                                : 'Crear Nueva Categoría',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Título
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => _titulo = val,
                        validator: (val) => val == null || val.isEmpty ? 'Ingresa un título' : null,
                      ),
                      const SizedBox(height: 8),

                      // Monto
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Monto',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _monto = int.tryParse(val) ?? 0,
                        validator: (val) => (val == null || int.tryParse(val) == null || int.tryParse(val)! <= 0)
                            ? 'Ingresa un monto válido'
                            : null,
                      ),
                      const SizedBox(height: 8),

                      // Tipo
                      Row(
                        children: [
                          const Text("Tipo: "),
                          Switch(
                            value: _tipo,
                            onChanged: (val) {
                              setModalState(() => _tipo = val);
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.red.shade200,
                          ),
                          Text(
                            _tipo ? 'Ingreso' : 'Gasto',
                            style: TextStyle(
                              color: _tipo ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Fecha
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha seleccionada:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat.yMMMMd('es_MX').format(_fecha),
                                style: const TextStyle(fontSize: 16, color: Colors.black87),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _fecha,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null && picked != _fecha) {
                                setModalState(() => _fecha = picked);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Presupuesto
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('presupuestos')
                            .where('usuarioId', isEqualTo: user.uid)
                            .get(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const CircularProgressIndicator();
                          final docs = snap.data!.docs;
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Presupuesto',
                              border: OutlineInputBorder(),
                            ),
                            items: docs
                                .map((d) => DropdownMenuItem(
                                      value: d.id,
                                      child: Text(d['nombre']),
                                    ))
                                .toList(),
                            onChanged: (val) => setModalState(() => _presupuestoSeleccionado = val),
                            validator: (val) => val == null ? 'Selecciona un presupuesto' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Guardar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          
                          icon: const Icon(Icons.save),
                          label: const Text("Guardar"),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            final user = FirebaseAuth.instance.currentUser!;
                            final categoriaFinal = _crearNuevaCategoria ? _nuevaCategoria! : _categoria!;
                            final delta = _tipo ? _monto : -_monto;
                            final presupuestoRef = FirebaseFirestore.instance
                                .collection('presupuestos')
                                .doc(_presupuestoSeleccionado);

                            try {
                              // Registrar transacción
                              await FirebaseFirestore.instance
                                  .collection('transacciones')
                                  .add({
                                'categoria': categoriaFinal,
                                'fecha': Timestamp.fromDate(_fecha),
                                'monto': _monto,
                                'tipo': _tipo,
                                'titulo': _titulo,
                                'usuarioId': user.uid,
                                'presupuestoId': _presupuestoSeleccionado,
                              });

                              // Actualizar montoActual del presupuesto
                              await presupuestoRef.update({
                                'montoActual': FieldValue.increment(delta),
                              });

                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al guardar: \$e')),
                              );
                            }
                          },
                        ),
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
    child: Icon(Icons.add, color: Colors.white),
    backgroundColor: Colors.green,
  );
  }
}
