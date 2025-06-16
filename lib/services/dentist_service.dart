import '../models/dentist.dart';
import '../supabase_config.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class DentistService {
  /// Busca dentistas cercanos usando la función RPC 'find_nearby_dentists'
  Future<List<Dentist>> findNearbyDentists(
      double userLatitude, double userLongitude, double maxDistance) async {
    try {
      // rpc recibe solo un mapa con parámetros nombrados
      final response = await supabase.rpc('find_nearby_dentists', params: {
        'user_latitude': userLatitude,
        'user_longitude': userLongitude,
        'max_distance': maxDistance,
      });

      // response es directamente la lista de resultados
      if (response != null && (response as List).isNotEmpty) {
        // ignore: unnecessary_cast
        return (response as List)
            .map((item) => Dentist.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e, stacktrace) {
      logger.e('Error al buscar dentistas cercanos:', error: e, stackTrace: stacktrace);
      return [];
    }
  }

  /// Obtiene todos los dentistas
  Future<List<Dentist>> getAllDentists() async {
    try {
      // select() devuelve directamente una lista
      final response = await supabase.from('dentists').select();

      // ignore: unnecessary_null_comparison
      if (response != null && (response as List).isNotEmpty) {
        return (response as List)
            .map((item) => Dentist.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e, stacktrace) {
      logger.e('Error al obtener dentistas:', error: e, stackTrace: stacktrace);
      return [];
    }
  }
}