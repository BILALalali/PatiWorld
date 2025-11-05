class LostPet {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String description;
  final String city;
  final DateTime lostDate;
  final String contactNumber;
  final String whatsappNumber;
  final String? imageUrl;
  final int? ageMonths;
  final String? gender;
  final bool isVaccinated;
  final bool isNeutered;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LostPet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.description,
    required this.city,
    required this.lostDate,
    required this.contactNumber,
    required this.whatsappNumber,
    this.imageUrl,
    this.ageMonths,
    this.gender,
    this.isVaccinated = false,
    this.isNeutered = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LostPet.fromJson(Map<String, dynamic> json) {
    return LostPet(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      lostDate: json['lost_date'] != null
          ? DateTime.parse(json['lost_date'].toString())
          : DateTime.now(),
      contactNumber: json['contact_number']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      ageMonths: json['age_months'] != null
          ? int.tryParse(json['age_months'].toString())
          : null,
      gender: json['gender']?.toString(),
      isVaccinated: json['is_vaccinated'] as bool? ?? false,
      isNeutered: json['is_neutered'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
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
      'lost_date': lostDate.toIso8601String().split('T')[0],
      'contact_number': contactNumber,
      'whatsapp_number': whatsappNumber,
      'image_url': imageUrl,
      'age_months': ageMonths,
      'gender': gender,
      'is_vaccinated': isVaccinated,
      'is_neutered': isNeutered,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
