import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vaccination.dart';
import '../constants/app_constants.dart';

class VaccinationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // إضافة لقاح جديد
  static Future<Vaccination> addVaccination(Vaccination vaccination) async {
    try {
      // إنشاء نسخة من البيانات مع معرف وهمي
      final vaccinationData = vaccination.toJson();
      vaccinationData['user_id'] = '00000000-0000-0000-0000-000000000001';
      
      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .insert(vaccinationData)
          .select()
          .single();

      return Vaccination.fromJson(response);
    } catch (e) {
      throw Exception('فشل في إضافة اللقاح: $e');
    }
  }

  // جلب جميع لقاحات المستخدم
  static Future<List<Vaccination>> getUserVaccinations() async {
    try {
      // جلب جميع اللقاحات بدون فلترة user_id للاختبار
      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Vaccination.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب اللقاحات: $e');
    }
  }

  // جلب لقاح محدد
  static Future<Vaccination> getVaccination(String id) async {
    try {
      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select()
          .eq('id', id)
          .single();

      return Vaccination.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب اللقاح: $e');
    }
  }

  // تحديث لقاح
  static Future<Vaccination> updateVaccination(Vaccination vaccination) async {
    try {
      // إنشاء نسخة من البيانات مع معرف وهمي
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
      throw Exception('فشل في تحديث اللقاح: $e');
    }
  }

  // حذف لقاح
  static Future<void> deleteVaccination(String id) async {
    try {
      await _supabase
          .from(AppConstants.vaccinationsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('فشل في حذف اللقاح: $e');
    }
  }

  // جلب اللقاحات المنتهية الصلاحية
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
      throw Exception('فشل في جلب اللقاحات المنتهية الصلاحية: $e');
    }
  }

  // جلب اللقاحات القادمة (خلال 7 أيام)
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
      throw Exception('فشل في جلب اللقاحات القادمة: $e');
    }
  }

  // جلب إحصائيات اللقاحات
  static Future<Map<String, int>> getVaccinationStats() async {
    try {
      final allVaccinations = await getUserVaccinations();
      final overdueVaccinations = await getOverdueVaccinations();
      final upcomingVaccinations = await getUpcomingVaccinations();

      return {
        'total': allVaccinations.length,
        'overdue': overdueVaccinations.length,
        'upcoming': upcomingVaccinations.length,
        'scheduled': allVaccinations.length - overdueVaccinations.length - upcomingVaccinations.length,
      };
    } catch (e) {
      throw Exception('فشل في جلب إحصائيات اللقاحات: $e');
    }
  }
}
