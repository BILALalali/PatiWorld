class Vaccination {
  final String id;
  final String petName;
  final String petType;
  final String vaccineName;
  final DateTime vaccineDate;
  final DateTime nextVaccineDate;
  final int vaccineNumber; // Aşı numarası
  final String notes;
  final DateTime createdAt;
  final String userId;

  Vaccination({
    required this.id,
    required this.petName,
    required this.petType,
    required this.vaccineName,
    required this.vaccineDate,
    required this.nextVaccineDate,
    required this.vaccineNumber,
    required this.notes,
    required this.createdAt,
    required this.userId,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'] ?? '',
      petName: json['pet_name'] ?? '',
      petType: json['pet_type'] ?? '',
      vaccineName: json['vaccine_name'] ?? '',
      vaccineDate: DateTime.parse(
        json['vaccine_date'] ?? DateTime.now().toIso8601String(),
      ),
      nextVaccineDate: DateTime.parse(
        json['next_vaccine_date'] ?? DateTime.now().toIso8601String(),
      ),
      vaccineNumber: json['vaccine_number'] ?? 1,
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_name': petName,
      'pet_type': petType,
      'vaccine_name': vaccineName,
      'vaccine_date': vaccineDate.toIso8601String(),
      'next_vaccine_date': nextVaccineDate.toIso8601String(),
      'vaccine_number': vaccineNumber,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  // Sonraki aşı için kalan günleri hesapla
  int get daysUntilNextVaccine {
    final now = DateTime.now();
    final difference = nextVaccineDate.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  // Aşı tarihinin geçip geçmediğini kontrol et
  bool get isVaccineOverdue {
    return DateTime.now().isAfter(nextVaccineDate);
  }
}
