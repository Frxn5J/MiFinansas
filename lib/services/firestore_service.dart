import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  Future<List<Map<String, dynamic>>> getTransacciones() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('transacciones')
        .where('usuarioId', isEqualTo: user.uid)
        .orderBy('fecha', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
