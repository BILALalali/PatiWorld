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
          name: 'قطة',
          type: 'قطة',
          imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
          description: 'القطط من أكثر الحيوانات الأليفة شعبية في العالم',
          features: ['ودودة', 'نظيفة', 'مستقلة'],
          foods: ['السمك', 'اللحم', 'الطعام الجاف'],
          diseases: ['التهاب المسالك البولية', 'أمراض الكلى', 'السكري'],
          careInstructions: 'تتطلب تنظيف دوري للصندوق الرمل وتطعيمات منتظمة',
          createdAt: DateTime.now(),
        ),
        Pet(
          id: '2',
          name: 'كلب',
          type: 'كلب',
          imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
          description: 'الكلاب أفضل أصدقاء الإنسان وأكثر الحيوانات وفاءً',
          features: ['مخلص', 'ذكي', 'نشط'],
          foods: ['اللحم', 'الطعام الجاف', 'الخضروات'],
          diseases: ['داء الكلب', 'التهاب المفاصل', 'أمراض القلب'],
          careInstructions: 'تحتاج إلى تمرين يومي وتدريب منتظم',
          createdAt: DateTime.now(),
        ),
        Pet(
          id: '3',
          name: 'طائر',
          type: 'طائر',
          imageUrl: 'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=400',
          description: 'الطيور تجلب البهجة والحيوية للمنزل',
          features: ['ملون', 'نشط', 'اجتماعي'],
          foods: ['البذور', 'الفواكه', 'الخضروات'],
          diseases: ['أمراض الجهاز التنفسي', 'الالتهابات', 'مشاكل الريش'],
          careInstructions: 'تحتاج إلى قفص واسع ونظيف وتفاعل يومي',
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
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
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                          'مرحباً بك في عالم الحيوانات الأليفة',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'اكتشف معلومات مفيدة عن رعاية حيواناتك الأليفة',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
          MaterialPageRoute(
            builder: (context) => PetDetailScreen(pet: pet),
          ),
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
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
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
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
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
                padding: const EdgeInsets.only(right: AppConstants.smallPadding),
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