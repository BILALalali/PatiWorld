class LostPet {
  final String id;
  final String userId;
  final String petName;
  final String petType;
  final String? description;
  final String? imageUrl;
  final String? location;
  final DateTime? lostDate;
  final String? contactInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  LostPet({
    required this.id,
    required this.userId,
    required this.petName,
    required this.petType,
    this.description,
    this.imageUrl,
    this.location,
    this.lostDate,
    this.contactInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LostPet.fromJson(Map<String, dynamic> json) {
    return LostPet(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      petName: json['pet_name'] as String,
      petType: json['pet_type'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      location: json['location'] as String?,
      lostDate: json['lost_date'] != null
          ? DateTime.parse(json['lost_date'] as String)
          : null,
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
      'lost_date': lostDate?.toIso8601String(),
      'contact_info': contactInfo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
