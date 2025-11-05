class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://xtysfxxrkwzemkasrxfl.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0eXNmeHhya3d6ZW1rYXNyeGZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2Mjk1MTMsImV4cCI6MjA3NjIwNTUxM30.JpmTTuwIqWIo5gWIjSFpU04qrOA2d2gMY-MUMF3DuKQ';

  // Database Table Names
  static const String adminsTable = 'admins';
  static const String usersTable = 'users';
  static const String lostPetsTable = 'lost_pets';
  static const String adoptionPetsTable = 'adoption_pets';
  static const String vaccinationsTable = 'vaccinations';
  static const String userStatsTable = 'user_stats';

  // Default Admin Credentials
  static const String defaultAdminEmail = 'pati2003pati2003@gmail.com';
  static const String defaultAdminPassword = 'Sdra.2003';

  // App Colors (متوافقة مع تطبيق المستخدم)
  static const int primaryColor = 0xFF2E7D32; // Yeşil (أخضر)
  static const int secondaryColor = 0xFF4CAF50; // Açık yeşil (أخضر فاتح)
  static const int accentColor = 0xFF81C784; // Çok açık yeşil (أخضر فاتح جداً)
  static const int errorColor = 0xFFE57373; // Açık kırmızı (أحمر فاتح)
  static const int warningColor = 0xFFFFB74D; // Turuncu (برتقالي)
  static const int successColor = 0xFF81C784; // Green (أخضر)
  static const int infoColor = 0xFF64B5F6; // Açık mavi (أزرق فاتح)

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

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';
}
