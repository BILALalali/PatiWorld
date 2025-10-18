import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet.dart';

class PetService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// جلب جميع الحيوانات النشطة
  static Future<List<Pet>> getAllPets() async {
    try {
      final response = await _supabase
          .from('pets')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Pet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب البيانات: $e');
    }
  }

  /// جلب حيوان محدد بالمعرف
  static Future<Pet?> getPetById(String id) async {
    try {
      final response = await _supabase
          .from('pets')
          .select()
          .eq('id', id)
          .eq('is_active', true)
          .single();

      return Pet.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// جلب الحيوانات حسب النوع
  static Future<List<Pet>> getPetsByType(String type) async {
    try {
      final response = await _supabase
          .from('pets')
          .select()
          .eq('type', type)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Pet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب البيانات: $e');
    }
  }

  /// البحث في الحيوانات
  static Future<List<Pet>> searchPets(String query) async {
    try {
      final response = await _supabase
          .from('pets')
          .select()
          .eq('is_active', true)
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,type.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List).map((json) => Pet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في البحث: $e');
    }
  }

  /// إضافة حيوان جديد (للمديرين)
  static Future<Pet> addPet(Pet pet) async {
    try {
      final response = await _supabase
          .from('pets')
          .insert(pet.toJson())
          .select()
          .single();

      return Pet.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إضافة الحيوان: $e');
    }
  }

  /// تحديث حيوان (للمديرين)
  static Future<Pet> updatePet(Pet pet) async {
    try {
      final response = await _supabase
          .from('pets')
          .update(pet.toJson())
          .eq('id', pet.id)
          .select()
          .single();

      return Pet.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تحديث الحيوان: $e');
    }
  }

  /// حذف حيوان (للمديرين) - حذف منطقي
  static Future<void> deletePet(String id) async {
    try {
      await _supabase.from('pets').update({'is_active': false}).eq('id', id);
    } catch (e) {
      throw Exception('فشل في حذف الحيوان: $e');
    }
  }

  /// جلب إحصائيات الحيوانات
  static Future<Map<String, int>> getPetStats() async {
    try {
      final response = await _supabase
          .from('pets')
          .select('type')
          .eq('is_active', true);

      final Map<String, int> stats = {};
      for (var pet in response) {
        final type = pet['type'] as String;
        stats[type] = (stats[type] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('فشل في جلب الإحصائيات: $e');
    }
  }
}
