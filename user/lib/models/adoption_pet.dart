class AdoptionPet {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  final String description;
  final String city;
  final String contactNumber;
  final String whatsappNumber;
  final int age; // العمر بالأشهر
  final String gender; // الجنس
  final bool isVaccinated; // هل تم تطعيمه
  final bool isNeutered; // هل تم تعقيمه
  final DateTime createdAt;
  final String userId;

  AdoptionPet({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.description,
    required this.city,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.age,
    required this.gender,
    required this.isVaccinated,
    required this.isNeutered,
    required this.createdAt,
    required this.userId,
  });

  factory AdoptionPet.fromJson(Map<String, dynamic> json) {
    return AdoptionPet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      isVaccinated: json['is_vaccinated'] ?? false,
      isNeutered: json['is_neutered'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'image_url': imageUrl,
      'description': description,
      'city': city,
      'contact_number': contactNumber,
      'whatsapp_number': whatsappNumber,
      'age': age,
      'gender': gender,
      'is_vaccinated': isVaccinated,
      'is_neutered': isNeutered,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
