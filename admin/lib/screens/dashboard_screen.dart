import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/admin_auth_service.dart';
import '../services/admin_service.dart';
import 'lost_pets_screen.dart';
import 'adoption_pets_screen.dart';
import 'users_screen.dart';
import 'vaccinations_screen.dart';
import 'add_admin_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await AdminService.getStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'İstatistikler yüklenirken hata oluştu: ${e.toString()}',
            ),
            backgroundColor: Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminAuthService.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Çıkış yapılırken hata oluştu: ${e.toString()}'),
              backgroundColor: Color(AppConstants.errorColor),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      const LostPetsScreen(),
      const AdoptionPetsScreen(),
      const UsersScreen(),
      const VaccinationsScreen(),
      const AddAdminScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yönetim Paneli'),
        backgroundColor: Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 0) {
                  _loadStatistics();
                }
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Kontrol Paneli'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pets),
                selectedIcon: Icon(Icons.pets),
                label: Text('Kayıp Hayvanlar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite),
                selectedIcon: Icon(Icons.favorite),
                label: Text('Sahiplendirme'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people),
                label: Text('Kullanıcılar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.medical_services),
                selectedIcon: Icon(Icons.medical_services),
                label: Text('Aşılar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_add),
                selectedIcon: Icon(Icons.person_add),
                label: Text('Yönetici Ekle'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = _statistics ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İstatistikler',
            style: TextStyle(
              fontSize: AppConstants.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppConstants.mediumPadding,
            mainAxisSpacing: AppConstants.mediumPadding,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Kayıp Hayvan İlanları',
                '${stats['totalLostPets'] ?? 0}',
                Icons.pets,
                AppConstants.errorColor,
              ),
              _buildStatCard(
                'Sahiplendirme İlanları',
                '${stats['totalAdoptionPets'] ?? 0}',
                Icons.favorite,
                AppConstants.successColor,
              ),
              _buildStatCard(
                'Kullanıcılar',
                '${stats['totalUsers'] ?? 0}',
                Icons.people,
                AppConstants.infoColor,
              ),
              _buildStatCard(
                'Aşı Kayıtları',
                '${stats['totalVaccinations'] ?? 0}',
                Icons.medical_services,
                AppConstants.warningColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, int color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Color(color)),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(color),
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.bodyFontSize,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
