import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../constants/app_constants.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  static app_user.User? get currentUser {
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      return app_user.User(
        id: session!.user.id,
        email: session.user.email ?? '',
        isEmailVerified: session.user.emailConfirmedAt != null,
        createdAt: DateTime.parse(session.user.createdAt),
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }

  // Get current user with full profile data from database
  static Future<app_user.User?> getCurrentUserWithProfile() async {
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      try {
        final response = await _supabase
            .from(AppConstants.usersTable)
            .select()
            .eq('id', session!.user.id)
            .single();

        return app_user.User.fromJson(response);
      } catch (e) {
        // Eğer veritabanında profil bulunamazsa, temel bilgileri döndür
        return app_user.User(
          id: session!.user.id,
          email: session.user.email ?? '',
          isEmailVerified: session.user.emailConfirmedAt != null,
          createdAt: DateTime.parse(session.user.createdAt),
          updatedAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  // Check if user is logged in
  static bool get isLoggedIn => _supabase.auth.currentSession != null;

  // Get auth stream
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String countryCode,
  }) async {
    try {
      // Register user with Supabase Auth
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'country_code': countryCode,
        },
      );

      if (response.user != null) {
        // Create user profile in database
        try {
          await _createUserProfile(
            userId: response.user!.id,
            email: email,
            fullName: fullName,
            phoneNumber: phoneNumber,
            countryCode: countryCode,
          );
        } catch (profileError) {
          // Log the error but don't fail the registration
          print('Profile creation error: $profileError');
        }
      }

      return response;
    } catch (e) {
      throw Exception('Hesap oluşturma başarısız: ${e.toString()}');
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      throw Exception('Giriş yapma başarısız: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Çıkış yapma başarısız: ${e.toString()}');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception(
        'Şifre sıfırlama bağlantısı gönderme başarısız: ${e.toString()}',
      );
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? countryCode,
    String? profileImageUrl,
    bool clearProfileImage = false,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (countryCode != null) updates['country_code'] = countryCode;
      if (profileImageUrl != null) {
        updates['profile_image'] = profileImageUrl;
      } else if (clearProfileImage) {
        updates['profile_image'] = null;
      }

      // Önce kullanıcının mevcut olup olmadığını kontrol et
      final existingUser = await _supabase
          .from(AppConstants.usersTable)
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existingUser == null) {
        // Kullanıcı yoksa oluştur
        await _createUserProfile(
          userId: userId,
          email: _supabase.auth.currentUser?.email ?? '',
          fullName: fullName ?? '',
          phoneNumber: phoneNumber ?? '',
          countryCode: countryCode ?? '+90',
        );
      } else {
        // Kullanıcı varsa güncelle
        await _supabase
            .from(AppConstants.usersTable)
            .update(updates)
            .eq('id', userId);
      }
    } catch (e) {
      throw Exception('Profil güncelleme başarısız: ${e.toString()}');
    }
  }

  // Get user profile from database
  static Future<app_user.User?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return app_user.User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Create user profile in database
  static Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phoneNumber,
    required String countryCode,
  }) async {
    try {
      await _supabase.from(AppConstants.usersTable).insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'country_code': countryCode,
        'is_email_verified': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Eğer kullanıcı zaten varsa, güncelle
      if (e.toString().contains('duplicate key') ||
          e.toString().contains('already exists')) {
        await _supabase
            .from(AppConstants.usersTable)
            .update({
              'email': email,
              'full_name': fullName,
              'phone_number': phoneNumber,
              'country_code': countryCode,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);
      } else {
        throw Exception('Profil oluşturma başarısız: ${e.toString()}');
      }
    }
  }

  // Verify email
  static Future<void> verifyEmail() async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: _supabase.auth.currentUser?.email,
      );
    } catch (e) {
      throw Exception(
        'Doğrulama bağlantısı gönderme başarısız: ${e.toString()}',
      );
    }
  }

  // Check if email is verified
  static bool get isEmailVerified {
    final session = _supabase.auth.currentSession;
    return session?.user.emailConfirmedAt != null;
  }

  // Create profile for existing users who don't have one
  static Future<void> createProfileForExistingUser() async {
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      try {
        // Check if profile already exists
        final existingProfile = await _supabase
            .from(AppConstants.usersTable)
            .select('id')
            .eq('id', session!.user.id)
            .maybeSingle();

        if (existingProfile == null) {
          // Create profile for existing user
          await _createUserProfile(
            userId: session.user.id,
            email: session.user.email ?? '',
            fullName: session.user.userMetadata?['full_name'] ?? '',
            phoneNumber: session.user.userMetadata?['phone_number'] ?? '',
            countryCode: session.user.userMetadata?['country_code'] ?? '+90',
          );
        }
      } catch (e) {
        print('Error creating profile for existing user: $e');
      }
    }
  }
}
