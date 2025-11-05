class Vaccination {
  final String id;
  final String? userId;
  final String petName;
  final String petType;
  final String vaccineName;
  final DateTime? vaccineDate;
  final DateTime? nextVaccineDate;
  final int? vaccineNumber;
  final String? notes;
  final DateTime? createdAt;

  Vaccination({
    required this.id,
    this.userId,
    required this.petName,
    required this.petType,
    required this.vaccineName,
    this.vaccineDate,
    this.nextVaccineDate,
    this.vaccineNumber,
    this.notes,
    this.createdAt,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      petName: json['pet_name']?.toString() ?? '',
      petType: json['pet_type']?.toString() ?? '',
      vaccineName: json['vaccine_name']?.toString() ?? '',
      vaccineDate: json['vaccine_date'] != null
          ? DateTime.tryParse(json['vaccine_date'].toString())
          : null,
      nextVaccineDate: json['next_vaccine_date'] != null
          ? DateTime.tryParse(json['next_vaccine_date'].toString())
          : null,
      vaccineNumber: json['vaccine_number'] != null
          ? (json['vaccine_number'] is int
                ? json['vaccine_number'] as int
                : int.tryParse(json['vaccine_number'].toString()))
          : null,
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pet_name': petName,
      'pet_type': petType,
      'vaccine_name': vaccineName,
      'vaccine_date': vaccineDate?.toIso8601String(),
      'next_vaccine_date': nextVaccineDate?.toIso8601String(),
      'vaccine_number': vaccineNumber,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
