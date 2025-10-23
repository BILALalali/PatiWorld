import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class DebugService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Debug function to check current user and database data
  static Future<void> debugUserStats() async {
    try {
      print('=== DEBUG USER STATS ===');

      // Check current auth session
      final session = _supabase.auth.currentSession;
      print('Auth session: $session');
      print('Auth user ID: ${session?.user.id}');

      if (session?.user != null) {
        final userId = session!.user.id;
        print('Current user ID from auth: $userId');

        // Check if user exists in users table
        try {
          final userResponse = await _supabase
              .from(AppConstants.usersTable)
              .select('*')
              .eq('id', userId)
              .maybeSingle();

          print('User in database: $userResponse');
        } catch (e) {
          print('Error checking user in database: $e');
        }

        // Check adoption pets
        try {
          final adoptionResponse = await _supabase
              .from(AppConstants.adoptionPetsTable)
              .select('*')
              .eq('user_id', userId);

          print('Adoption pets for user: ${adoptionResponse.length}');
          print('Adoption pets data: $adoptionResponse');
        } catch (e) {
          print('Error checking adoption pets: $e');
        }

        // Check lost pets
        try {
          final lostPetsResponse = await _supabase
              .from(AppConstants.lostPetsTable)
              .select('*')
              .eq('user_id', userId);

          print('Lost pets for user: ${lostPetsResponse.length}');
          print('Lost pets data: $lostPetsResponse');
        } catch (e) {
          print('Error checking lost pets: $e');
        }

        // Check vaccinations
        try {
          final vaccinationsResponse = await _supabase
              .from(AppConstants.vaccinationsTable)
              .select('*')
              .eq('user_id', userId);

          print('Vaccinations for user: ${vaccinationsResponse.length}');
          print('Vaccinations data: $vaccinationsResponse');
        } catch (e) {
          print('Error checking vaccinations: $e');
        }

        // Check all adoption pets to see what user_ids exist
        try {
          final allAdoptionPets = await _supabase
              .from(AppConstants.adoptionPetsTable)
              .select('user_id');

          print('All adoption pets user_ids: $allAdoptionPets');
        } catch (e) {
          print('Error checking all adoption pets: $e');
        }

        // Check all lost pets to see what user_ids exist
        try {
          final allLostPets = await _supabase
              .from(AppConstants.lostPetsTable)
              .select('user_id');

          print('All lost pets user_ids: $allLostPets');
        } catch (e) {
          print('Error checking all lost pets: $e');
        }
      }

      print('=== END DEBUG ===');
    } catch (e) {
      print('Debug error: $e');
    }
  }
}
