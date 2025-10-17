import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const PatiWorldApp());
}

class PatiWorldApp extends StatelessWidget {
  const PatiWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PatiWorld',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // لون أخضر للحيوانات
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const MainScreen(),
    );
  }
}
