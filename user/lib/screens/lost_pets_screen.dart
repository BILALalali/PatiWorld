import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/lost_pet.dart';
import '../constants/app_constants.dart';
import '../services/lost_pet_service.dart';
import 'add_lost_pet_screen.dart';
import '../l10n/app_localizations.dart';

class LostPetsScreen extends StatefulWidget {
  const LostPetsScreen({super.key});

  @override
  State<LostPetsScreen> createState() => _LostPetsScreenState();
}

class _LostPetsScreenState extends State<LostPetsScreen> {
  List<LostPet> lostPets = [];
  List<LostPet> filteredLostPets = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedType = 'All';
  String selectedCity = 'All';

  @override
  void initState() {
    super.initState();
    _loadLostPets();
  }

  Future<void> _loadLostPets() async {
    try {
      print('Loading lost pets...');
      final pets = await LostPetService.getAllLostPets();
      print('Loaded ${pets.length} lost pets');
      for (var pet in pets) {
        print('Pet: ${pet.name} - ${pet.type} - ${pet.city}');
      }
      setState(() {
        lostPets = pets;
        _applyFilters();
        isLoading = false;
      });
      print('Lost pets loaded successfully');
    } catch (e) {
      print('Error loading lost pets: $e');
      // Error loading lost pets
      setState(() {
        lostPets = [];
        isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorLoadingData}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    print('Applying filters...');
    print('Total lost pets: ${lostPets.length}');
    print('Search query: "$searchQuery"');
    print('Selected type: "$selectedType"');
    print('Selected city: "$selectedCity"');

    setState(() {
      filteredLostPets = lostPets.where((pet) {
        // Search filter
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          if (!pet.name.toLowerCase().contains(query) &&
              !pet.description.toLowerCase().contains(query) &&
              !pet.type.toLowerCase().contains(query) &&
              !pet.city.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Type filter
        if (selectedType != 'All' && pet.type != selectedType) {
          return false;
        }

        // City filter
        if (selectedCity != 'All' && pet.city != selectedCity) {
          return false;
        }

        return true;
      }).toList();
    });

    print('Filtered lost pets: ${filteredLostPets.length}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    print(
      'Building LostPetsScreen - isLoading: $isLoading, lostPets: ${lostPets.length}, filteredLostPets: ${filteredLostPets.length}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lostPetListings),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (searchQuery.isNotEmpty ||
              selectedType != 'All' ||
              selectedCity != 'All')
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  searchQuery = '';
                  selectedType = 'All';
                  selectedCity = 'All';
                });
                _applyFilters();
              },
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: (selectedType != 'All' || selectedCity != 'All')
                  ? Colors.yellow
                  : Colors.white,
            ),
            onPressed: _showFilterDialog,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadLostPets),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredLostPets.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                if (searchQuery.isNotEmpty ||
                    selectedType != 'All' ||
                    selectedCity != 'All')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      '${filteredLostPets.length} sonuç bulundu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(child: _buildLostPetsList()),
              ],
            ),
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
    final l10n = AppLocalizations.of(context)!;

    print(
      'Building empty state - lostPets: ${lostPets.length}, filteredLostPets: ${filteredLostPets.length}',
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 100, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            l10n.noLostPetListings,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            l10n.addFirstLostPetListing,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLostPetsList() {
    print(
      'Building lost pets list - filteredLostPets: ${filteredLostPets.length}',
    );

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
        itemCount: filteredLostPets.length,
        itemBuilder: (context, index) {
          return _buildLostPetCard(filteredLostPets[index]);
        },
      ),
    );
  }

  Widget _buildLostPetCard(LostPet lostPet) {
    final l10n = AppLocalizations.of(context)!;

    print('Building lost pet card for: ${lostPet.name}');

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
                lostPet.imageUrl ??
                    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
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
                // Name and Status
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
                        l10n.lost,
                        style: const TextStyle(
                          color: Colors.red,
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

                // Pet Details
                Row(
                  children: [
                    if (lostPet.ageMonths != null)
                      _buildInfoChip(
                        Icons.cake,
                        lostPet.ageDisplay,
                        Colors.orange,
                      ),
                    if (lostPet.ageMonths != null) const SizedBox(width: 8),
                    if (lostPet.gender != null)
                      _buildInfoChip(
                        Icons.person,
                        lostPet.gender!,
                        Colors.purple,
                      ),
                    if (lostPet.gender != null) const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.location_on,
                      lostPet.city,
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.smallPadding),

                // Lost Date and Days Since
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.calendar_today,
                      lostPet.formattedLostDate,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.access_time,
                      l10n.daysAgo(lostPet.daysSinceLost),
                      Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Health Status
                if (lostPet.isVaccinated || lostPet.isNeutered)
                  Row(
                    children: [
                      if (lostPet.isVaccinated)
                        _buildStatusChip(
                          l10n.vaccinated,
                          lostPet.isVaccinated,
                          Colors.green,
                        ),
                      if (lostPet.isVaccinated) const SizedBox(width: 8),
                      if (lostPet.isNeutered)
                        _buildStatusChip(
                          l10n.neutered,
                          lostPet.isNeutered,
                          Colors.blue,
                        ),
                    ],
                  ),

                if (lostPet.isVaccinated || lostPet.isNeutered)
                  const SizedBox(height: AppConstants.mediumPadding),

                // Contact Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(lostPet.contactNumber),
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(l10n.call),
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
                        label: Text(l10n.whatsapp),
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
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.whatsappAppCannotBeOpened);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showErrorSnackBar('${l10n.whatsappCannotBeOpened}: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showPhoneNumberDialog(String phoneNumber) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.phoneNumber),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l10n.phoneNumber}:',
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
              Text(
                l10n.copyNumberAndCallManually,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Try to copy to clipboard
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.numberCopiedToClipboard),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(l10n.copyNumber),
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.search),
        content: TextField(
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          controller: TextEditingController(text: searchQuery),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = '';
              });
              _applyFilters();
              Navigator.pop(context);
            },
            child: Text(l10n.clear),
          ),
          TextButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: Text(l10n.search),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type Filter
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                labelText: l10n.petType,
                border: const OutlineInputBorder(),
              ),
              items: ['All', ...AppConstants.petTypes].map((type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            // City Filter
            DropdownButtonFormField<String>(
              value: selectedCity,
              decoration: InputDecoration(
                labelText: l10n.city,
                border: const OutlineInputBorder(),
              ),
              items: ['All', ...AppConstants.cities].map((city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedType = 'All';
                selectedCity = 'All';
              });
              _applyFilters();
              Navigator.pop(context);
            },
            child: Text(l10n.reset),
          ),
          TextButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: Text(l10n.apply),
          ),
        ],
      ),
    );
  }
}
