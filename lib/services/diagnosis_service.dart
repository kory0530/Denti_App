import 'dart:io'; // ✅ Necesario para File
import 'package:flutter/foundation.dart';

import '../supabase_config.dart';

class DiagnosisService {
  // Subir una imagen al almacenamiento de Supabase
  Future<String?> uploadImage(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final filename = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Subimos el archivo al bucket 'diagnosis-images'
      await supabase.storage.from('diagnosis-images').upload(filename, file);

      // Obtenemos la URL pública directamente (es un String)
      final publicUrl = supabase.storage.from('diagnosis-images').getPublicUrl(filename);

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir la imagen: $e');
      }
      return null;
    }
  }

  // Guardar un diagnóstico en la base de datos
  Future<bool> saveDiagnosis(
      String userId,
      String imageUrl,
      Map<String, dynamic> diagnosisResult,
      String recommendations) async {
    try {
      await supabase.from('diagnoses').insert({
        'user_id': userId,
        'image_url': imageUrl,
        'diagnosis_result': diagnosisResult,
        'recommendations': recommendations,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error al guardar el diagnóstico: $e');
      }
      return false;
    }
  }
}