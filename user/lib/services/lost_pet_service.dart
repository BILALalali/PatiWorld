import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lost_pet.dart';
import '../constants/app_constants.dart';

class LostPetService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// جلب جميع الحيوانات المفقودة النشطة
  static Future<List<LostPet>> getAllLostPets() async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LostPet.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الحيوانات المفقودة: $e');
    }
  }

  /// جلب حيوان مفقود محدد بالمعرف
  static Future<LostPet?> getLostPetById(String id) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('id', id)
          .eq('is_active', true)
          .single();

      return LostPet.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// جلب الحيوانات المفقودة حسب النوع
  static Future<List<LostPet>> getLostPetsByType(String type) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('type', type)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LostPet.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الحيوانات المفقودة: $e');
    }
  }

  /// جلب الحيوانات المفقودة حسب المدينة
  static Future<List<LostPet>> getLostPetsByCity(String city) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('city', city)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LostPet.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الحيوانات المفقودة: $e');
    }
  }

  /// البحث في الحيوانات المفقودة
  static Future<List<LostPet>> searchLostPets(String query) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('is_active', true)
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,type.ilike.%$query%,city.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LostPet.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في البحث: $e');
    }
  }

  /// إضافة حيوان مفقود جديد
  static Future<LostPet> addLostPet({
    required String name,
    required String type,
    required String description,
    required String city,
    required DateTime lostDate,
    required String contactNumber,
    required String whatsappNumber,
    String? imageUrl,
    int? ageMonths,
    String? gender,
    bool isVaccinated = false,
    bool isNeutered = false,
    required String userId,
  }) async {
    try {
      final lostPetData = {
        'name': name,
        'type': type,
        'description': description,
        'city': city,
        'lost_date': lostDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'contact_number': contactNumber,
        'whatsapp_number': whatsappNumber,
        'image_url': imageUrl ?? 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
        'age_months': ageMonths,
        'gender': gender,
        'is_vaccinated': isVaccinated,
        'is_neutered': isNeutered,
        'is_active': true,
        'user_id': userId,
      };

      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .insert(lostPetData)
          .select()
          .single();

      return LostPet.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إضافة الحيوان المفقود: $e');
    }
  }

  /// تحديث حيوان مفقود
  static Future<LostPet> updateLostPet(LostPet lostPet) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .update(lostPet.toJson())
          .eq('id', lostPet.id)
          .select()
          .single();

      return LostPet.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الحيوان المفقود: $e');
    }
  }

  /// حذف حيوان مفقود (حذف منطقي)
  static Future<void> deleteLostPet(String id) async {
    try {
      await _supabase
          .from(AppConstants.lostPetsTable)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل في حذف الحيوان المفقود: $e');
    }
  }

  /// جلب الحيوانات المفقودة للمستخدم الحالي
  static Future<List<LostPet>> getUserLostPets(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LostPet.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب حيواناتك المفقودة: $e');
    }
  }

  /// جلب إحصائيات الحيوانات المفقودة
  static Future<Map<String, int>> getLostPetStats() async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select('type, city')
          .eq('is_active', true);

      final Map<String, int> typeStats = {};
      final Map<String, int> cityStats = {};

      for (var pet in response) {
        final type = pet['type'] as String;
        final city = pet['city'] as String;
        
        typeStats[type] = (typeStats[type] ?? 0) + 1;
        cityStats[city] = (cityStats[city] ?? 0) + 1;
      }

      return {
        'total': response.length,
        'by_type_count': typeStats.length,
        'by_city_count': cityStats.length,
      };
    } catch (e) {
      throw Exception('فشل في جلب الإحصائيات: $e');
    }
  }

  /// تحديث حالة الحيوان المفقود (تم العثور عليه)
  static Future<void> markAsFound(String id) async {
    try {
      await _supabase
          .from(AppConstants.lostPetsTable)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل في تحديث حالة الحيوان: $e');
    }
  }
}
