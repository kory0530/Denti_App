import 'package:denti_app/supabase_config.dart';
import '../models/user.dart' as local;
import 'package:logger/logger.dart';

final logger = Logger();

class AuthService {
  // Registrar un nuevo usuario
  Future<local.User?> signUp(String email, String password, String fullName) async {
    try {
      // Registrar usuario en Auth (solo email y password)
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final supabaseUser = res.user;
      if (supabaseUser == null) {
        logger.e('Error: usuario nulo tras signUp');
        return null;
      }

      // Insertar datos adicionales en tabla 'users'
      final insertedUsers = await supabase.from('users').insert({
        'id': supabaseUser.id,
        'email': email,
        'full_name': fullName,
      }).select();

      // insertedUsers es una lista con registros insertados
      // ignore: unnecessary_null_comparison
      if (insertedUsers == null || insertedUsers.isEmpty) {
        logger.e('Error insertando usuario en tabla users');
        return null;
      }

      final userMap = insertedUsers.first;

      return local.User.fromJson(userMap);
    } catch (e, st) {
      logger.e('Error al registrar usuario', error: e, stackTrace: st);
      return null;
    }
  }

  // Iniciar sesión
  Future<local.User?> signIn(String email, String password) async {
    try {
      final res = await supabase.auth.signInWithPassword(email: email, password: password);
      final supabaseUser = res.user;

      if (supabaseUser == null) {
        logger.e('Usuario nulo tras signIn');
        return null;
      }

      // Obtener datos de usuario desde tabla 'users'
      final userList = await supabase
          .from('users')
          .select()
          .eq('id', supabaseUser.id);

      // ignore: unnecessary_null_comparison
      if (userList == null || userList.isEmpty) {
        logger.e('Usuario no encontrado en tabla users');
        return null;
      }

      final userMap = userList.first;

      return local.User.fromJson(userMap);
    } catch (e, st) {
      logger.e('Error al iniciar sesión', error: e, stackTrace: st);
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e, st) {
      logger.e('Error al cerrar sesión', error: e, stackTrace: st);
    }
  }

  // Obtener usuario actual
  Future<local.User?> getCurrentUser() async {
    try {
      final supabaseUser = supabase.auth.currentUser;
      if (supabaseUser == null) return null;

      final userList = await supabase
          .from('users')
          .select()
          .eq('id', supabaseUser.id);

      // ignore: unnecessary_null_comparison
      if (userList == null || userList.isEmpty) {
        logger.e('Usuario actual no encontrado en tabla users');
        return null;
      }

      final userMap = userList.first;

      return local.User.fromJson(userMap);
    } catch (e, st) {
      logger.e('Error al obtener usuario actual', error: e, stackTrace: st);
      return null;
    }
  }
}
