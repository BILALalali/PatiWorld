import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../constants/app_constants.dart';
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
    // بيانات تجريبية للحيوانات
    setState(() {
      pets = [
        Pet(
          id: '1',
          name: 'Kedi',
          type: 'Kedi',
          imageUrl:
              'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
          description: 'Kediler dünyada en popüler evcil hayvanlardan biridir',
          features: ['Sevimli', 'Temiz', 'Bağımsız'],
          foods: ['Balık', 'Et', 'Kuru mama'],
          diseases: [
            'İdrar yolu enfeksiyonu',
            'Böbrek hastalıkları',
            'Diyabet',
          ],
          careInstructions: 'Düzenli kum temizliği ve aşılar gerektirir',
          createdAt: DateTime.now(),
        ),
        Pet(
          id: '2',
          name: 'Köpek',
          type: 'Köpek',
          imageUrl:
              'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
          description:
              'Köpekler insanın en iyi dostu ve en sadık hayvanlarıdır',
          features: ['Sadık', 'Zeki', 'Aktif'],
          foods: ['Et', 'Kuru mama', 'Sebzeler'],
          diseases: ['Kuduz', 'Eklem iltihabı', 'Kalp hastalıkları'],
          careInstructions: 'Günlük egzersiz ve düzenli eğitim gerektirir',
          createdAt: DateTime.now(),
        ),
        Pet(
          id: '3',
          name: 'Kuş',
          type: 'Kuş',
          imageUrl:
              'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=400',
          description: 'Kuşlar eve neşe ve canlılık getirir',
          features: ['Renkli', 'Aktif', 'Sosyal'],
          foods: ['Tohumlar', 'Meyveler', 'Sebzeler'],
          diseases: [
            'Solunum yolu hastalıkları',
            'Enfeksiyonlar',
            'Tüy problemleri',
          ],
          careInstructions:
              'Geniş ve temiz kafes ile günlük etkileşim gerektirir',
          createdAt: DateTime.now(),
        ),
      ];
      isLoading = false;
    });
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.mediumPadding,
                      ),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: AppConstants.mediumPadding,
                              mainAxisSpacing: AppConstants.mediumPadding,
                            ),
                        itemCount: pets.length,
                        itemBuilder: (context, index) {
                          return _buildPetCard(pets[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        pet.type,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      Text(
                        pet.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      // Features
                      Wrap(
                        spacing: 4,
                        children: pet.features.take(3).map((feature) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 10,
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
