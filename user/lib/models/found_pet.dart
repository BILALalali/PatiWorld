class FoundPet {
  final String id;
  final String name;
  final String type;
  final String breed;
  final String city;
  final String? imageUrl;
  final DateTime foundDate;
  final DateTime createdAt;
  final String userId;
  final String? contactNumber;
  final String? whatsappNumber;

  FoundPet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.city,
    this.imageUrl,
    required this.foundDate,
    required this.createdAt,
    required this.userId,
    this.contactNumber,
    this.whatsappNumber,
  });

  factory FoundPet.fromJson(Map<String, dynamic> json) {
    return FoundPet(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      breed: json['breed']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      foundDate: json['found_date'] != null
          ? DateTime.parse(json['found_date'].toString())
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      userId: json['user_id']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'city': city,
      'image_url': imageUrl,
      'found_date': foundDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'contact_number': contactNumber,
      'whatsapp_number': whatsappNumber,
    };
  }

  // Helper method to get days since found
  int get daysSinceFound {
    return DateTime.now().difference(foundDate).inDays;
  }

  // Helper method to format found date for display
  String get formattedFoundDate {
    return '${foundDate.day.toString().padLeft(2, '0')}/${foundDate.month.toString().padLeft(2, '0')}/${foundDate.year}';
  }
}
