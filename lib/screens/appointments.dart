import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  // Nota: el nombre se mantiene igual
  // ignore: library_private_types_in_public_api
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _diagnoses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDiagnoses();
  }

  Future<void> fetchDiagnoses() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Usuario no autenticado.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await supabase
          .from('diagnoses')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _diagnoses = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los diagnósticos: $e';
        _isLoading = false;
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
          'Historial de Diagnósticos',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A56F9)),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                )
              : _diagnoses.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay diagnósticos registrados.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _diagnoses.length,
                      itemBuilder: (context, index) {
                        final diag = _diagnoses[index];
                        final DateTime createdAt =
                            DateTime.parse(diag['created_at']);
                        final result = diag['diagnosis_result'];
                        final recommendations = diag['recommendations'];
                        final imageUrl = diag['image_url'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A3D),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 12),
                              const Text(
                                'Diagnóstico:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                result.toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Recomendaciones:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                recommendations ?? 'Sin recomendaciones',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Fecha: ${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
