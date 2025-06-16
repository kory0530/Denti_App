class User {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
  });

  // Método para convertir un mapa JSON a un objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
    );
  }

  // Método para convertir un objeto User a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
    };
  }
}