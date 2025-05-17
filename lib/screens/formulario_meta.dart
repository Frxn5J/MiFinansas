import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class FormularioMeta extends StatefulWidget {
  @override
  _FormularioMetaState createState() => _FormularioMetaState();
}

class _FormularioMetaState extends State<FormularioMeta> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _montoController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  IconData? _iconoSeleccionado;
  Color? _colorSeleccionado;

  final List<IconData> _iconosDisponibles = [
    Icons.directions_car,
    Icons.phone_iphone,
    Icons.home,
    Icons.flight,
    Icons.star,
    Icons.savings,
    Icons.computer,
    Icons.camera_alt,
    Icons.sports_esports,
    Icons.school,
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.local_hospital,
    Icons.pets,
    Icons.work,
    Icons.favorite,
    Icons.headphones,
    Icons.book,
    Icons.gavel,
    Icons.tv,
    Icons.fitness_center,
    Icons.music_note,
    Icons.local_florist,
    Icons.watch,
    Icons.wallet,
    Icons.directions_bike,
    Icons.luggage,
    Icons.icecream,
    Icons.palette,
    Icons.local_cafe,
  ];

  void _mostrarColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = _colorSeleccionado ?? Colors.blue;
        return AlertDialog(
          title: Text('Selecciona un color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
              enableAlpha: false,
              labelTypes: const [ColorLabelType.hex],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Seleccionar'),
              onPressed: () {
                setState(() => _colorSeleccionado = tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _guardarMeta() async {
    final user = FirebaseAuth.instance.currentUser;

    print("🔍 Iniciando proceso de guardado...");
    if (user == null) {
      print("⛔ Usuario no autenticado.");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Debes iniciar sesión.')));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print("⛔ Formulario no válido.");
      return;
    }

    print("✅ Usuario autenticado: \${user.uid}");
    print("📄 Datos a guardar:");
    print("  Nombre: \${_nombreController.text}");
    print("  Monto: \${_montoController.text}");
    print("  Fecha Inicio: \$_fechaInicio");
    print("  Fecha Fin: \$_fechaFin");
    print("  Icono: \${_iconoSeleccionado?.codePoint}");
    print("  Color: \${_colorSeleccionado?.value}");

    try {
      await FirebaseFirestore.instance.collection('metas_ahorro').add({
        'nombre': _nombreController.text.trim(),
        'montoMeta': double.tryParse(_montoController.text.trim()) ?? 0,
        'fechaInicio': _fechaInicio != null ? Timestamp.fromDate(_fechaInicio!) : null,
        'fechaFin': _fechaFin != null ? Timestamp.fromDate(_fechaFin!) : null,
        'icono': _iconoSeleccionado?.codePoint,
        'color': _colorSeleccionado?.value,
        'usuarioId': user.uid,
        'acumulado': 0,
      });

      print("✅ Meta guardada correctamente en Firestore.");
      Navigator.of(context).pop();
    } catch (e) {
      print("❌ Error al guardar en Firestore: \$e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Text("Agregar Meta", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre de la meta', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Ingrese un nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoController,
                decoration: InputDecoration(labelText: 'Monto meta', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(_fechaInicio == null
                          ? 'Desde'
                          : DateFormat.yMMMd('es_MX').format(_fechaInicio!)),
                      trailing: Icon(Icons.date_range),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _fechaInicio = picked);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(_fechaFin == null
                          ? 'Hasta'
                          : DateFormat.yMMMd('es_MX').format(_fechaFin!)),
                      trailing: Icon(Icons.date_range),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _fechaFin = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Elige un icono:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: GridView.count(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: _iconosDisponibles.map((icono) {
                    final isSelected = _iconoSeleccionado == icono;
                    return IconButton(
                      icon: Icon(icono, color: isSelected ? Colors.deepOrange : Colors.grey),
                      onPressed: () => setState(() => _iconoSeleccionado = icono),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              Text("Color seleccionado:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _mostrarColorPicker,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: _colorSeleccionado ?? Colors.grey,
                  child: Icon(Icons.edit, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save),
                  label: Text("Guardar Meta"),
                  onPressed: _guardarMeta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
