class Diagnosis {
  final String id;
  final String userId;
  final String imageUrl;
  final Map<String, dynamic> diagnosisResult;
  final String recommendations;
  final DateTime createdAt;

  Diagnosis({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.diagnosisResult,
    required this.recommendations,
    required this.createdAt,
  });

  // Método para convertir un mapa JSON a un objeto Diagnosis
  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'],
      userId: json['user_id'],
      imageUrl: json['image_url'],
      diagnosisResult: json['diagnosis_result'],
      recommendations: json['recommendations'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Método para convertir un objeto Diagnosis a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'diagnosis_result': diagnosisResult,
      'recommendations': recommendations,
      'created_at': createdAt.toIso8601String(),
    };
  }
}