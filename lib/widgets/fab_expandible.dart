import 'package:flutter/material.dart';
import '../screens/formulario_transaccion.dart';
import 'add_button.dart';
import '../screens/formulario_meta.dart';

class FABExpandible extends StatefulWidget {
  @override
  _FABExpandibleState createState() => _FABExpandibleState();
}

class _FABExpandibleState extends State<FABExpandible> with SingleTickerProviderStateMixin {
  bool _abierto = false;

  @override
  Widget build(BuildContext context) {
    const Color verdeFinanzas = Color(0xFF4CAF50);
    const Color grisClaro = Color(0xFFE0E0E0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_abierto) ...[
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
          const SizedBox(height: 10),
          RegistroFAB(),
          const SizedBox(height: 10),
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
