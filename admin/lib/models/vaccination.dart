class Vaccination {
  final String id;
  final String userId;
  final String petName;
  final String vaccineType;
  final DateTime vaccinationDate;
  final DateTime? nextVaccinationDate;
  final String? veterinarianName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vaccination({
    required this.id,
    required this.userId,
    required this.petName,
    required this.vaccineType,
    required this.vaccinationDate,
    this.nextVaccinationDate,
    this.veterinarianName,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      petName: json['pet_name'] as String,
      vaccineType: json['vaccine_type'] as String,
      vaccinationDate: DateTime.parse(json['vaccination_date'] as String),
      nextVaccinationDate: json['next_vaccination_date'] != null
          ? DateTime.parse(json['next_vaccination_date'] as String)
          : null,
      veterinarianName: json['veterinarian_name'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pet_name': petName,
      'vaccine_type': vaccineType,
      'vaccination_date': vaccinationDate.toIso8601String(),
      'next_vaccination_date': nextVaccinationDate?.toIso8601String(),
      'veterinarian_name': veterinarianName,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
