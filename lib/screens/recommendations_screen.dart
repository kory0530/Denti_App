import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> recommendations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRecommendations();
  }

  Future<void> fetchRecommendations() async {
    try {
      final response = await supabase
          .from('recommendations')
          .select('*')
          .order('created_at', ascending: false);

      // ignore: unnecessary_null_comparison
      if (response != null) {
        setState(() {
          recommendations = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No se encontraron recomendaciones.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar las recomendaciones: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Recomendaciones',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6A56F9),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                    ),
                  ),
                )
              : recommendations.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay recomendaciones disponibles.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        final recommendation = recommendations[index];
                        return Card(
                          color: const Color(0xFF2A2A3D),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.health_and_safety,
                              color: Color(0xFF6A56F9),
                            ),
                            title: Text(
                              recommendation['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              recommendation['content'] ?? '',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white70,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        );
                      },
                    ),
    );
  }
}

