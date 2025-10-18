import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../models/pet.dart';
import '../models/user.dart' as app_user;

class DatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ========== PETS ==========
  static Future<List<Pet>> getPets() async {
    try {
      final response = await _supabase
          .from(AppConstants.petsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((json) => Pet.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching pets: $e');
      return [];
    }
  }

  static Future<Pet?> getPetById(String id) async {
    try {
      final response = await _supabase
          .from(AppConstants.petsTable)
          .select()
          .eq('id', id)
          .single();

      return Pet.fromJson(response);
    } catch (e) {
      print('Error fetching pet: $e');
      return null;
    }
  }

  static Future<bool> addPet(Pet pet) async {
    try {
      await _supabase.from(AppConstants.petsTable).insert(pet.toJson());
      return true;
    } catch (e) {
      print('Error adding pet: $e');
      return false;
    }
  }

  static Future<bool> updatePet(Pet pet) async {
    try {
      await _supabase
          .from(AppConstants.petsTable)
          .update(pet.toJson())
          .eq('id', pet.id);
      return true;
    } catch (e) {
      print('Error updating pet: $e');
      return false;
    }
  }

  static Future<bool> deletePet(String id) async {
    try {
      await _supabase.from(AppConstants.petsTable).delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting pet: $e');
      return false;
    }
  }

  // ========== LOST PETS ==========
  static Future<List<Map<String, dynamic>>> getLostPets() async {
    try {
      final response = await _supabase
          .from(AppConstants.lostPetsTable)
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching lost pets: $e');
      return [];
    }
  }

  static Future<bool> addLostPet(Map<String, dynamic> lostPet) async {
    try {
      await _supabase.from(AppConstants.lostPetsTable).insert(lostPet);
      return true;
    } catch (e) {
      print('Error adding lost pet: $e');
      return false;
    }
  }

  // ========== ADOPTION PETS ==========
  static Future<List<Map<String, dynamic>>> getAdoptionPets() async {
    try {
      final response = await _supabase
          .from(AppConstants.adoptionPetsTable)
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching adoption pets: $e');
      return [];
    }
  }

  static Future<bool> addAdoptionPet(Map<String, dynamic> adoptionPet) async {
    try {
      await _supabase.from(AppConstants.adoptionPetsTable).insert(adoptionPet);
      return true;
    } catch (e) {
      print('Error adding adoption pet: $e');
      return false;
    }
  }

  // ========== VACCINATIONS ==========
  static Future<List<Map<String, dynamic>>> getVaccinations() async {
    try {
      final response = await _supabase
          .from(AppConstants.vaccinationsTable)
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching vaccinations: $e');
      return [];
    }
  }

  static Future<bool> addVaccination(Map<String, dynamic> vaccination) async {
    try {
      await _supabase.from(AppConstants.vaccinationsTable).insert(vaccination);
      return true;
    } catch (e) {
      print('Error adding vaccination: $e');
      return false;
    }
  }

  // ========== USERS ==========
  static Future<app_user.User?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from(AppConstants.usersTable)
          .select()
          .eq('id', user.id)
          .single();

      return app_user.User.fromJson(response);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<bool> updateUser(app_user.User user) async {
    try {
      await _supabase
          .from(AppConstants.usersTable)
          .update(user.toJson())
          .eq('id', user.id);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // ========== AUTHENTICATION ==========
  static Future<bool> signUp(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await _supabase.from(AppConstants.usersTable).insert({
          'id': response.user!.id,
          'email': email,
          'name': name,
          'created_at': DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing up: $e');
      return false;
    }
  }

  static Future<bool> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // ========== STORAGE ==========
  static Future<String?> uploadImage(
    String bucket,
    String path,
    Uint8List bytes,
  ) async {
    try {
      final response = await _supabase.storage
          .from(bucket)
          .uploadBinary(path, bytes);
      return response;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static String getImageUrl(String bucket, String path) {
    return _supabase.storage.from(bucket).getPublicUrl(path);
  }
}
