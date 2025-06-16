import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/diagnosis_service.dart';
import '../services/ai_service.dart';
import 'formulario_preguntas_screen.dart';
import 'diagnosis_result_screen.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SelfDiagnosisScreen extends StatefulWidget {
  const SelfDiagnosisScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SelfDiagnosisScreenState createState() => _SelfDiagnosisScreenState();
}

class _SelfDiagnosisScreenState extends State<SelfDiagnosisScreen> {
  final DiagnosisService _diagnosisService = DiagnosisService();
  final AiService _aiService = AiService();

  List<File> _selectedImages = [];
  bool _isLoading = false;
  String _instructions = '';

  @override
  void initState() {
    super.initState();
    _loadPhotoInstructions();
  }

  Future<void> _loadPhotoInstructions() async {
    setState(() => _isLoading = true);
    try {
      final prompt = '''
Eres un experto en odontología. Escribe instrucciones claras y breves para que un paciente tome entre 3 y 5 fotos de su boca, con el objetivo de hacer un diagnóstico dental. Indica ángulos, iluminación y recomendaciones importantes.
''';

      final instructions = await _aiService.generateDiagnosis(
        images: [],
        questionnaireAnswers: {'instrucciones': prompt},
      );

      setState(() {
        _instructions = instructions ?? 'No se pudieron cargar instrucciones.';
      });
    } catch (e) {
      logger.e('Error al cargar instrucciones: $e');
      setState(() {
        _instructions = 'No se pudieron obtener instrucciones.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    // ignore: unnecessary_null_comparison
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final images = pickedFiles.map((f) => File(f.path)).toList();
      if (images.length > 5) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Máximo 5 imágenes permitidas.')),
        );
        return;
      }

      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<void> _performDiagnosis() async {
    if (_selectedImages.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona al menos una imagen')),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uploadedUrls = <String>[];
      for (final image in _selectedImages) {
        final url = await _diagnosisService.uploadImage(user.id, image.path);
        if (url != null) uploadedUrls.add(url);
      }

      final respuestasFormulario = await Navigator.push<Map<String, String>>(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const FormularioPreguntasScreen()),
      );

      if (respuestasFormulario == null) {
        setState(() => _isLoading = false);
        return;
      }

      final diagnosisText = await _aiService.generateDiagnosis(
        images: _selectedImages,
        questionnaireAnswers: respuestasFormulario,
      );

      final diagnosisResult = {
        'diagnosisText': diagnosisText ?? 'No se pudo obtener diagnóstico',
      };

      final recommendations = 'Consulta a un dentista para evaluación más detallada.';

      final success = await _diagnosisService.saveDiagnosis(
        user.id,
        uploadedUrls.first,
        diagnosisResult,
        recommendations,
      );

      if (success && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosisResultScreen(
              diagnosisText: diagnosisText ?? 'No se pudo obtener diagnóstico',
              recommendations: recommendations,
            ),
          ),
        );
        setState(() {
          _selectedImages.clear();
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el diagnóstico')),
        );
      }
    } catch (e) {
      logger.e('Error al realizar diagnóstico: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputTextStyle = const TextStyle(color: Colors.white, fontFamily: 'Montserrat');
    final instructionsTextStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.white70,
      fontFamily: 'Montserrat',
    );

    final bodyTextStyle = const TextStyle(color: Colors.white70, fontFamily: 'Montserrat');

   final buttonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color.fromARGB(255, 15, 70, 151), // azul oscuro
  foregroundColor: Colors.white, // <-- letras blancas
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  padding: const EdgeInsets.symmetric(vertical: 14),
  textStyle: const TextStyle(
    fontFamily: 'Montserrat',
    fontWeight: FontWeight.w600,
    fontSize: 16,
  ),
);


    // ignore: unused_local_variable
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E1E2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 137, 137, 138)),
      ),
      labelStyle: inputTextStyle,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
        title: const Text(
          'Autodiagnóstico Dental',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_instructions.isNotEmpty) ...[
                        Text('Instrucciones para las fotos:', style: instructionsTextStyle),
                        const SizedBox(height: 8),
                        Text(_instructions, style: bodyTextStyle),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton.icon(
                        onPressed: _pickMultipleImages,
                        icon: const Icon(Icons.image),
                        label: const Text('Seleccionar Imágenes (máx 5)'),
                        style: buttonStyle,
                      ),
                      const SizedBox(height: 12),
                      if (_selectedImages.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedImages.map((img) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(img, width: 100, height: 100, fit: BoxFit.cover),
                            );
                          }).toList(),
                        ),
                      if (_selectedImages.isNotEmpty) const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _performDiagnosis,
                        // ignore: sort_child_properties_last
                        child: const Text('Realizar Diagnóstico'),
                        style: buttonStyle,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
