import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/add_button.dart';
import 'package:intl/intl.dart';
import '../widgets/fab_expandible.dart';
import '../widgets/modal_ajuste_meta.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = const TextStyle(fontFamily: 'TiltNeon');
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FABExpandible(),
      body: ListView(
        children: [
          Container(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('metas_ahorro')
                .where('usuarioId', isEqualTo: user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("Aún no has agregado metas de ahorro."),
                ));
              }
              final metas = snapshot.data!.docs;
              return Column(
                children: metas.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final bool completada = data['completada'] == true;
                  final color = Color(data['color'] ?? 0xFFBDBDBD);
                  final icon = IconData(data['icono'] ?? Icons.flag.codePoint, fontFamily: 'MaterialIcons');
                  final nombre = data['nombre'] ?? 'Meta';
                  final monto = data['montoMeta'] ?? 0;
                  final fechaInicio = (data['fechaInicio'] as Timestamp?)?.toDate();
                  final fechaFin = (data['fechaFin'] as Timestamp?)?.toDate();
                  return GestureDetector(
                    onTap: completada
                        ? null // Desactiva el tap si ya se completó
                        : () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ModalAjusteMeta(
                          metaId: doc.id,
                          data: data,
                        ),
                      );
                    },
                    child: Card(
                      color: completada ? Colors.green.shade50 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: completada
                            ? BorderSide(color: Colors.green, width: 1.5)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            if (completada)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.emoji_events, color: Colors.green),
                                  SizedBox(width: 6),
                                  Text(
                                    'Meta cumplida',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            if (completada) const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withOpacity(0.2),
                                  child: Icon(icon, color: color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    nombre,
                                    style: const TextStyle(fontFamily: 'TiltNeon', fontSize: 18),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      LinearProgressIndicator(
                                        value: (data['acumulado'] ?? 0) / (monto == 0 ? 1 : monto),
                                        backgroundColor: Colors.grey[300],
                                        color: color,
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "\$${(data['acumulado'] ?? 0).toStringAsFixed(0)} / \$${monto.toStringAsFixed(0)}",
                                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${(((data['acumulado'] ?? 0) / (monto == 0 ? 1 : monto)) * 100).toStringAsFixed(0)}%",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "\$${monto.toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  fechaInicio != null
                                      ? DateFormat('dd/MM/yyyy').format(fechaInicio)
                                      : '---',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  fechaFin != null
                                      ? DateFormat('dd/MM/yyyy').format(fechaFin)
                                      : '---',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
