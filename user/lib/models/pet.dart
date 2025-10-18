class Pet {
  final String id;
  final String name;
  final String type; // نوع الحيوان (قطة، كلب، إلخ)
  final String imageUrl;
  final String description;
  final List<String> features; // أهم الصفات
  final List<String> foods; // الأطعمة المفضلة
  final List<String> diseases; // الأمراض الشائعة
  final String careInstructions; // تعليمات العناية
  final bool isActive; // هل الحيوان نشط
  final DateTime createdAt;
  final DateTime updatedAt;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.description,
    required this.features,
    required this.foods,
    required this.diseases,
    required this.careInstructions,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      foods: List<String>.from(json['foods'] ?? []),
      diseases: List<String>.from(json['diseases'] ?? []),
      careInstructions: json['care_instructions'] ?? '',
      isActive: json['is_active'] ?? true,
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
      'name': name,
      'type': type,
      'image_url': imageUrl,
      'description': description,
      'features': features,
      'foods': foods,
      'diseases': diseases,
      'care_instructions': careInstructions,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
