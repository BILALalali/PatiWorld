class UserStats {
  final String id;
  final String userId;
  final int totalAdoptionPets;
  final int totalLostPets;
  final int totalVaccinations;
  final int daysInApp;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserStats({
    required this.id,
    required this.userId,
    required this.totalAdoptionPets,
    required this.totalLostPets,
    required this.totalVaccinations,
    required this.daysInApp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      totalAdoptionPets: json['total_adoption_pets'] as int? ?? 0,
      totalLostPets: json['total_lost_pets'] as int? ?? 0,
      totalVaccinations: json['total_vaccinations'] as int? ?? 0,
      daysInApp: json['days_in_app'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_adoption_pets': totalAdoptionPets,
      'total_lost_pets': totalLostPets,
      'total_vaccinations': totalVaccinations,
      'days_in_app': daysInApp,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
