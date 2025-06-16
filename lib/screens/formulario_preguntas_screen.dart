import 'package:flutter/material.dart';

class FormularioPreguntasScreen extends StatefulWidget {
  const FormularioPreguntasScreen({super.key});

  @override
  State<FormularioPreguntasScreen> createState() => _FormularioPreguntasScreenState();
}

class _FormularioPreguntasScreenState extends State<FormularioPreguntasScreen> {
  final List<Map<String, dynamic>> _preguntas = [
    {"clave": "dolor", "texto": "¿Sientes dolor en los dientes o encías?", "tipo": "si_no"},
    {"clave": "sangrado", "texto": "¿Te sangran las encías al cepillarte?", "tipo": "si_no"},
    {"clave": "sensibilidad", "texto": "¿Tienes sensibilidad al frío o al calor?", "tipo": "si_no"},
    {"clave": "dientes_perdidos", "texto": "¿Has perdido algún diente?", "tipo": "si_no"},
    {"clave": "mal_aliento", "texto": "¿Has notado mal aliento frecuente?", "tipo": "si_no"},
    {"clave": "encias_inflamadas", "texto": "¿Sientes las encías inflamadas?", "tipo": "si_no"},
    {"clave": "dificultad_masticar", "texto": "¿Tienes dificultad para masticar?", "tipo": "si_no"},
    {"clave": "frecuencia_cepillado", "texto": "¿Cuántas veces al día te cepillas los dientes?", "tipo": "texto"},
    {"clave": "visita_dentista", "texto": "¿Cuándo fue tu última visita al dentista?", "tipo": "texto"},
    {"clave": "consumo_azucar", "texto": "¿Con qué frecuencia consumes alimentos azucarados?", "tipo": "texto"},
  ];

  int _preguntaActual = 0;
  final Map<String, String> _respuestas = {};
  final TextEditingController _textoController = TextEditingController();

  void _guardarRespuesta(String respuesta) {
    final clave = _preguntas[_preguntaActual]['clave'];
    _respuestas[clave] = respuesta;

    if (_preguntaActual < _preguntas.length - 1) {
      setState(() {
        _preguntaActual++;
        _textoController.clear();
      });
    } else {
      Navigator.pop(context, _respuestas);
    }
  }

  @override
  void dispose() {
    _textoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = _preguntas[_preguntaActual];

    return Scaffold(
      appBar: AppBar(title: const Text('Cuestionario Dental')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregunta ${_preguntaActual + 1} de ${_preguntas.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              pregunta['texto'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            if (pregunta['tipo'] == 'si_no') ...[
              ElevatedButton(
                onPressed: () => _guardarRespuesta("Sí"),
                child: const Text("Sí"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _guardarRespuesta("No"),
                child: const Text("No"),
              ),
            ] else ...[
              TextField(
                controller: _textoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Escribe tu respuesta",
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_textoController.text.trim().isNotEmpty) {
                    _guardarRespuesta(_textoController.text.trim());
                  }
                },
                child: const Text("Siguiente"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
