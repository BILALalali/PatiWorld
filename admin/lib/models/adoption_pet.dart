class AdoptionPet {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String description;
  final String city;
  final String contactNumber;
  final String whatsappNumber;
  final String imageUrl;
  final int age;
  final String gender;
  final bool isVaccinated;
  final bool isNeutered;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  AdoptionPet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.description,
    required this.city,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.imageUrl,
    required this.age,
    required this.gender,
    this.isVaccinated = false,
    this.isNeutered = false,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  factory AdoptionPet.fromJson(Map<String, dynamic> json) {
    return AdoptionPet(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      age: json['age'] is int
          ? json['age'] as int
          : (json['age'] != null
                ? int.tryParse(json['age'].toString()) ?? 0
                : 0),
      gender: json['gender']?.toString() ?? '',
      isVaccinated: json['is_vaccinated'] as bool? ?? false,
      isNeutered: json['is_neutered'] as bool? ?? false,
      latitude: json['latitude'] != null
          ? (json['latitude'] is double
                ? json['latitude'] as double
                : double.tryParse(json['latitude'].toString()))
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] is double
                ? json['longitude'] as double
                : double.tryParse(json['longitude'].toString()))
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'description': description,
      'city': city,
      'contact_number': contactNumber,
      'whatsapp_number': whatsappNumber,
      'image_url': imageUrl,
      'age': age,
      'gender': gender,
      'is_vaccinated': isVaccinated,
      'is_neutered': isNeutered,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
