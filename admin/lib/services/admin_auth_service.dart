import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/admin.dart';
import '../constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _adminPrefsKey = 'admin_session';
  static const String _adminIdKey = 'admin_id';
  static const String _adminEmailKey = 'admin_email';

  // Hash password using SHA-256 (for simplicity, in production use bcrypt)
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign in with email and password
  static Future<Admin> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);

      // Query admin from database
      final response = await _supabase
          .from(AppConstants.adminsTable)
          .select()
          .eq('email', email)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }

      // Verify password
      if (response['password_hash'] != hashedPassword) {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }

      final admin = Admin.fromJson(response);

      // Save admin session
      await _saveAdminSession(admin);

      return admin;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_adminPrefsKey);
      await prefs.remove(_adminIdKey);
      await prefs.remove(_adminEmailKey);
    } catch (e) {
      throw Exception('فشل تسجيل الخروج: ${e.toString()}');
    }
  }

  // Get current admin
  static Future<Admin?> getCurrentAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString(_adminIdKey);

      if (adminId == null) {
        return null;
      }

      final response = await _supabase
          .from(AppConstants.adminsTable)
          .select()
          .eq('id', adminId)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        await signOut();
        return null;
      }

      return Admin.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Check if admin is logged in
  static Future<bool> isLoggedIn() async {
    final admin = await getCurrentAdmin();
    return admin != null;
  }

  // Save admin session
  static Future<void> _saveAdminSession(Admin admin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_adminIdKey, admin.id);
    await prefs.setString(_adminEmailKey, admin.email);
    await prefs.setString(_adminPrefsKey, admin.toJson().toString());
  }

  // Create new admin
  static Future<Admin> createAdmin({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      // Check if email already exists
      final existingAdmin = await _supabase
          .from(AppConstants.adminsTable)
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingAdmin != null) {
        throw Exception('البريد الإلكتروني مستخدم بالفعل');
      }

      final hashedPassword = _hashPassword(password);

      final response = await _supabase
          .from(AppConstants.adminsTable)
          .insert({
            'email': email,
            'full_name': fullName,
            'password_hash': hashedPassword,
            'is_active': true,
          })
          .select()
          .single();

      return Admin.fromJson(response);
    } catch (e) {
      throw Exception('فشل إنشاء المشرف: ${e.toString()}');
    }
  }

  // Update admin
  static Future<Admin> updateAdmin({
    required String adminId,
    String? email,
    String? fullName,
    String? password,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (email != null) {
        // Check if email already exists (excluding current admin)
        final existingAdmin = await _supabase
            .from(AppConstants.adminsTable)
            .select()
            .eq('email', email)
            .neq('id', adminId)
            .maybeSingle();

        if (existingAdmin != null) {
          throw Exception('البريد الإلكتروني مستخدم بالفعل');
        }
        updates['email'] = email;
      }

      if (fullName != null) updates['full_name'] = fullName;
      if (password != null) updates['password_hash'] = _hashPassword(password);
      if (isActive != null) updates['is_active'] = isActive;

      final response = await _supabase
          .from(AppConstants.adminsTable)
          .update(updates)
          .eq('id', adminId)
          .select()
          .single();

      return Admin.fromJson(response);
    } catch (e) {
      throw Exception('فشل تحديث المشرف: ${e.toString()}');
    }
  }

  // Delete admin
  static Future<void> deleteAdmin(String adminId) async {
    try {
      await _supabase.from(AppConstants.adminsTable).delete().eq('id', adminId);
    } catch (e) {
      throw Exception('فشل حذف المشرف: ${e.toString()}');
    }
  }

  // Get all admins
  static Future<List<Admin>> getAllAdmins() async {
    try {
      final response = await _supabase
          .from(AppConstants.adminsTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Admin.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل جلب المشرفين: ${e.toString()}');
    }
  }
}
