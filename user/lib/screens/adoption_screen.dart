import 'package:flutter/material.dart';
import '../models/adoption_pet.dart';
import '../constants/app_constants.dart';
import 'add_adoption_pet_screen.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  List<AdoptionPet> adoptionPets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdoptionPets();
  }

  Future<void> _loadAdoptionPets() async {
    // بيانات تجريبية لإعلانات التبني
    setState(() {
      adoptionPets = [
        AdoptionPet(
          id: '1',
          name: 'Küçük Kedi',
          type: 'Kedi',
          imageUrl:
              'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
          description:
              'Sıcak bir yuva arayan güzel küçük kedi, çok sevimli ve aileler için uygun',
          city: 'İzmir',
          contactNumber: '0501234567',
          whatsappNumber: '0501234567',
          age: 3, // 3 ay
          gender: 'Dişi',
          isVaccinated: true,
          isNeutered: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          userId: 'user1',
        ),
        AdoptionPet(
          id: '2',
          name: 'Labrador Köpek',
          type: 'Köpek',
          imageUrl:
              'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
          description:
              'Sevimli ve zeki Labrador köpek, çocuklu aileler için uygun',
          city: 'Ankara',
          contactNumber: '0507654321',
          whatsappNumber: '0507654321',
          age: 12, // 12 ay
          gender: 'Erkek',
          isVaccinated: true,
          isNeutered: true,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          userId: 'user2',
        ),
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahiplendirme İlanları'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : adoptionPets.isEmpty
          ? _buildEmptyState()
          : _buildAdoptionPetsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAdoptionPetScreen(),
            ),
          ).then((_) => _loadAdoptionPets());
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 100, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            'لا توجد إعلانات تبني حالياً',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'كن أول من يضيف إعلان للتبني',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionPetsList() {
    return Container(
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
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        itemCount: adoptionPets.length,
        itemBuilder: (context, index) {
          return _buildAdoptionPetCard(adoptionPets[index]);
        },
      ),
    );
  }

  Widget _buildAdoptionPetCard(AdoptionPet adoptionPet) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppConstants.mediumRadius),
              topRight: Radius.circular(AppConstants.mediumRadius),
            ),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.network(
                adoptionPet.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.pets, size: 50, color: Colors.grey),
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
          Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Type
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        adoptionPet.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'للتبني',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.smallPadding),

                // Description
                Text(
                  adoptionPet.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Pet Details
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.cake,
                      '${adoptionPet.age} شهر',
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.person,
                      adoptionPet.gender,
                      Colors.purple,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.location_on,
                      adoptionPet.city,
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Health Status
                Row(
                  children: [
                    _buildStatusChip(
                      'مطعم',
                      adoptionPet.isVaccinated,
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'معقم',
                      adoptionPet.isNeutered,
                      Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Contact Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _makePhoneCall(adoptionPet.contactNumber),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('اتصال'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _openWhatsApp(adoptionPet.whatsappNumber),
                        icon: const Icon(Icons.message, size: 18),
                        label: const Text('واتساب'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, bool status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status
            ? color.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status
              ? color.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status ? Icons.check : Icons.close,
            size: 14,
            color: status ? color : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: status ? color : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    _showInfoSnackBar('سيتم فتح تطبيق الهاتف للرقم: $phoneNumber');
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    _showInfoSnackBar('سيتم فتح تطبيق الواتساب للرقم: $phoneNumber');
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
}
