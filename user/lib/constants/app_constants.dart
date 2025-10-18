class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://xtysfxxrkwzemkasrxfl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0eXNmeHhya3d6ZW1rYXNyeGZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2Mjk1MTMsImV4cCI6MjA3NjIwNTUxM30.JpmTTuwIqWIo5gWIjSFpU04qrOA2d2gMY-MUMF3DuKQ';

  // Database Table Names
  static const String petsTable = 'pets';
  static const String lostPetsTable = 'lost_pets';
  static const String adoptionPetsTable = 'adoption_pets';
  static const String vaccinationsTable = 'vaccinations';
  static const String usersTable = 'users';

  // Storage Buckets
  static const String petImagesBucket = 'pet-images';
  static const String profileImagesBucket = 'profile-images';

  // App Colors
  static const int primaryColor = 0xFF2E7D32; // أخضر
  static const int secondaryColor = 0xFF4CAF50; // أخضر فاتح
  static const int accentColor = 0xFF81C784; // أخضر فاتح جداً
  static const int errorColor = 0xFFE57373; // أحمر فاتح
  static const int warningColor = 0xFFFFB74D; // برتقالي
  static const int infoColor = 0xFF64B5F6; // أزرق فاتح

  // Text Styles
  static const double titleFontSize = 24.0;
  static const double subtitleFontSize = 18.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;

  // Spacing
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Card Elevation
  static const double cardElevation = 4.0;
  static const double appBarElevation = 0.0;

  // Animation Duration
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;

  // Image Sizes
  static const double profileImageSize = 80.0;
  static const double petImageSize = 120.0;
  static const double cardImageHeight = 200.0;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxDescriptionLength = 500;
  static const int maxNameLength = 50;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Pet Types
  static const List<String> petTypes = [
    'Kedi',
    'Köpek',
    'Kuş',
    'Balık',
    'Tavşan',
    'Hamster',
    'Kaplumbağa',
    'Diğer',
  ];

  // Cities
  static const List<String> cities = [
    'İstanbul',
    'Ankara',
    'İzmir',
    'Bursa',
    'Antalya',
    'Adana',
    'Konya',
    'Gaziantep',
    'Şanlıurfa',
    'Kocaeli',
    'Mersin',
    'Diyarbakır',
    'Hatay',
    'Manisa',
    'Kayseri',
    'Samsun',
    'Balıkesir',
    'Kahramanmaraş',
    'Van',
    'Denizli',
    'Diğer',
  ];

  // Gender Options
  static const List<String> genderOptions = ['Erkek', 'Dişi'];

  // Country Codes
  static const List<Map<String, String>> countryCodes = [
    {'code': '+90', 'name': 'Türkiye', 'flag': '🇹🇷'},
    {'code': '+1', 'name': 'USA/Canada', 'flag': '🇺🇸'},
    {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '+49', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': '+33', 'name': 'France', 'flag': '🇫🇷'},
    {'code': '+39', 'name': 'Italy', 'flag': '🇮🇹'},
    {'code': '+34', 'name': 'Spain', 'flag': '🇪🇸'},
    {'code': '+31', 'name': 'Netherlands', 'flag': '🇳🇱'},
    {'code': '+32', 'name': 'Belgium', 'flag': '🇧🇪'},
    {'code': '+41', 'name': 'Switzerland', 'flag': '🇨🇭'},
    {'code': '+43', 'name': 'Austria', 'flag': '🇦🇹'},
    {'code': '+45', 'name': 'Denmark', 'flag': '🇩🇰'},
    {'code': '+46', 'name': 'Sweden', 'flag': '🇸🇪'},
    {'code': '+47', 'name': 'Norway', 'flag': '🇳🇴'},
    {'code': '+358', 'name': 'Finland', 'flag': '🇫🇮'},
    {'code': '+7', 'name': 'Russia', 'flag': '🇷🇺'},
    {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
    {'code': '+81', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': '+82', 'name': 'South Korea', 'flag': '🇰🇷'},
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+92', 'name': 'Pakistan', 'flag': '🇵🇰'},
    {'code': '+98', 'name': 'Iran', 'flag': '🇮🇷'},
    {'code': '+966', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
    {'code': '+965', 'name': 'Kuwait', 'flag': '🇰🇼'},
    {'code': '+974', 'name': 'Qatar', 'flag': '🇶🇦'},
    {'code': '+973', 'name': 'Bahrain', 'flag': '🇧🇭'},
    {'code': '+968', 'name': 'Oman', 'flag': '🇴🇲'},
    {'code': '+962', 'name': 'Jordan', 'flag': '🇯🇴'},
    {'code': '+961', 'name': 'Lebanon', 'flag': '🇱🇧'},
    {'code': '+963', 'name': 'Syria', 'flag': '🇸🇾'},
    {'code': '+964', 'name': 'Iraq', 'flag': '🇮🇶'},
    {'code': '+20', 'name': 'Egypt', 'flag': '🇪🇬'},
    {'code': '+212', 'name': 'Morocco', 'flag': '🇲🇦'},
    {'code': '+213', 'name': 'Algeria', 'flag': '🇩🇿'},
    {'code': '+216', 'name': 'Tunisia', 'flag': '🇹🇳'},
    {'code': '+218', 'name': 'Libya', 'flag': '🇱🇾'},
    {'code': '+249', 'name': 'Sudan', 'flag': '🇸🇩'},
    {'code': '+27', 'name': 'South Africa', 'flag': '🇿🇦'},
    {'code': '+234', 'name': 'Nigeria', 'flag': '🇳🇬'},
    {'code': '+254', 'name': 'Kenya', 'flag': '🇰🇪'},
    {'code': '+251', 'name': 'Ethiopia', 'flag': '🇪🇹'},
    {'code': '+20', 'name': 'Egypt', 'flag': '🇪🇬'},
  ];

  // Vaccine Types
  static const List<String> vaccineTypes = [
    'لقاح أساسي',
    'لقاح سنوي',
    'لقاح ضد داء الكلب',
    'لقاح ضد السعال',
    'لقاح ضد الإنفلونزا',
    'أخرى',
  ];
}
