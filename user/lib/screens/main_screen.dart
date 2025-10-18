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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 85,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, 1, Icons.search, 'Kayıp', false),
          _buildNavItem(context, 2, Icons.favorite, 'Sahiplendir', false),
          _buildNavItem(context, 0, Icons.home, 'Ana Sayfa', true),
          _buildNavItem(context, 3, Icons.medical_services, 'Aşılar', false),
          _buildNavItem(context, 4, Icons.person, 'Profilim', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    bool isHome,
  ) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: isSelected && isHome ? 70 : 50,
        height: isSelected && isHome ? 70 : 50,
        decoration: BoxDecoration(
          color: isSelected && isHome
              ? const Color(0xFF4CAF50)
              : isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSelected && isHome ? 28 : 22,
              color: isSelected
                  ? isHome
                        ? Colors.white
                        : primaryColor
                  : Colors.grey.shade500,
            ),
            if (isHome) const SizedBox(height: 2),
            if (isHome)
              Text(
                label,
                style: TextStyle(
                  fontSize: isSelected ? 9 : 8,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
