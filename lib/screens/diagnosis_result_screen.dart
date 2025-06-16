import 'package:flutter/material.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final String diagnosisText;
  final String recommendations;

  const DiagnosisResultScreen({
    super.key,
    required this.diagnosisText,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Montserrat',
    );

    final bodyStyle = const TextStyle(
      fontSize: 16,
      color: Colors.white70,
      height: 1.4,
      fontFamily: 'Montserrat',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Resultado del Diagnóstico',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diagnóstico:', style: titleStyle),
                const SizedBox(height: 12),
                Text(diagnosisText, style: bodyStyle),
                const SizedBox(height: 24),
                Text('Recomendaciones:', style: titleStyle),
                const SizedBox(height: 12),
                Text(recommendations, style: bodyStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

