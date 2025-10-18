import 'package:flutter/material.dart';
import '../models/lost_pet.dart';
import '../constants/app_constants.dart';
import 'add_lost_pet_screen.dart';

class LostPetsScreen extends StatefulWidget {
  const LostPetsScreen({super.key});

  @override
  State<LostPetsScreen> createState() => _LostPetsScreenState();
}

class _LostPetsScreenState extends State<LostPetsScreen> {
  List<LostPet> lostPets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLostPets();
  }

  Future<void> _loadLostPets() async {
    // بيانات تجريبية للإعلانات
    setState(() {
      lostPets = [
        LostPet(
          id: '1',
          name: 'Küçük Kedi',
          type: 'Kedi',
          imageUrl:
              'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
          description:
              'Nergis mahallesinde kayıp küçük kedi, beyaz renkli siyah lekeli',
          city: 'İstanbul',
          contactNumber: '0501234567',
          whatsappNumber: '0501234567',
          lostDate: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          userId: 'user1',
        ),
        LostPet(
          id: '2',
          name: 'Golden Köpek',
          type: 'Köpek',
          imageUrl:
              'https://images.unsplash.com/photo-1552053831-71594a27632d?w=400',
          description: 'Ulus mahallesinde kayıp Golden Retriever, çok sevimli',
          city: 'İstanbul',
          contactNumber: '0507654321',
          whatsappNumber: '0507654321',
          lostDate: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
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
        title: const Text('Kayıp Hayvan İlanları'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lostPets.isEmpty
          ? _buildEmptyState()
          : _buildLostPetsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLostPetScreen()),
          ).then((_) => _loadLostPets());
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
          Icon(Icons.search_off, size: 100, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            'Şu anda kayıp hayvan ilanı yok',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Kayıp hayvan ilanı ekleyen ilk kişi olun',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLostPetsList() {
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
        itemCount: lostPets.length,
        itemBuilder: (context, index) {
          return _buildLostPetCard(lostPets[index]);
        },
      ),
    );
  }

  Widget _buildLostPetCard(LostPet lostPet) {
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
                lostPet.imageUrl,
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
                        lostPet.name,
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
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'مفقود',
                        style: TextStyle(
                          color: Colors.red[700],
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
                  lostPet.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Location and Date
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      lostPet.city,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'منذ ${_getDaysAgo(lostPet.lostDate)} أيام',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Contact Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(lostPet.contactNumber),
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
                        onPressed: () => _openWhatsApp(lostPet.whatsappNumber),
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

  int _getDaysAgo(DateTime date) {
    return DateTime.now().difference(date).inDays;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // محاكاة عملية الاتصال
    _showInfoSnackBar('سيتم فتح تطبيق الهاتف للرقم: $phoneNumber');
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // محاكاة عملية فتح الواتساب
    _showInfoSnackBar('سيتم فتح تطبيق الواتساب للرقم: $phoneNumber');
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
}
