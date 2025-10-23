import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lost_pet.dart';
import '../constants/app_constants.dart';

class LostPetService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Tüm aktif kayıp hayvanları getir
  static Future<List<LostPet>> getAllLostPets() async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) => LostPet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Kayıp hayvanları getirme başarısız: $e');
    }
  }

  /// ID ile belirli kayıp hayvanı getir
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

  /// Türüne göre kayıp hayvanları getir
  static Future<List<LostPet>> getLostPetsByType(String type) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('type', type)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) => LostPet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Kayıp hayvanları getirme başarısız: $e');
    }
  }

  /// Şehre göre kayıp hayvanları getir
  static Future<List<LostPet>> getLostPetsByCity(String city) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('city', city)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) => LostPet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Kayıp hayvanları getirme başarısız: $e');
    }
  }

  /// Kayıp hayvanlarda arama yap
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

      return (response as List).map((json) => LostPet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Arama başarısız: $e');
    }
  }

  /// Yeni kayıp hayvan ekle
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
        'lost_date': lostDate.toIso8601String().split(
          'T',
        )[0], // Format as YYYY-MM-DD
        'contact_number': contactNumber,
        'whatsapp_number': whatsappNumber,
        'image_url':
            imageUrl ??
            'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
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
      throw Exception('Kayıp hayvan ekleme başarısız: $e');
    }
  }

  /// Kayıp hayvanı güncelle
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
      throw Exception('Kayıp hayvan güncelleme başarısız: $e');
    }
  }

  /// Kayıp hayvanı sil (mantıksal silme)
  static Future<void> deleteLostPet(String id) async {
    try {
      await _supabase
          .from(AppConstants.lostPetsTable)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('Kayıp hayvan silme başarısız: $e');
    }
  }

  /// Mevcut kullanıcının kayıp hayvanlarını getir
  static Future<List<LostPet>> getUserLostPets(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) => LostPet.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Kayıp hayvanlarınızı getirme başarısız: $e');
    }
  }

  /// Kayıp hayvan istatistiklerini getir
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
      throw Exception('İstatistik getirme başarısız: $e');
    }
  }

  /// Kayıp hayvan durumunu güncelle (bulundu)
  static Future<void> markAsFound(String id) async {
    try {
      await _supabase
          .from(AppConstants.lostPetsTable)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw Exception('Hayvan durumu güncelleme başarısız: $e');
    }
  }
}
