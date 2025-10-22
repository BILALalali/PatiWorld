import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// تنظيف اسم الملف من الرموز غير الصالحة
  static String _cleanFileName(String input) {
    // إزالة جميع الرموز غير الصالحة واستبدالها بـ _
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  /// رفع صورة حيوان مفقود
  static Future<String> uploadLostPetImage({
    required File imageFile,
    required String userId,
    required String petName,
  }) async {
    try {
      // التحقق من تسجيل الدخول
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // إنشاء اسم فريد للملف
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanPetName = _cleanFileName(petName);
      final cleanUserId = _cleanFileName(userId);
      final fileName = 'lost_pet_${cleanUserId}_${cleanPetName}_$timestamp.jpg';

      // رفع الصورة إلى Storage
      await _supabase.storage
          .from(AppConstants.petImagesBucket)
          .upload(fileName, imageFile);

      // الحصول على رابط الصورة العامة
      final imageUrl = _supabase.storage
          .from(AppConstants.petImagesBucket)
          .getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      throw Exception('Resim yükleme hatası: ${e.toString()}');
    }
  }

  /// رفع صورة حيوان للتبني
  static Future<String> uploadAdoptionPetImage({
    required File imageFile,
    required String userId,
    required String petName,
  }) async {
    try {
      // التحقق من تسجيل الدخول
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل دخول');
      }

      // إنشاء الـ bucket إذا لم يكن موجوداً
      final bucketCreated = await createBucketIfNotExists(
        AppConstants.petImagesBucket,
      );
      if (!bucketCreated) {
        throw Exception('فشل في إنشاء أو الوصول للـ bucket');
      }

      // إنشاء اسم فريد للملف
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanPetName = _cleanFileName(petName);
      final cleanUserId = _cleanFileName(userId);
      final fileName =
          'adoption_pet_${cleanUserId}_${cleanPetName}_$timestamp.jpg';

      // رفع الصورة إلى bucket
      await _supabase.storage
          .from(AppConstants.petImagesBucket)
          .upload(fileName, imageFile);

      // الحصول على رابط الصورة العامة
      final imageUrl = _supabase.storage
          .from(AppConstants.petImagesBucket)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('فشل في رفع الصورة: $e');
    }
  }

  /// رفع صورة الملف الشخصي
  static Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // التحقق من تسجيل الدخول
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل دخول');
      }

      // إنشاء الـ bucket إذا لم يكن موجوداً
      final bucketCreated = await createBucketIfNotExists(
        AppConstants.profileImagesBucket,
      );
      if (!bucketCreated) {
        throw Exception('فشل في إنشاء أو الوصول للـ bucket');
      }

      // إنشاء اسم فريد للملف
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanUserId = _cleanFileName(userId);
      final fileName = 'profile_${cleanUserId}_$timestamp.jpg';

      // رفع الصورة إلى bucket
      await _supabase.storage
          .from(AppConstants.profileImagesBucket)
          .upload(fileName, imageFile);

      // الحصول على رابط الصورة العامة
      final imageUrl = _supabase.storage
          .from(AppConstants.profileImagesBucket)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('فشل في رفع صورة الملف الشخصي: $e');
    }
  }

  /// حذف صورة
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // استخراج اسم الملف من الرابط
      final fileName = imageUrl.split('/').last;

      // تحديد الـ bucket بناءً على نوع الصورة
      String bucketName;
      if (imageUrl.contains('profile')) {
        bucketName = AppConstants.profileImagesBucket;
      } else {
        bucketName = AppConstants.petImagesBucket;
      }

      // حذف الصورة
      await _supabase.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      throw Exception('فشل في حذف الصورة: $e');
    }
  }

  /// ضغط الصورة قبل الرفع (اختياري)
  static Future<File> compressImage(File imageFile) async {
    // يمكن إضافة مكتبة ضغط الصور هنا مثل flutter_image_compress
    // للآن سنعيد نفس الملف
    return imageFile;
  }

  /// التحقق من صحة نوع الملف
  static bool isValidImageType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// التحقق من حجم الملف
  static bool isValidImageSize(File imageFile) {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5 MB
    return imageFile.lengthSync() <= maxSizeInBytes;
  }

  /// اختبار الاتصال بـ Storage
  static Future<bool> testStorageConnection() async {
    try {
      // التحقق من تسجيل الدخول أولاً
      final user = _supabase.auth.currentUser;
      print('Current user: ${user?.id ?? "Not logged in"}');

      // محاولة جلب قائمة الـ buckets
      final buckets = await _supabase.storage.listBuckets();
      print('Available buckets: ${buckets.map((b) => b.name).toList()}');
      print('Looking for bucket: ${AppConstants.petImagesBucket}');

      // التحقق من وجود الـ bucket المطلوب
      final hasPetImagesBucket = buckets.any(
        (bucket) => bucket.name == AppConstants.petImagesBucket,
      );
      if (!hasPetImagesBucket) {
        print('Warning: pet-images bucket not found!');
        print('Please create the bucket manually in Supabase Dashboard');
        print('Expected bucket name: ${AppConstants.petImagesBucket}');
      } else {
        print('✅ pet-images bucket found!');
      }

      return true;
    } catch (e) {
      print('Storage connection failed: $e');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// التحقق من وجود الـ bucket
  static Future<bool> bucketExists(String bucketName) async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      return buckets.any((bucket) => bucket.name == bucketName);
    } catch (e) {
      print('Error checking bucket existence: $e');
      return false;
    }
  }

  /// إنشاء الـ bucket إذا لم يكن موجوداً
  static Future<bool> createBucketIfNotExists(String bucketName) async {
    try {
      // التحقق من وجود الـ bucket أولاً
      final exists = await bucketExists(bucketName);
      if (exists) {
        print('✅ Bucket $bucketName already exists');
        return true;
      }

      // إنشاء الـ bucket
      print('Creating bucket: $bucketName');
      await _supabase.storage.createBucket(
        bucketName,
        BucketOptions(
          public: true, // جعل الـ bucket عام للوصول للصور
          allowedMimeTypes: [
            'image/jpeg',
            'image/png',
            'image/gif',
            'image/webp',
          ],
          fileSizeLimit: '5MB', // 5MB limit
        ),
      );

      print('✅ Bucket $bucketName created successfully');
      return true;
    } catch (e) {
      print('❌ Failed to create bucket $bucketName: $e');

      // تحليل نوع الخطأ وإعطاء رسالة واضحة
      if (e.toString().contains('row-level security policy') ||
          e.toString().contains('Unauthorized') ||
          e.toString().contains('403')) {
        print(
          '🔒 RLS Policy Error: User does not have permission to create buckets',
        );
        print('📋 Manual Setup Required:');
        print('   1. Go to Supabase Dashboard > Storage');
        print('   2. Create bucket manually: $bucketName');
        print('   3. Set as Public bucket');
        print('   4. Configure RLS policies for public access');
      }

      return false;
    }
  }

  /// إعداد Storage بالكامل (إنشاء جميع الـ buckets المطلوبة)
  static Future<bool> setupStorage() async {
    try {
      print('🚀 Setting up Storage...');

      // إنشاء bucket صور الحيوانات
      final petImagesBucketCreated = await createBucketIfNotExists(
        AppConstants.petImagesBucket,
      );

      // إنشاء bucket صور الملفات الشخصية
      final profileImagesBucketCreated = await createBucketIfNotExists(
        AppConstants.profileImagesBucket,
      );

      if (petImagesBucketCreated && profileImagesBucketCreated) {
        print('✅ Storage setup completed successfully!');
        return true;
      } else {
        print('❌ Storage setup failed!');
        return false;
      }
    } catch (e) {
      print('❌ Storage setup error: $e');
      return false;
    }
  }
}
