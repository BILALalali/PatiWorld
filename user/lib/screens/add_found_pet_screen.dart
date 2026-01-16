import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../services/found_pet_service.dart';
import '../services/ai_matching_service.dart';
import '../models/lost_pet.dart';
import '../l10n/app_localizations.dart';

class AddFoundPetScreen extends StatefulWidget {
  const AddFoundPetScreen({super.key});

  @override
  State<AddFoundPetScreen> createState() => _AddFoundPetScreenState();
}

class _AddFoundPetScreenState extends State<AddFoundPetScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  String? _selectedType;
  String? _selectedBreed;
  String? _selectedCity;
  bool _isLoading = false;
  List<LostPet> _similarLostPets = [];
  bool _isLoadingSimilarPets = false;

  final ImagePicker _picker = ImagePicker();

  // Get breed list based on selected pet type
  List<String> get _availableBreeds {
    switch (_selectedType) {
      case 'Kedi':
        return AppConstants.catBreeds;
      case 'Köpek':
        return AppConstants.dogBreeds;
      case 'Kuş':
        return AppConstants.birdBreeds;
      default:
        return [];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    _checkAndLoadSimilarPets();
  }

  Future<void> _checkAndLoadSimilarPets() async {
    // Only search if all required fields are filled
    if (_selectedType != null &&
        _selectedBreed != null &&
        _selectedCity != null) {
      setState(() {
        _isLoadingSimilarPets = true;
      });

      try {
        print('🔍 Searching for similar lost pets...');
        print('   Type: $_selectedType');
        print('   Breed: $_selectedBreed');
        print('   City: $_selectedCity');
        print('   Has Image: ${_image != null}');
        
        // Use AI image matching if image is selected, otherwise use text-based matching
        final similarPets = await AIMatchingService.findSimilarLostPets(
          type: _selectedType!,
          breed: _selectedBreed!,
          city: _selectedCity!,
          imageUrl: null,
          imageFile: _image, // Pass image file for AI matching
          limit: 5,
        );

        print('✅ Found ${similarPets.length} similar pets');

        if (mounted) {
          setState(() {
            _similarLostPets = similarPets;
            _isLoadingSimilarPets = false;
          });
        }
      } catch (e, stackTrace) {
        print('❌ Error loading similar pets: $e');
        print('Stack trace: $stackTrace');
        if (mounted) {
          setState(() {
            _isLoadingSimilarPets = false;
          });
          // Show error message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: Benzer hayvanlar yüklenirken bir sorun oluştu. ${e.toString()}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      setState(() {
        _similarLostPets = [];
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        print('User not logged in');
        return null;
      }

      // Use the correct bucket name from AppConstants
      final String bucket = AppConstants.petImagesBucket; // 'pet-images'

      // Create unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = p.extension(image.path);
      final String fileName = 'found_pet_${user.id}_$timestamp$extension';

      // Upload image to Supabase Storage
      await supabase.storage
          .from(bucket)
          .upload(
            fileName,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final String publicUrl = supabase.storage
          .from(bucket)
          .getPublicUrl(fileName);

      print('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      // Print detailed error for debugging
      if (e.toString().contains('Bucket not found') ||
          e.toString().contains('404') ||
          e.toString().contains('permission denied') ||
          e.toString().contains('403') ||
          e.toString().contains('RLS')) {
        print(
          'Storage bucket issue: Check if bucket "${AppConstants.petImagesBucket}" exists and RLS policies are set correctly',
        );
      }
      return null;
    }
  }

  Future<void> _saveFoundPet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
        if (imageUrl == null) {
          // Show warning but continue saving without image
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.imageUploadFailed),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          // Continue saving without image
          imageUrl = null;
        }
      }

      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.pleaseLogin),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }

        await FoundPetService.addFoundPet(
          name: AppLocalizations.of(
            context,
          )!.foundAnimalName, // "Bulunan Hayvan"
          type: _selectedType!,
          breed: _selectedBreed!,
          city: _selectedCity!,
          imageUrl: imageUrl,
          userId: userId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.foundPetAddedSuccessfully,
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        print('Error adding found pet: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)!.errorAddingFoundPet}: ${e.toString()}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addFoundPet),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                            AppConstants.mediumRadius,
                          ),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(
                                    height: AppConstants.smallPadding,
                                  ),
                                  Text(
                                    l10n.selectImage,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.mediumRadius,
                                ),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),

                    // Pet Type Dropdown (limited to 3 types)
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: l10n.petType,
                        border: const OutlineInputBorder(),
                        hintText: l10n.selectPetType,
                      ),
                      items: AppConstants.foundPetTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                          _selectedBreed =
                              null; // Reset breed when type changes
                        });
                        _checkAndLoadSimilarPets();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseSelectPetType;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),

                    // Breed Dropdown (depends on selected pet type)
                    DropdownButtonFormField<String>(
                      value: _selectedBreed,
                      decoration: InputDecoration(
                        labelText: l10n.breed,
                        border: const OutlineInputBorder(),
                        hintText: _selectedType == null
                            ? l10n.selectPetType
                            : l10n.enterBreed,
                      ),
                      items: _selectedType == null
                          ? null
                          : _availableBreeds.map((breed) {
                              return DropdownMenuItem<String>(
                                value: breed,
                                child: Text(breed),
                              );
                            }).toList(),
                      onChanged: _selectedType == null
                          ? null
                          : (value) {
                              setState(() {
                                _selectedBreed = value;
                              });
                              _checkAndLoadSimilarPets();
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterBreed;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),

                    // City Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: l10n.city,
                        border: const OutlineInputBorder(),
                        hintText: l10n.selectCity,
                      ),
                      items: AppConstants.cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                        _checkAndLoadSimilarPets();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseSelectCity;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.mediumPadding),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveFoundPet,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          l10n.addFoundPet,
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.mediumRadius,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // Similar Lost Pets Section
                    if (_selectedType != null &&
                        _selectedBreed != null &&
                        _selectedCity != null)
                      _buildSimilarLostPetsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSimilarLostPetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              'Kayıp Hayvanlar (Benzer veya Yakın)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.mediumPadding),

        // Loading or Results
        if (_isLoadingSimilarPets)
          Container(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    _image != null 
                        ? 'AI ile benzer hayvanlar aranıyor...' 
                        : 'Benzer hayvanlar aranıyor...',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (_similarLostPets.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    _image != null
                        ? 'AI ile benzer kayıp hayvan bulunamadı. Lütfen daha sonra tekrar deneyin.'
                        : 'Benzer kayıp hayvan bulunamadı.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _similarLostPets.length,
              itemBuilder: (context, index) {
                return _buildMiniLostPetCard(_similarLostPets[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMiniLostPetCard(LostPet lostPet) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppConstants.smallPadding),
      child: Card(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        child: InkWell(
          onTap: () {
            // Show contact options
            _showContactOptions(lostPet);
          },
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
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
                  height: 100,
                  width: double.infinity,
                  child: Image.network(
                    lostPet.imageUrl ??
                        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.pets,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Pet Info
              Padding(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lostPet.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            lostPet.type,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            lostPet.city,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactOptions(LostPet lostPet) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.pets),
                title: Text(lostPet.name),
                subtitle: Text('${lostPet.type} - ${lostPet.city}'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Telefon'),
                subtitle: Text(lostPet.contactNumber),
                onTap: () async {
                  final uri = Uri.parse('tel:${lostPet.contactNumber}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('WhatsApp'),
                subtitle: Text(lostPet.whatsappNumber),
                onTap: () async {
                  final uri = Uri.parse(
                    'https://wa.me/${lostPet.whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '')}',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
