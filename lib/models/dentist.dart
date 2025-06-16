class Dentist {
  final String id;
  final String name;
  final String specialty;
  final double latitude;
  final double longitude;
  final String address;
  final String? phoneNumber;
  final double? rating;

  Dentist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phoneNumber,
    this.rating,
  });

  factory Dentist.fromJson(Map<String, dynamic> json) {
    return Dentist(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      latitude: (json['latitude'] is double)
          ? json['latitude']
          : double.parse(json['latitude'].toString()),
      longitude: (json['longitude'] is double)
          ? json['longitude']
          : double.parse(json['longitude'].toString()),
      address: json['address'] as String,
      phoneNumber: json['phone_number'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone_number': phoneNumber,
      'rating': rating,
    };
  }
}
