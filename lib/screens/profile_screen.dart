import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mifinanzas/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).get();
    return {
      'nombre': doc.data()?['usuario'] ?? 'Sin nombre',
      'correo': user.email ?? 'Sin correo',
    };
  }

  void _mostrarFormularioCambiarPassword(BuildContext context, String email) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña actual',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentPassword = currentPasswordController.text.trim();
                final newPassword = newPasswordController.text.trim();
                final confirmPassword = confirmPasswordController.text.trim();

                if (newPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("La nueva contraseña debe tener al menos 6 caracteres")),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Las contraseñas no coinciden")),
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser!;
                  final cred = EmailAuthProvider.credential(email: email, password: currentPassword);
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(newPassword);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contraseña actualizada con éxito")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarFormularioPin(BuildContext context) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Establecer PIN'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'PIN de 4 dígitos',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                final pin = pinController.text.trim();
                if (pin.length != 4 || int.tryParse(pin) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ingresa un PIN válido de 4 dígitos")),
                  );
                  return;
                }

                final user = FirebaseAuth.instance.currentUser!;
                await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
                  'pin': pin,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PIN guardado exitosamente")),
                );
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _confirmarEliminarPin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar PIN"),
          content: const Text("¿Estás seguro de que deseas eliminar tu PIN?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser!;
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(user.uid)
                    .update({'pin': FieldValue.delete()});

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PIN eliminado correctamente")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _cerrarSesion(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pinValidado');

      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cerrar sesión: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Perfil', style: TextStyle(fontSize: 28)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar datos"));
          }

          final nombreUsuario = snapshot.data!['nombre'];
          final correoUsuario = snapshot.data!['correo'];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.orange,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                        ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                        : null,
                    backgroundColor: Colors.white,
                    child: FirebaseAuth.instance.currentUser?.photoURL == null
                        ? const Icon(Icons.person, size: 60, color: Colors.black)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(nombreUsuario, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  correoUsuario,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 20),
                const Text('Moneda', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Image(
                        image: AssetImage('assets/flags/mexico.png'),
                        width: 24,
                        height: 24,
                      ),
                      SizedBox(width: 10),
                      Text('MXN'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                Builder(
                  builder: (context) {
                    return ElevatedButton.icon(
                      onPressed: () async {
                        final RenderBox button = context.findRenderObject() as RenderBox;
                        final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                        final offset = button.localToGlobal(Offset.zero, ancestor: overlay);

                        final selected = await showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(
                            offset.dx,
                            offset.dy + button.size.height + 8,
                            offset.dx + button.size.width,
                            offset.dy,
                          ),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          items: [
                            const PopupMenuItem(
                              value: 'establecer',
                              child: Text('Establecer o cambiar PIN'),
                            ),
                            const PopupMenuItem(
                              value: 'eliminar',
                              child: Text('Eliminar PIN'),
                            ),
                          ],
                        );

                        if (selected == 'establecer') {
                          _mostrarFormularioPin(context);
                        } else if (selected == 'eliminar') {
                          _confirmarEliminarPin(context);
                        }
                      },
                      icon: const Icon(Icons.lock),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        child: Text("PIN de seguridad"),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        elevation: 3,
                        shadowColor: Colors.black45,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () => _mostrarFormularioCambiarPassword(context, correoUsuario),
                      child: const Text("Cambiar contraseña", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () => _cerrarSesion(context),
                      child: const Text("Cerrar Sesión", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
