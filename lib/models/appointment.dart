class Appointment {
  final String id;
  final String userId;
  final DateTime dateTime;
  final String status;
  final String? notes;

  Appointment({
    required this.id,
    required this.userId,
    required this.dateTime,
    required this.status,
    this.notes,
  });

  // Método para convertir un mapa JSON a un objeto Appointment
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['user_id'],
      dateTime: DateTime.parse(json['date_time']),
      status: json['status'],
      notes: json['notes'],
    );
  }

  // Método para convertir un objeto Appointment a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }
}