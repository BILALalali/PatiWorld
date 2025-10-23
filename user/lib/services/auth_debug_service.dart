import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDebugService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Debug function to check authentication status
  static void debugAuthStatus() {
    try {
      print('=== AUTH DEBUG ===');
      
      final session = _supabase.auth.currentSession;
      print('Current session: $session');
      
      final user = _supabase.auth.currentUser;
      print('Current user: $user');
      
      if (user != null) {
        print('User ID: ${user.id}');
        print('User email: ${user.email}');
        print('User created at: ${user.createdAt}');
      } else {
        print('No user found - user is null');
      }
      
      print('=== END AUTH DEBUG ===');
    } catch (e) {
      print('Auth debug error: $e');
    }
  }
}
