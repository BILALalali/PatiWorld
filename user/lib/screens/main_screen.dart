import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'lost_pets_screen.dart';
import 'adoption_screen.dart';
import 'vaccination_screen.dart';
import 'profile_screen.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context, l10n),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      height: 85,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(
          148,
          218,
          246,
          230,
        ), // Warmer, more comfortable for eyes
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06), // Even softer shadow
            blurRadius: 25,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), // Very soft shadow
            blurRadius: 15,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            1,
            Icons.pets,
            l10n.petLost,
            false,
          ), // Changed to pets icon for lost pets
          _buildNavItem(
            context,
            2,
            'assets/icons/heart_smile.svg',
            l10n.petAdoption,
            false,
          ), // Custom heart smile icon for adoption
          _buildNavItem(context, 0, Icons.home, l10n.home, true),
          _buildNavItem(
            context,
            3,
            'assets/icons/vaccine_calendar.svg',
            l10n.veterinaryServices,
            false,
          ),
          _buildNavItem(
            context,
            4,
            'assets/icons/profile_circle.svg',
            l10n.profile,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    dynamic icon, // Can be IconData or String (for SVG path)
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
              ? const Color(0xFF4CAF50) // Keep the green for home
              : isSelected
              ? primaryColor.withValues(alpha: 0.08) // Softer selection color
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon is String
                ? SvgPicture.asset(
                    icon,
                    width: isSelected && isHome ? 28 : 22,
                    height: isSelected && isHome ? 28 : 22,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? isHome
                                ? Colors.white
                                : primaryColor
                          : Colors.grey.shade600,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(
                    icon,
                    size: isSelected && isHome ? 28 : 22,
                    color: isSelected
                        ? isHome
                              ? Colors.white
                              : primaryColor
                        : Colors
                              .grey
                              .shade600, // Slightly darker for better visibility
                  ),
            if (isHome) const SizedBox(height: 2),
            if (isHome)
              Text(
                label,
                style: TextStyle(
                  fontSize: isSelected ? 9 : 8,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade600, // Better visibility
                ),
              ),
          ],
        ),
      ),
    );
  }
}
