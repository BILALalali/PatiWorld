import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lost_pet.dart';
import '../models/adoption_pet.dart';
import '../models/user.dart' as app_user;
import '../models/vaccination.dart';
import '../constants/app_constants.dart';

class AdminService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== Lost Pets ====================
  static Future<List<LostPet>> getLostPets() async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => LostPet.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل جلب إعلانات المفقودات: ${e.toString()}');
    }
  }

  static Future<void> deleteLostPet(String id) async {
    try {
      await _supabase.from(AppConstants.lostPetsTable).delete().eq('id', id);
    } catch (e) {
      throw Exception('فشل حذف إعلان المفقودات: ${e.toString()}');
    }
  }

  // ==================== Adoption Pets ====================
  static Future<List<AdoptionPet>> getAdoptionPets() async {
    try {
      final response = await _supabase
          .from(AppConstants.adoptionPetsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AdoptionPet.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل جلب إعلانات التبني: ${e.toString()}');
    }
  }

  static Future<void> deleteAdoptionPet(String id) async {
    try {
      await _supabase
          .from(AppConstants.adoptionPetsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل حذف إعلان التبني: ${e.toString()}');
    }
  }

  // ==================== Users ====================
  static Future<List<app_user.User>> getUsers() async {
    try {
      final response = await _supabase
          .from(AppConstants.usersTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => app_user.User.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل جلب المستخدمين: ${e.toString()}');
    }
  }

  static Future<void> toggleUserActive(String userId, bool isActive) async {
    try {
      await _supabase
          .from(AppConstants.usersTable)
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      throw Exception('فشل تحديث حالة المستخدم: ${e.toString()}');
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from(AppConstants.usersTable).delete().eq('id', userId);
    } catch (e) {
      throw Exception('فشل حذف المستخدم: ${e.toString()}');
    }
  }

  // ==================== Vaccinations ====================
  static Future<List<Vaccination>> getVaccinations() async {
    try {
      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Vaccination.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل جلب سجلات اللقاحات: ${e.toString()}');
    }
  }

  static Future<void> deleteVaccination(String id) async {
    try {
      await _supabase
          .from(AppConstants.vaccinationsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل حذف سجل اللقاح: ${e.toString()}');
    }
  }

  // ==================== Statistics ====================
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Get all records and count them
      final lostPets = await _supabase
          .from(AppConstants.lostPetsTable)
          .select('id');

      final adoptionPets = await _supabase
          .from(AppConstants.adoptionPetsTable)
          .select('id');

      final users = await _supabase.from(AppConstants.usersTable).select('id');

      final vaccinations = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select('id');

      // Get user stats
      final userStatsResponse = await _supabase
          .from(AppConstants.userStatsTable)
          .select();

      int totalAdoptionPets = 0;
      int totalLostPets = 0;
      int totalVaccinations = 0;

      if (userStatsResponse is List) {
        for (var stat in userStatsResponse) {
          final statMap = Map<String, dynamic>.from(stat);
          totalAdoptionPets += statMap['total_adoption_pets'] as int? ?? 0;
          totalLostPets += statMap['total_lost_pets'] as int? ?? 0;
          totalVaccinations += statMap['total_vaccinations'] as int? ?? 0;
        }
      }

      return {
        'totalLostPets': (lostPets as List).length,
        'totalAdoptionPets': (adoptionPets as List).length,
        'totalUsers': (users as List).length,
        'totalVaccinations': (vaccinations as List).length,
        'totalAdoptionPetsFromStats': totalAdoptionPets,
        'totalLostPetsFromStats': totalLostPets,
        'totalVaccinationsFromStats': totalVaccinations,
      };
    } catch (e) {
      throw Exception('فشل جلب الإحصائيات: ${e.toString()}');
    }
  }
}
