class LostPet {
  final String id;
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
  final String userId;

  LostPet({
    required this.id,
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
    required this.userId,
  });

  factory LostPet.fromJson(Map<String, dynamic> json) {
    return LostPet(
      id: json['id']?.toString() ?? '',
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
      userId: json['user_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'city': city,
      'lost_date': lostDate.toIso8601String().split(
        'T',
      )[0], // Format as YYYY-MM-DD
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
      'user_id': userId,
    };
  }

  LostPet copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? city,
    DateTime? lostDate,
    String? contactNumber,
    String? whatsappNumber,
    String? imageUrl,
    int? ageMonths,
    String? gender,
    bool? isVaccinated,
    bool? isNeutered,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return LostPet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      city: city ?? this.city,
      lostDate: lostDate ?? this.lostDate,
      contactNumber: contactNumber ?? this.contactNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      ageMonths: ageMonths ?? this.ageMonths,
      gender: gender ?? this.gender,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isNeutered: isNeutered ?? this.isNeutered,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  // Helper method to get days since lost
  int get daysSinceLost {
    return DateTime.now().difference(lostDate).inDays;
  }

  // Helper method to format lost date for display
  String get formattedLostDate {
    return '${lostDate.day.toString().padLeft(2, '0')}/${lostDate.month.toString().padLeft(2, '0')}/${lostDate.year}';
  }

  // Helper method to get age display
  String get ageDisplay {
    if (ageMonths == null) return 'Bilinmiyor';
    if (ageMonths! < 12) {
      return '$ageMonths Ay';
    } else {
      final years = ageMonths! ~/ 12;
      final months = ageMonths! % 12;
      if (months == 0) {
        return '$years Yaş';
      } else {
        return '$years Yaş $months Ay';
      }
    }
  }
}
