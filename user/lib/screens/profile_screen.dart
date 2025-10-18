import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app_user;
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  app_user.User? _currentUser; // Current user data

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // Load user data from database
    try {
      // First, try to create profile for existing user if it doesn't exist
      await AuthService.createProfileForExistingUser();

      // Then load user data
      final user = await AuthService.getCurrentUserWithProfile();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.fullName ?? '';
          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber ?? '';
        });
      } else {
        // Fallback to basic user data if database fetch fails
        final user = AuthService.currentUser;
        if (user != null) {
          setState(() {
            _nameController.text = user.fullName ?? '';
            _emailController.text = user.email;
            _phoneController.text = user.phoneNumber ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback to basic user data if database fetch fails
      final user = AuthService.currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = user.fullName ?? '';
          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Image Section
                _buildProfileImageSection(),

                const SizedBox(height: AppConstants.extraLargePadding),

                // Profile Information
                _buildProfileInfoSection(),

                const SizedBox(height: AppConstants.extraLargePadding),

                // Statistics Section
                _buildStatisticsSection(),

                const SizedBox(height: AppConstants.extraLargePadding),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : _currentUser?.profileImageUrl != null
                    ? Image.network(
                        _currentUser!.profileImageUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
              ),
            ),
            if (_isEditing) // Only show edit button when in editing mode
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changeProfileImage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.mediumPadding),
        Text(
          _nameController.text.isNotEmpty ? _nameController.text : 'Kullanıcı',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          'PatiWorld Üyesi',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProfileInfoSection() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hesap Bilgileri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),

            // Full Name
            _buildInfoField(
              label: 'Ad Soyad',
              controller: _nameController,
              icon: Icons.person,
              enabled: _isEditing,
              validator: (value) {
                if (_isEditing && (value == null || value.isEmpty)) {
                  return 'Lütfen ad soyad giriniz';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Email
            _buildInfoField(
              label: 'E-posta',
              controller: _emailController,
              icon: Icons.email,
              enabled: false, // Email cannot be changed
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: AppConstants.mediumPadding),

            // Phone Number
            _buildInfoField(
              label: 'Telefon Numarası',
              controller: _phoneController,
              icon: Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (_isEditing && (value == null || value.isEmpty)) {
                  return 'Lütfen telefon numarası giriniz';
                }
                if (_isEditing && value != null && value.length < 10) {
                  return 'Telefon numarası en az 10 haneli olmalıdır';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İstatistikleriniz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Kayıp İlanları',
                    '2',
                    Icons.search,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: AppConstants.mediumPadding),
                Expanded(
                  child: _buildStatCard(
                    'Sahiplendirme İlanları',
                    '1',
                    Icons.favorite,
                    Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Kayıtlı Aşılar',
                    '3',
                    Icons.medical_services,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: AppConstants.mediumPadding),
                Expanded(
                  child: _buildStatCard(
                    'Uygulamada Gün',
                    '15',
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            label: Text(
              _isEditing ? 'Değişiklikleri Kaydet' : 'Profili Düzenle',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.mediumPadding),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        String? imageUrl;

        // Upload image if selected
        if (_selectedImage != null) {
          imageUrl = await _uploadProfileImage(user.id);
        }

        // Update user profile in database
        await AuthService.updateUserProfile(
          userId: user.id,
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          profileImageUrl: imageUrl,
        );

        // Reload user data to get updated profile
        await _loadUserData();

        setState(() {
          _isEditing = false;
          _selectedImage = null; // Clear selected image after saving
        });

        _showSuccessSnackBar('Değişiklikler başarıyla kaydedildi');
      } else {
        _showErrorSnackBar('Kullanıcı bilgileri bulunamadı');
      }
    } catch (e) {
      _showErrorSnackBar(
        'Değişiklikler kaydedilirken hata oluştu: ${e.toString()}',
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Çıkış yapılırken hata oluştu: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _changeProfileImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              if (_currentUser?.profileImageUrl != null ||
                  _selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Resmi Kaldır'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeProfileImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _showSuccessSnackBar('Resim seçildi');
      }
    } catch (e) {
      _showErrorSnackBar(
        'Galeriden resim seçilirken hata oluştu: ${e.toString()}',
      );
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      setState(() {
        _selectedImage = null;
      });

      final user = AuthService.currentUser;
      if (user != null) {
        await AuthService.updateUserProfile(
          userId: user.id,
          clearProfileImage: true,
        );
        _showSuccessSnackBar('Profil resmi kaldırıldı');
      }
    } catch (e) {
      _showErrorSnackBar('Resim kaldırılırken hata oluştu: ${e.toString()}');
    }
  }

  Future<String> _uploadProfileImage(String userId) async {
    try {
      final fileBytes = await _selectedImage!.readAsBytes();
      final fileName = 'profile_$userId.jpg';

      // First, try to create the bucket if it doesn't exist
      try {
        await Supabase.instance.client.storage.createBucket(
          'profile-images',
          BucketOptions(
            public: true,
            allowedMimeTypes: [
              'image/jpeg',
              'image/png',
              'image/gif',
              'image/webp',
            ],
            fileSizeLimit: '5242880', // 5MB
          ),
        );
      } catch (createError) {
        // Bucket might already exist, that's okay
        print('Bucket creation result: $createError');
      }

      // Try to upload the image
      try {
        final response = await Supabase.instance.client.storage
            .from('profile-images')
            .uploadBinary(
              fileName,
              fileBytes,
              fileOptions: FileOptions(
                upsert: true, // Allow overwrite
              ),
            );

        if (response.isNotEmpty) {
          final imageUrl = Supabase.instance.client.storage
              .from('profile-images')
              .getPublicUrl(fileName);

          return imageUrl;
        } else {
          throw Exception('Resim yüklenemedi');
        }
      } catch (uploadError) {
        // If upload fails, try with a different approach
        if (uploadError.toString().contains('permission denied') ||
            uploadError.toString().contains('403') ||
            uploadError.toString().contains('RLS') ||
            uploadError.toString().contains('Bucket not found') ||
            uploadError.toString().contains('404')) {
          throw Exception(
            'Storage bucket "profile-images" bulunamadı أو لا توجد صلاحيات. يرجى تشغيل SQL code في Supabase Dashboard:\n\n'
            '1. اذهب إلى Supabase Dashboard\n'
            '2. اختر SQL Editor\n'
            '3. شغل الكود من ملف setup_storage_bucket.sql\n\n'
            'Error: ${uploadError.toString()}',
          );
        }
        throw uploadError;
      }
    } catch (e) {
      if (e.toString().contains('file too large') ||
          e.toString().contains('413')) {
        throw Exception('الملف كبير جداً. يرجى اختيار صورة أصغر.');
      } else {
        throw Exception('خطأ في رفع الصورة: ${e.toString()}');
      }
    }
  }
}
