class Admin {
  final String id;
  final String email;
  final String fullName;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Admin({
    required this.id,
    required this.email,
    required this.fullName,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      passwordHash: json['password_hash'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  Admin copyWith({
    String? id,
    String? email,
    String? fullName,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Admin(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
