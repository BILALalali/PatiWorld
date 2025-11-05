import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Helper class for password hashing
class PasswordHelper {
  /// Hash password using SHA-256
  /// Note: In production, use bcrypt or Argon2 instead
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate SQL insert statement for default admin
  /// Run this once to get the hash, then use it in SQL
  static String generateDefaultAdminSQL() {
    final password = 'Sdra.2003';
    final hash = hashPassword(password);

    return '''
-- Insert default admin
INSERT INTO admins (email, full_name, password_hash, is_active)
VALUES (
  'pati2003pati2003@gmail.com',
  'Super Admin',
  '$hash',
  TRUE
)
ON CONFLICT (email) DO NOTHING;
''';
  }
}
