import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Dosya adını geçersiz karakterlerden temizle
  static String _cleanFileName(String input) {
    // Tüm geçersiz karakterleri kaldır ve _ ile değiştir
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }

  /// Kayıp hayvan resmi yükle
  static Future<String> uploadLostPetImage({
    required File imageFile,
    required String userId,
    required String petName,
  }) async {
    try {
      // Giriş kontrolü
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Benzersiz dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanPetName = _cleanFileName(petName);
      final cleanUserId = _cleanFileName(userId);
      final fileName = 'lost_pet_${cleanUserId}_${cleanPetName}_$timestamp.jpg';

      // Resmi Storage'a yükle
      await _supabase.storage
          .from(AppConstants.petImagesBucket)
          .upload(fileName, imageFile);

      // Genel resim bağlantısını al
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
      // Giriş kontrolü
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Bucket yoksa oluştur
      final bucketCreated = await createBucketIfNotExists(
        AppConstants.petImagesBucket,
      );
      if (!bucketCreated) {
        throw Exception('Bucket oluşturma veya erişim başarısız');
      }

      // Benzersiz dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanPetName = _cleanFileName(petName);
      final cleanUserId = _cleanFileName(userId);
      final fileName =
          'adoption_pet_${cleanUserId}_${cleanPetName}_$timestamp.jpg';

      // Resmi bucket'a yükle
      await _supabase.storage
          .from(AppConstants.petImagesBucket)
          .upload(fileName, imageFile);

      // Genel resim bağlantısını al
      final imageUrl = _supabase.storage
          .from(AppConstants.petImagesBucket)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Resim yükleme başarısız: $e');
    }
  }

  /// Profil resmi yükle
  static Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      // Giriş kontrolü
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Bucket yoksa oluştur
      final bucketCreated = await createBucketIfNotExists(
        AppConstants.profileImagesBucket,
      );
      if (!bucketCreated) {
        throw Exception('Bucket oluşturma veya erişim başarısız');
      }

      // Benzersiz dosya adı oluştur
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanUserId = _cleanFileName(userId);
      final fileName = 'profile_${cleanUserId}_$timestamp.jpg';

      // Resmi bucket'a yükle
      await _supabase.storage
          .from(AppConstants.profileImagesBucket)
          .upload(fileName, imageFile);

      // Genel resim bağlantısını al
      final imageUrl = _supabase.storage
          .from(AppConstants.profileImagesBucket)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Profil resmi yükleme başarısız: $e');
    }
  }

  /// Resmi sil
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // Dosya adını bağlantıdan çıkar
      final fileName = imageUrl.split('/').last;

      // Resim türüne göre bucket belirle
      String bucketName;
      if (imageUrl.contains('profile')) {
        bucketName = AppConstants.profileImagesBucket;
      } else {
        bucketName = AppConstants.petImagesBucket;
      }

      // Resmi sil
      await _supabase.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      throw Exception('Resim silme başarısız: $e');
    }
  }

  /// Yüklemeden önce resmi sıkıştır (isteğe bağlı)
  static Future<File> compressImage(File imageFile) async {
    // Burada flutter_image_compress gibi resim sıkıştırma kütüphanesi eklenebilir
    // Şimdilik aynı dosyayı döndürüyoruz
    return imageFile;
  }

  /// Dosya türünün geçerliliğini kontrol et
  static bool isValidImageType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Dosya boyutunu kontrol et
  static bool isValidImageSize(File imageFile) {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5 MB
    return imageFile.lengthSync() <= maxSizeInBytes;
  }

  /// Storage bağlantısını test et
  static Future<bool> testStorageConnection() async {
    try {
      // Önce giriş kontrolü
      final user = _supabase.auth.currentUser;
      print('Current user: ${user?.id ?? "Not logged in"}');

      // Bucket listesini getirmeyi dene
      final buckets = await _supabase.storage.listBuckets();
      print('Available buckets: ${buckets.map((b) => b.name).toList()}');
      print('Looking for bucket: ${AppConstants.petImagesBucket}');

      // Gerekli bucket'ın varlığını kontrol et
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

  /// Bucket'ın varlığını kontrol et
  static Future<bool> bucketExists(String bucketName) async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      return buckets.any((bucket) => bucket.name == bucketName);
    } catch (e) {
      print('Error checking bucket existence: $e');
      return false;
    }
  }

  /// Bucket yoksa oluştur
  static Future<bool> createBucketIfNotExists(String bucketName) async {
    try {
      // Önce bucket'ın varlığını kontrol et
      final exists = await bucketExists(bucketName);
      if (exists) {
        print('✅ Bucket $bucketName already exists');
        return true;
      }

      // Bucket'ı oluştur
      print('Creating bucket: $bucketName');
      await _supabase.storage.createBucket(
        bucketName,
        BucketOptions(
          public: true, // Resimlere erişim için bucket'ı genel yap
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

      // Hata türünü analiz et ve net mesaj ver
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

  /// Storage'ı tamamen ayarla (gerekli tüm bucket'ları oluştur)
  static Future<bool> setupStorage() async {
    try {
      print('🚀 Setting up Storage...');

      // Hayvan resimleri bucket'ını oluştur
      final petImagesBucketCreated = await createBucketIfNotExists(
        AppConstants.petImagesBucket,
      );

      // Profil resimleri bucket'ını oluştur
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
