import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModalAjusteMeta extends StatefulWidget {
  final String metaId;
  final Map<String, dynamic> data;

  const ModalAjusteMeta({super.key, required this.metaId, required this.data});

  @override
  State<ModalAjusteMeta> createState() => _ModalAjusteMetaState();
}

class _ModalAjusteMetaState extends State<ModalAjusteMeta> {
  final TextEditingController _montoController = TextEditingController();

  void _actualizarMeta(bool sumar) async {
    final monto = double.tryParse(_montoController.text.trim()) ?? 0;

    if (monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un monto válido.')),
      );
      return;
    }

    final acumuladoActual = (widget.data['acumulado'] ?? 0).toDouble();
    final montoMeta = (widget.data['montoMeta'] ?? 0).toDouble();

    double nuevoAcumulado;
    if (sumar) {
      nuevoAcumulado = acumuladoActual + monto;
      // No permitir superar la meta
      if (nuevoAcumulado > montoMeta) {
        nuevoAcumulado = montoMeta;
      }
    } else {
      nuevoAcumulado = acumuladoActual - monto;
      // No permitir negativos
      if (nuevoAcumulado < 0) {
        nuevoAcumulado = 0;
      }
    }

    final bool completada = nuevoAcumulado >= montoMeta;

    try {
      await FirebaseFirestore.instance
          .collection('metas_ahorro')
          .doc(widget.metaId)
          .update({
        'acumulado': nuevoAcumulado,
        'completada': completada,
      });

      if (completada) {
        // Mostrar felicitación
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¡Meta completada!'),
            content: const Text('Felicidades, has alcanzado tu objetivo de ahorro.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Cerrar'),
              )
            ],
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Modificar Meta", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Meta: ${widget.data['nombre']}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),

          // Monto en grande
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '\$',
                  style: TextStyle(fontSize: 32, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _montoController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.grey,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      hintText: "00.00",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Text(
                  'MXN',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar"),
                  onPressed: () => _actualizarMeta(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.remove),
                  label: const Text("Quitar"),
                  onPressed: () => _actualizarMeta(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
