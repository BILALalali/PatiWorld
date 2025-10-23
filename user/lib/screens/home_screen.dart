import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../constants/app_constants.dart';
import '../services/pet_service.dart';
import 'pet_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> pets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      setState(() {
        isLoading = true;
      });

      final petsData = await PetService.getAllPets();

      setState(() {
        pets = petsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veri yükleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PatiWorld',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(AppConstants.mediumPadding),
                    child: Column(
                      children: [
                        Text(
                          'Evcil Hayvan Dünyasına Hoş Geldiniz',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'Evcil hayvanlarınızın bakımı hakkında faydalı bilgiler keşfedin',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Pets Grid
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadPets,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.mediumPadding,
                        ),
                        child: pets.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Şu anda mevcut hayvan yok',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      childAspectRatio:
                                          _calculateChildAspectRatio(context),
                                      crossAxisSpacing:
                                          AppConstants.mediumPadding,
                                      mainAxisSpacing:
                                          AppConstants.mediumPadding,
                                    ),
                                itemCount: pets.length,
                                itemBuilder: (context, index) {
                                  return _buildPetCard(pets[index]);
                                },
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  double _calculateChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate available height for the grid
    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = 120.0; // Approximate header height
    final bottomNavHeight = 85.0; // Approximate bottom nav height
    final padding = AppConstants.mediumPadding * 2;

    final availableHeight =
        screenHeight -
        appBarHeight -
        statusBarHeight -
        headerHeight -
        bottomNavHeight -
        padding;

    // Calculate aspect ratio based on available space
    final aspectRatio =
        screenWidth / (availableHeight / 2); // 2 items per screen

    // Ensure minimum and maximum aspect ratios
    return aspectRatio.clamp(2.0, 3.5);
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PetDetailScreen(pet: pet)),
        );
      },
      child: Card(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              // Pet Image
              Container(
                width: 120,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.mediumRadius),
                    bottomLeft: Radius.circular(AppConstants.mediumRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.mediumRadius),
                    bottomLeft: Radius.circular(AppConstants.mediumRadius),
                  ),
                  child: Image.network(
                    pet.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.pets,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
              // Pet Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pet Name
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Pet Type
                      Text(
                        pet.type,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Description
                      Expanded(
                        child: Text(
                          pet.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Features
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: pet.features.take(3).map((feature) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 9,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow Icon
              Padding(
                padding: const EdgeInsets.only(
                  right: AppConstants.smallPadding,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
