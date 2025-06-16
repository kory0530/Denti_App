import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../supabase_config.dart';

class AppointmentService {
  /// Crear una nueva cita
  Future<bool> createAppointment({
    required String userId,
    required DateTime dateTime,
    required String status,
    String? notes,
  }) async {
    try {
      await supabase.from('appointments').insert({
        'user_id': userId,
        'date_time': dateTime.toIso8601String(),
        'status': status,
        'notes': notes,
      });
      return true;
    } catch (e) {
      debugPrint('Error al crear la cita: $e');
      return false;
    }
  }

  /// Obtener todas las citas de un usuario
  Future<List<Appointment>> getAppointmentsByUser(String userId) async {
    try {
      final response = await supabase
          .from('appointments')
          .select()
          .eq('user_id', userId)
          .order('date_time', ascending: true);

      return (response as List)
          .map((item) => Appointment.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error al obtener las citas: $e');
      return [];
    }
  }

  /// Eliminar una cita por su ID
  Future<bool> deleteAppointment(String appointmentId) async {
    try {
      await supabase.from('appointments').delete().eq('id', appointmentId);
      return true;
    } catch (e) {
      debugPrint('Error al eliminar la cita: $e');
      return false;
    }
  }
}
