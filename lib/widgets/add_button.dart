import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                right: 16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _crearNuevaCategoria
                        ? TextFormField(
                            decoration: InputDecoration(labelText: 'Nueva Categoría'),
                            onChanged: (value) => _nuevaCategoria = value,
                          )
                        : FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('transacciones')
                                .where('usuarioId', isEqualTo: user.uid)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }
                              final categorias = snapshot.data!.docs
                                  .map((doc) => doc['categoria'].toString())
                                  .toSet()
                                  .toList();
                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(labelText: 'Categoría'),
                                items: categorias
                                    .map((cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        ))
                                    .toList(),
                                onChanged: (val) => _categoria = val,
                              );
                            },
                          ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _crearNuevaCategoria = !_crearNuevaCategoria;
                          if (!_crearNuevaCategoria) {
                            _nuevaCategoria = null;
                          }
                        });
                      },
                      child: Text(_crearNuevaCategoria
                          ? 'Seleccionar Categoría Existente'
                          : 'Crear Nueva Categoría'),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Título'),
                      onChanged: (val) => _titulo = val,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Monto'),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _monto = int.tryParse(val) ?? 0,
                    ),
                    Row(
                      children: [
                        Text("Tipo: "),
                        Switch(
                          value: _tipo,
                          onChanged: (val) {
                            setModalState(() {
                              _tipo = val;
                            });
                          },
                        ),
                        Text(_tipo ? 'Ingreso' : 'Gasto'),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Fecha: ${_fecha.toLocal()}".split(' ')[0]),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _fecha,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != _fecha)
                              setModalState(() {
                                _fecha = picked;
                              });
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Presupuesto'),
                      onChanged: (val) => _presupuestoSeleccionado = val,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final categoriaFinal = _crearNuevaCategoria
                            ? _nuevaCategoria
                            : _categoria;

                        if (categoriaFinal == null || categoriaFinal.isEmpty)
                          return;

                        await FirebaseFirestore.instance
                            .collection('transacciones')
                            .add({
                          'categoria': categoriaFinal,
                          'fecha': Timestamp.fromDate(_fecha),
                          'monto': _monto,
                          'tipo': _tipo,
                          'titulo': _titulo,
                          'usuarioId': user.uid,
                          'presupuesto': _presupuestoSeleccionado ?? '',
                        });

                        Navigator.of(context).pop();
                      },
                      child: Text('Guardar'),
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
      child: Icon(Icons.add),
    );
  }
}
