import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  Future<void> _signIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final user = await _authService.signIn(email, password);
    if (user != null) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Mostrar toast personalizado con Overlay
      // ignore: use_build_context_synchronously
      showCustomToast(context, 'Credenciales incorrectas');
    }
  }

  void showCustomToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Fondo oscuro elegante
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bienvenido de nuevo',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              _buildTextField(_emailController, 'Correo electrónico', Icons.email),
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'Contraseña', Icons.lock, isPassword: true),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () => _signIn(context),
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
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
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
        style: const TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.white,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white54),
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white60,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
