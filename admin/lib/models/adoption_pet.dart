class AdoptionPet {
  final String id;
  final String userId;
  final String petName;
  final String petType;
  final String? description;
  final String? imageUrl;
  final String? location;
  final String? age;
  final String? gender;
  final String? contactInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdoptionPet({
    required this.id,
    required this.userId,
    required this.petName,
    required this.petType,
    this.description,
    this.imageUrl,
    this.location,
    this.age,
    this.gender,
    this.contactInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdoptionPet.fromJson(Map<String, dynamic> json) {
    return AdoptionPet(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      petName: json['pet_name'] as String,
      petType: json['pet_type'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      location: json['location'] as String?,
      age: json['age'] as String?,
      gender: json['gender'] as String?,
      contactInfo: json['contact_info'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pet_name': petName,
      'pet_type': petType,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'age': age,
      'gender': gender,
      'contact_info': contactInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
