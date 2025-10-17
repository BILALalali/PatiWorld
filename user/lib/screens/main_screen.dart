import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'lost_pets_screen.dart';
import 'adoption_screen.dart';
import 'vaccination_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LostPetsScreen(),
    const AdoptionScreen(),
    const VaccinationScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'الرئيسية',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: 'مفقودات',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'تبني',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.medical_services),
      label: 'لقاحات',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'حسابي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: _bottomNavItems,
      ),
    );
  }
}
