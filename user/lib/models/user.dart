class User {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? countryCode;
  final String? profileImageUrl;
  final String? fullName;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.countryCode,
    this.profileImageUrl,
    this.fullName,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      countryCode: json['country_code'],
      profileImageUrl: json['profile_image_url'],
      fullName: json['full_name'],
      isEmailVerified: json['is_email_verified'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'profile_image_url': profileImageUrl,
      'full_name': fullName,
      'is_email_verified': isEmailVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? profileImageUrl,
    String? fullName,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      fullName: fullName ?? this.fullName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
