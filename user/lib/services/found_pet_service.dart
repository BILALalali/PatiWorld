import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/found_pet.dart';
import '../constants/app_constants.dart';

class FoundPetService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Tüm bulunan hayvanları getir
  static Future<List<FoundPet>> getAllFoundPets() async {
    try {
      final response = await _supabase
          .from(AppConstants.foundPetsTable)
          .select()
          .order('found_date', ascending: false);

      return (response as List).map((json) => FoundPet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Bulunan hayvanları getirme başarısız: $e');
    }
  }

  /// ID ile belirli bulunan hayvanı getir
  static Future<FoundPet?> getFoundPetById(String id) async {
    try {
      final response = await _supabase
          .from(AppConstants.foundPetsTable)
          .select()
          .eq('id', id)
          .single();

      return FoundPet.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Yeni bulunan hayvan ekle
  static Future<FoundPet> addFoundPet({
    required String name,
    required String type,
    required String breed,
    required String city,
    String? imageUrl,
    required String userId,
  }) async {
    try {
      final foundPetData = {
        'name': name,
        'type': type,
        'breed': breed,
        'city': city,
        'image_url': imageUrl,
        'found_date': DateTime.now().toIso8601String(),
        'user_id': userId,
      };

      final response = await _supabase
          .from(AppConstants.foundPetsTable)
          .insert(foundPetData)
          .select()
          .single();

      return FoundPet.fromJson(response);
    } catch (e) {
      throw Exception('Bulunan hayvan ekleme başarısız: $e');
    }
  }

  /// Bulunan hayvanı güncelle
  static Future<FoundPet> updateFoundPet(FoundPet foundPet) async {
    try {
      final response = await _supabase
          .from(AppConstants.foundPetsTable)
          .update(foundPet.toJson())
          .eq('id', foundPet.id)
          .select()
          .single();

      return FoundPet.fromJson(response);
    } catch (e) {
      throw Exception('Bulunan hayvan güncelleme başarısız: $e');
    }
  }

  /// Bulunan hayvanı sil
  static Future<void> deleteFoundPet(String id) async {
    try {
      await _supabase.from(AppConstants.foundPetsTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('Bulunan hayvan silme başarısız: $e');
    }
  }

  /// Mevcut kullanıcının bulunan hayvanlarını getir
  static Future<List<FoundPet>> getUserFoundPets(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.foundPetsTable)
          .select()
          .eq('user_id', userId)
          .order('found_date', ascending: false);

      return (response as List).map((json) => FoundPet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Bulunan hayvanlarınızı getirme başarısız: $e');
    }
  }
}
