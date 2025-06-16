import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AiService {
  final String _apiKey = 'AIzaSyActmcFENHsOPyeD38FzPQEZ5dkSwj1ggk'; // Tu clave de Gemini API

  // Este endpoint es para Gemini Pro Vision, el modelo multimodal
  // Podrías considerar 'gemini-1.5-flash-latest' para mayor velocidad y menor costo.
  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
      // Para Gemini 1.5 Flash: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';


  /// Envía imágenes y preguntas a Gemini para generar un diagnóstico dental.
  Future<String?> generateDiagnosis({
    required List<File> images,
    required Map<String, String> questionnaireAnswers,
  }) async {
    try {
      List<Map<String, dynamic>> parts = [];

      for (var image in images) {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);
        parts.add({
          "inlineData": {
            "mimeType": "image/jpeg", // Asegúrate de que tus imágenes sean JPG
            "data": base64Image,
          }
        });
      }

      final answersPrompt = questionnaireAnswers.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');

      // El prompt es crucial aquí. Le dices a Gemini qué debe "ver" y cómo diagnosticar.
      parts.add({
        "text": '''
Eres un asistente de IA experto en odontología. Analiza cuidadosamente las imágenes dentales proporcionadas y las respuestas del siguiente cuestionario del paciente.

Basándote en la evidencia visual de las imágenes y la información del cuestionario, identifica:
1.  **Cualquier signo de enfermedad dental** (ej., caries, gingivitis, periodontitis, erosión dental, fracturas, desgaste, abscesos, etc.). Describe la ubicación y severidad si es posible.
2.  **Problemas estéticos** (ej., manchas, desalineación leve).
3.  **Observaciones generales** relevantes para la salud bucal.

Después de tu análisis, proporciona un **diagnóstico inicial y recomendaciones personalizadas** al paciente. La respuesta debe ser:
* Clara, concisa y fácil de entender para un paciente no profesional.
* Precisa y basada en la evidencia visible y proporcionada.
* Con un tono profesional y empático.
* **En formato de puntos o lista numerada para mayor claridad.**
* Si no hay problemas evidentes, indícalo.
* Respondele directamente al paciente, solo di algo como " Estas son las instrucciones para tomarte las fotos "
* Que las instrucciones sean muy breves y concisas

---
Cuestionario del Paciente:
$answersPrompt

---
Diagnóstico y Recomendaciones:
'''
      });

      final response = await http.post(
        Uri.parse("$_apiUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {"parts": parts}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? "No se recibió respuesta del modelo.";
      } else {
        return "Error ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      return "Error al procesar la solicitud: $e";
    }
  }
}