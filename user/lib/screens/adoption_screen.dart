import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
    try {
      final response = await Supabase.instance.client
          .from(AppConstants.adoptionPetsTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      setState(() {
        adoptionPets = (response as List)
            .map((json) => AdoptionPet.fromJson(json))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler yüklenirken hata oluştu: ${e.toString()}'),
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
            'Şu anda sahiplendirme ilanı bulunmuyor',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'İlk sahiplendirme ilanını sen ekle',
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
                        'Sahiplendirme',
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
                      '${adoptionPet.age} Ay',
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
                      'Aşılı',
                      adoptionPet.isVaccinated,
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      'Kısırlaştırılmış',
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
                        label: const Text('Ara'),
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
                        label: const Text('WhatsApp'),
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
    try {
      // Remove any spaces or special characters for phone call
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Create the phone URL
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
      
      // Try to launch the phone app
      bool launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        // If phone app is not available, show the number for manual dialing
        _showPhoneNumberDialog(cleanNumber);
      }
    } catch (e) {
      // If there's an error, show the number for manual dialing
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      _showPhoneNumberDialog(cleanNumber);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Remove any spaces or special characters for WhatsApp
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create the WhatsApp URL
      final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');

      // Check if the device can launch the URL
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('WhatsApp uygulaması açılamadı');
      }
    } catch (e) {
      _showErrorSnackBar('WhatsApp açılamadı: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showPhoneNumberDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رقم الهاتف'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'رقم الهاتف:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(
                phoneNumber,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'يمكنك نسخ الرقم والاتصال يدوياً',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Try to copy to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم نسخ الرقم إلى الحافظة'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('نسخ الرقم'),
            ),
          ],
        );
      },
    );
  }
}
