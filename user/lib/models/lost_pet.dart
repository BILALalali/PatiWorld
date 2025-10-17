class LostPet {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  final String description;
  final String city;
  final String contactNumber;
  final String whatsappNumber;
  final DateTime lostDate;
  final DateTime createdAt;
  final String userId;

  LostPet({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.description,
    required this.city,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.lostDate,
    required this.createdAt,
    required this.userId,
  });

  factory LostPet.fromJson(Map<String, dynamic> json) {
    return LostPet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      lostDate: DateTime.parse(json['lost_date'] ?? DateTime.now().toIso8601String()),
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
      'lost_date': lostDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
