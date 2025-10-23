import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class UserStatsService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get the correct user ID for statistics - handles cases where auth user ID might differ from database user ID
  static Future<String?> getCorrectUserId() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session?.user != null) {
        final authUserId = session!.user.id;
        print('Auth user ID: $authUserId');

        // First try to find user by auth ID
        try {
          final userResponse = await _supabase
              .from(AppConstants.usersTable)
              .select('id')
              .eq('id', authUserId)
              .maybeSingle();

          if (userResponse != null) {
            print('Found user by auth ID: ${userResponse['id']}');
            return userResponse['id'];
          }
        } catch (e) {
          print('Error finding user by auth ID: $e');
        }

        // If not found by auth ID, try to find by email
        try {
          final email = session.user.email;
          if (email != null) {
            final userResponse = await _supabase
                .from(AppConstants.usersTable)
                .select('id')
                .eq('email', email)
                .maybeSingle();

            if (userResponse != null) {
              print('Found user by email: ${userResponse['id']}');
              return userResponse['id'];
            }
          }
        } catch (e) {
          print('Error finding user by email: $e');
        }

        // Fallback: return auth user ID
        print('Using auth user ID as fallback: $authUserId');
        return authUserId;
      }
      return null;
    } catch (e) {
      print('Error getting correct user ID: $e');
      return null;
    }
  }

  /// Get user statistics including adoption pets, lost pets, vaccinations, and days in app
  static Future<Map<String, int>> getUserStats(String userId) async {
    try {
      print('Getting stats for user ID: $userId');

      // Get all statistics in parallel for better performance
      final results = await Future.wait([
        _getAdoptionPetsCount(userId),
        _getLostPetsCount(userId),
        _getVaccinationsCount(userId),
        _getDaysInApp(userId),
      ]);

      final stats = {
        'adoption_pets_count': results[0],
        'lost_pets_count': results[1],
        'vaccinations_count': results[2],
        'days_in_app': results[3],
      };

      print('Final stats: $stats');
      return stats;
    } catch (e) {
      print('Error in getUserStats: $e');
      throw Exception('İstatistikleri getirme başarısız: $e');
    }
  }

  /// Get count of adoption pets for a specific user
  static Future<int> _getAdoptionPetsCount(String userId) async {
    try {
      print('Getting adoption pets count for user: $userId');
      final response = await _supabase
          .from(AppConstants.adoptionPetsTable)
          .select('id')
          .eq('user_id', userId);

      print('Adoption pets response: $response');
      print('Adoption pets count: ${response.length}');
      return response.length;
    } catch (e) {
      print('Adoption pets count error: $e');
      return 0;
    }
  }

  /// Get count of lost pets for a specific user
  static Future<int> _getLostPetsCount(String userId) async {
    try {
      print('Getting lost pets count for user: $userId');
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select('id')
          .eq('user_id', userId)
          .eq('is_active', true);

      print('Lost pets response: $response');
      print('Lost pets count: ${response.length}');
      return response.length;
    } catch (e) {
      print('Lost pets count error: $e');
      return 0;
    }
  }

  /// Get count of vaccinations for a specific user
  static Future<int> _getVaccinationsCount(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select('id')
          .eq('user_id', userId);

      return response.length;
    } catch (e) {
      print('Vaccinations count error: $e');
      return 0;
    }
  }

  /// Get days since user registration (days in app)
  static Future<int> _getDaysInApp(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.usersTable)
          .select('created_at')
          .eq('id', userId)
          .single();

      if (response['created_at'] != null) {
        final createdAt = DateTime.parse(response['created_at']);
        final now = DateTime.now();
        final difference = now.difference(createdAt).inDays;
        return difference >= 0 ? difference : 0;
      }
      return 0;
    } catch (e) {
      print('Days in app error: $e');
      return 0;
    }
  }

  /// Get individual adoption pets count
  static Future<int> getAdoptionPetsCount(String userId) async {
    return await _getAdoptionPetsCount(userId);
  }

  /// Get individual lost pets count
  static Future<int> getLostPetsCount(String userId) async {
    return await _getLostPetsCount(userId);
  }

  /// Get individual vaccinations count
  static Future<int> getVaccinationsCount(String userId) async {
    return await _getVaccinationsCount(userId);
  }

  /// Get individual days in app
  static Future<int> getDaysInApp(String userId) async {
    return await _getDaysInApp(userId);
  }
}
