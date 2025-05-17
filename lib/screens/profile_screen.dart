import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = currentUser;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _showChangePasswordDialog() {
    final _formKey = GlobalKey<FormState>();
    String newPassword = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar Contraseña'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Nueva contraseña'),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Debe tener al menos 6 caracteres';
              }
              return null;
            },
            onChanged: (value) => newPassword = value,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await _user!.updatePassword(newPassword);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña actualizada.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? 'Usuario';
    final email = _user?.email ?? '';
    final photoUrl = _user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Perfil', style: TextStyle(fontSize: 28)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.orange,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? Icon(Icons.person, size: 60, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(displayName, style: TextStyle(fontSize: 22)),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(email, style: TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 20),

            // Moneda
            Text('Moneda', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Image(
                    image: AssetImage('assets/flags/mexico.png'),
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 10),
                  Text('MXN'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cambiar PIN
            Text('Cambiar PIN', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/change_pin');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lock, size: 40),
              ),
            ),

            const SizedBox(height: 24),

            // Botones
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  onPressed: _showChangePasswordDialog,
                  child: const Text(
                    "Cambiar contraseña",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  onPressed: _signOut,
                  child: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

