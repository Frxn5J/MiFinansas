import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/formulario_transaccion.dart';
import '../screens/formulario_meta.dart';

class FABExpandible extends StatefulWidget {
  const FABExpandible({Key? key}) : super(key: key);

  @override
  _FABExpandibleState createState() => _FABExpandibleState();
}

class _FABExpandibleState extends State<FABExpandible> with SingleTickerProviderStateMixin {
  bool _abierto = false;
  final user = FirebaseAuth.instance.currentUser;
  final presupuestosRef = FirebaseFirestore.instance.collection('presupuestos');

  void _abrirFormularioPresupuesto() {
    final nombreCtrl = TextEditingController();
    final montoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo Presupuesto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: montoCtrl,
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
              final montoFijado = double.tryParse(montoCtrl.text) ?? 0;
              if (nombre.isEmpty || montoFijado <= 0) return;

              await presupuestosRef.add({
                'usuarioId': user!.uid,
                'nombre': nombre,
                'montoFijado': montoFijado,
                'montoActual': 0,
              });

              Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    const Color verdeFinanzas = Color(0xFF4CAF50);
    const Color grisClaro = Color(0xFFE0E0E0);
    final isHorizontal = MediaQuery.of(context).orientation == Orientation.landscape;

    final botones = [
      _buildBotonSecundario(
        icono: Icons.account_balance_wallet,
        colorFondo: grisClaro,
        colorIcono: Colors.teal,
        etiqueta: 'Presupuesto',
        onPressed: () {
          setState(() => _abierto = false);
          _abrirFormularioPresupuesto();
        },
      ),
      _buildBotonSecundario(
        icono: Icons.flag,
        colorFondo: grisClaro,
        colorIcono: Colors.blueGrey[700]!,
        etiqueta: 'Meta',
        onPressed: () {
          setState(() => _abierto = false);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => FormularioMeta(),
          );
        },
      ),
      _buildBotonSecundario(
        icono: Icons.swap_horiz,
        colorFondo: grisClaro,
        colorIcono: Colors.green.shade800,
        etiqueta: 'Transacción',
        onPressed: () {
          setState(() => _abierto = false);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => FormularioTransaccion(),
          );
        },
      ),
    ];

    final espaciado = SizedBox(width: isHorizontal ? 10 : 0, height: isHorizontal ? 0 : 10);

    return isHorizontal
        ? Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_abierto) ...[
          for (var b in botones) ...[b, espaciado],
        ],
        FloatingActionButton(
          onPressed: () => setState(() => _abierto = !_abierto),
          backgroundColor: verdeFinanzas,
          child: Icon(_abierto ? Icons.close : Icons.add, color: Colors.white),
        )
      ],
    )
        : Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_abierto) ...[
          for (var b in botones) ...[b, espaciado],
        ],
        FloatingActionButton(
          onPressed: () => setState(() => _abierto = !_abierto),
          backgroundColor: verdeFinanzas,
          child: Icon(_abierto ? Icons.close : Icons.add, color: Colors.white),
        )
      ],
    );
  }

  Widget _buildBotonSecundario({
    required IconData icono,
    required Color colorFondo,
    required Color colorIcono,
    required String etiqueta,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colorFondo,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Tooltip(
          message: etiqueta,
          child: Icon(icono, color: colorIcono),
        ),
      ),
    );
  }
}
