import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final AuthService _authService = AuthService();

  SignUpScreen({super.key});

  Future<void> _signUp(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final fullName = _fullNameController.text;

    final user = await _authService.signUp(email, password, fullName);
    if (user != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Volver al inicio de sesión
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Registro',
          style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField(_fullNameController, 'Nombre completo', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Correo electrónico', Icons.email),
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'Contraseña', Icons.lock, isPassword: true),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _signUp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 10,
              ),
              child: const Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60, fontFamily: 'Montserrat'),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
