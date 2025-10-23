import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vaccination.dart';
import '../constants/app_constants.dart';

class VaccinationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Yeni aşı ekle
  static Future<Vaccination> addVaccination(Vaccination vaccination) async {
    try {
      final vaccinationData = vaccination.toJson();
      print('Original vaccination data: $vaccinationData');

      // Remove id field for new vaccinations - let database generate it
      vaccinationData.remove('id');
      print('Vaccination data after removing id: $vaccinationData');

      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .insert(vaccinationData)
          .select()
          .single();

      print('Response from database: $response');
      return Vaccination.fromJson(response);
    } catch (e) {
      print('Error adding vaccination: $e');
      throw Exception('Aşı ekleme başarısız: $e');
    }
  }

  // Kullanıcının tüm aşılarını getir
  static Future<List<Vaccination>> getUserVaccinations() async {
    try {
      // Get current user ID
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Vaccination.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Aşıları getirme başarısız: $e');
    }
  }

  // Belirli aşıyı getir
  static Future<Vaccination> getVaccination(String id) async {
    try {
      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select()
          .eq('id', id)
          .single();

      return Vaccination.fromJson(response);
    } catch (e) {
      throw Exception('Aşı getirme başarısız: $e');
    }
  }

  // Aşıyı güncelle
  static Future<Vaccination> updateVaccination(Vaccination vaccination) async {
    try {
      // Sahte ID ile veri kopyası oluştur
      final vaccinationData = vaccination.toJson();
      vaccinationData['user_id'] = '00000000-0000-0000-0000-000000000001';

      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .update(vaccinationData)
          .eq('id', vaccination.id)
          .select()
          .single();

      return Vaccination.fromJson(response);
    } catch (e) {
      throw Exception('Aşı güncelleme başarısız: $e');
    }
  }

  // Aşıyı sil
  static Future<void> deleteVaccination(String id) async {
    try {
      await _supabase
          .from(AppConstants.vaccinationsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Aşı silme başarısız: $e');
    }
  }

  // Süresi geçmiş aşıları getir
  static Future<List<Vaccination>> getOverdueVaccinations() async {
    try {
      final now = DateTime.now().toIso8601String().split('T')[0];

      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select()
          .lt('next_vaccine_date', now)
          .order('next_vaccine_date', ascending: true);

      return (response as List)
          .map((json) => Vaccination.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Süresi geçmiş aşıları getirme başarısız: $e');
    }
  }

  // Yaklaşan aşıları getir (7 gün içinde)
  static Future<List<Vaccination>> getUpcomingVaccinations() async {
    try {
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select()
          .gte('next_vaccine_date', now.toIso8601String().split('T')[0])
          .lte('next_vaccine_date', nextWeek.toIso8601String().split('T')[0])
          .order('next_vaccine_date', ascending: true);

      return (response as List)
          .map((json) => Vaccination.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Yaklaşan aşıları getirme başarısız: $e');
    }
  }

  // Aşı istatistiklerini getir
  static Future<Map<String, int>> getVaccinationStats() async {
    try {
      final allVaccinations = await getUserVaccinations();
      final overdueVaccinations = await getOverdueVaccinations();
      final upcomingVaccinations = await getUpcomingVaccinations();

      return {
        'total': allVaccinations.length,
        'overdue': overdueVaccinations.length,
        'upcoming': upcomingVaccinations.length,
        'scheduled':
            allVaccinations.length -
            overdueVaccinations.length -
            upcomingVaccinations.length,
      };
    } catch (e) {
      throw Exception('Aşı istatistiklerini getirme başarısız: $e');
    }
  }
}
