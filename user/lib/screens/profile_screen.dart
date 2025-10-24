import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/user_stats_service.dart';
import '../services/debug_service.dart';
import '../models/user.dart' as app_user;
import 'login_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

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
  bool _isLoading = false; // Loading state for image upload
  bool _isLoadingStats = false; // Loading state for statistics
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  app_user.User? _currentUser; // Current user data
  int _imageUpdateTimestamp = 0; // Track image updates to force refresh

  // Statistics data
  Map<String, int> _userStats = {
    'adoption_pets_count': 0,
    'lost_pets_count': 0,
    'vaccinations_count': 0,
    'days_in_app': 0,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _loadUserStats();
      // Debug function - call it after a short delay to ensure auth is ready
      Future.delayed(const Duration(seconds: 2), () {
        DebugService.debugUserStats();
      });
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
        if (mounted) {
          setState(() {
            _currentUser = user;
            _nameController.text = user.fullName ?? '';
            _emailController.text = user.email;
            _phoneController.text = user.phoneNumber ?? '';
            _imageUpdateTimestamp =
                DateTime.now().millisecondsSinceEpoch; // Force image refresh
          });
        }
      } else {
        // Fallback to basic user data if database fetch fails
        final user = AuthService.currentUser;
        if (user != null && mounted) {
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
      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.fullName ?? '';
          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber ?? '';
        });
      }
    }
  }

  Future<void> _loadUserStats() async {
    try {
      setState(() {
        _isLoadingStats = true;
      });

      final currentUser = AuthService.currentUser;
      print('Current user: $currentUser');
      print('Current user ID: ${currentUser?.id}');

      if (currentUser != null) {
        print('Loading stats for user ID: ${currentUser.id}');

        // Get the correct user ID (handles cases where auth user ID differs from database user ID)
        final correctUserId = await UserStatsService.getCorrectUserId();
        Map<String, int> stats;

        if (correctUserId != null) {
          print('Using correct user ID: $correctUserId');
          stats = await UserStatsService.getUserStats(correctUserId);
          print('Stats loaded: $stats');
        } else {
          print('Could not determine correct user ID');
          // Fallback to current user ID
          stats = await UserStatsService.getUserStats(currentUser.id);
          print('Stats loaded with fallback: $stats');
        }

        if (mounted) {
          setState(() {
            _userStats = stats;
            _isLoadingStats = false;
          });
        }
      } else {
        print('No current user found');
        if (mounted) {
          setState(() {
            _isLoadingStats = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Stack(
          children: [
            // Decorative background circles
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
            // Main profile image container
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                          '${_currentUser!.profileImageUrl!}?t=$_imageUpdateTimestamp',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.pets,
                                size: 50,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.6),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 50,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                ),
              ),
            ),
            // Edit button with pet-themed icon
            if (_isEditing)
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: _isLoading ? null : _changeProfileImage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.6)
                          : Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        // Name without emoji
        Text(
          _nameController.text.isNotEmpty ? _nameController.text : l10n.profile,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            'PatiWorld ${l10n.profile}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with pet theme
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.pets_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hesap Bilgileri',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kişisel bilgilerinizi düzenleyin',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content with better spacing
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Full Name
                _buildPetThemedInfoField(
                  label: 'Ad Soyad',
                  controller: _nameController,
                  icon: Icons.person_rounded,
                  emoji: '👤',
                  enabled: _isEditing,
                  validator: (value) {
                    if (_isEditing && (value == null || value.isEmpty)) {
                      return 'Lütfen ad soyad giriniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email
                _buildPetThemedInfoField(
                  label: 'E-posta',
                  controller: _emailController,
                  icon: Icons.email_rounded,
                  emoji: '📧',
                  enabled: false, // Email cannot be changed
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                // Phone Number
                _buildPetThemedInfoField(
                  label: 'Telefon Numarası',
                  controller: _phoneController,
                  icon: Icons.phone_rounded,
                  emoji: '📱',
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
        ],
      ),
    );
  }

  Widget _buildPetThemedInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String emoji,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Colors.grey[400]!,
          width: 2,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            validator: validator,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: enabled ? Colors.black87 : Colors.grey[600],
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: enabled
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[500],
                  size: 18,
                ),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with pet theme
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.analytics_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İstatistikleriniz',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aktivite özetiniz',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('📊', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),

          // Content with pet-themed stats
          Padding(
            padding: const EdgeInsets.all(24),
            child: _isLoadingStats
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildPetThemedStatCard(
                              'Kayıp İlanları',
                              _userStats['lost_pets_count'].toString(),
                              Icons.search_rounded,
                              '🔍',
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPetThemedStatCard(
                              'Sahiplendirme İlanları',
                              _userStats['adoption_pets_count'].toString(),
                              Icons.favorite_rounded,
                              '❤️',
                              Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPetThemedStatCard(
                              'Kayıtlı Aşılar',
                              _userStats['vaccinations_count'].toString(),
                              Icons.medical_services_rounded,
                              '💉',
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPetThemedStatCard(
                              'Uygulamada Gün',
                              _userStats['days_in_app'].toString(),
                              Icons.calendar_today_rounded,
                              '📅',
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetThemedStatCard(
    String title,
    String value,
    IconData icon,
    String emoji,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(emoji, style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
            onPressed: _isLoading
                ? null
                : (_isEditing ? _saveProfile : _toggleEdit),
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(_isEditing ? Icons.save : Icons.edit),
            label: Text(
              _isLoading
                  ? 'Yükleniyor...'
                  : (_isEditing ? 'Değişiklikleri Kaydet' : 'Profili Düzenle'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLoading
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.primary,
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

    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        String? imageUrl;

        // Upload image if selected
        if (_selectedImage != null) {
          // Delete old profile image if exists
          if (_currentUser?.profileImageUrl != null) {
            await _deleteOldProfileImage(_currentUser!.profileImageUrl!);
          }

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
          _isLoading = false;
        });

        _showSuccessSnackBar('Değişiklikler başarıyla kaydedildi');
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Kullanıcı bilgileri bulunamadı');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
    setState(() {
      _isLoading = true;
    });

    try {
      setState(() {
        _selectedImage = null;
      });

      final user = AuthService.currentUser;
      if (user != null) {
        // Delete old profile image from storage if exists
        if (_currentUser?.profileImageUrl != null) {
          await _deleteOldProfileImage(_currentUser!.profileImageUrl!);
        }

        await AuthService.updateUserProfile(
          userId: user.id,
          clearProfileImage: true,
        );

        // Reload user data to get updated profile
        await _loadUserData();

        setState(() {
          _isLoading = false;
        });

        _showSuccessSnackBar('Profil resmi kaldırıldı');
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Resim kaldırılırken hata oluştu: ${e.toString()}');
    }
  }

  Future<String> _uploadProfileImage(String userId) async {
    try {
      final fileBytes = await _selectedImage!.readAsBytes();
      final fileName = 'profile_$userId.jpg';

      // Upload the image to Supabase Storage
      final response = await Supabase.instance.client.storage
          .from(AppConstants.profileImagesBucket)
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: FileOptions(
              upsert: true, // Allow overwrite
              contentType: 'image/jpeg',
            ),
          );

      if (response.isNotEmpty) {
        // Get the public URL for the uploaded image
        final imageUrl = Supabase.instance.client.storage
            .from(AppConstants.profileImagesBucket)
            .getPublicUrl(fileName);

        return imageUrl;
      } else {
        throw Exception('Resim yüklenemedi');
      }
    } catch (e) {
      if (e.toString().contains('permission denied') ||
          e.toString().contains('403') ||
          e.toString().contains('RLS') ||
          e.toString().contains('Bucket not found') ||
          e.toString().contains('404')) {
        throw Exception(
          'Storage bucket "profile-images" bulunamadı أو لا توجد صلاحيات. يرجى تشغيل SQL code في Supabase Dashboard:\n\n'
          '1. اذهب إلى Supabase Dashboard\n'
          '2. اختر SQL Editor\n'
          '3. شغل الكود من ملف setup_storage_bucket.sql\n\n'
          'Error: ${e.toString()}',
        );
      } else if (e.toString().contains('file too large') ||
          e.toString().contains('413')) {
        throw Exception('الملف كبير جداً. يرجى اختيار صورة أصغر.');
      } else {
        throw Exception('خطأ في رفع الصورة: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteOldProfileImage(String imageUrl) async {
    try {
      // Extract file name from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final fileName = pathSegments.last;

        // Delete the file from storage
        await Supabase.instance.client.storage
            .from(AppConstants.profileImagesBucket)
            .remove([fileName]);
      }
    } catch (e) {
      // Log error but don't throw - this is not critical
      print('Error deleting old profile image: $e');
    }
  }
}
