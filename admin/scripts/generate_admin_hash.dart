// Script to generate SHA-256 hash for default admin password
// Run with: dart run scripts/generate_admin_hash.dart

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main() {
  const password = 'Sdra.2003';
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  final hash = digest.toString();

  print('=' * 60);
  print('Password Hash Generator');
  print('=' * 60);
  print('');
  print('Password: $password');
  print('SHA-256 Hash: $hash');
  print('');
  print('SQL Statement:');
  print('-' * 60);
  print('''
INSERT INTO admins (email, full_name, password_hash, is_active)
VALUES (
  'pati2003pati2003@gmail.com',
  'Super Admin',
  '$hash',
  TRUE
)
ON CONFLICT (email) DO NOTHING;
''');
  print('=' * 60);
}
