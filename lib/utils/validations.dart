class ValidationUtils {
  // Validar correo electrónico
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validar contraseña (mínimo 6 caracteres)
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}