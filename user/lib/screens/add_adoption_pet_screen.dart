import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/app_constants.dart';
import 'location_picker_screen.dart';

class AddAdoptionPetScreen extends StatefulWidget {
  const AddAdoptionPetScreen({super.key});

  @override
  State<AddAdoptionPetScreen> createState() => _AddAdoptionPetScreenState();
}

class _AddAdoptionPetScreenState extends State<AddAdoptionPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _whatsappNumberController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedType = AppConstants.petTypes.first;
  String _selectedCity = AppConstants.cities.first;
  String _selectedGender = AppConstants.genderOptions.first;
  String _selectedCountryCode = '+90'; // Default to Turkey
  bool _isVaccinated = false;
  bool _isNeutered = false;
  bool _isLoading = false;
  File? _selectedImage;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedLocationName = 'Konum seçilmedi';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactNumberController.dispose();
    _whatsappNumberController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahiplendirme İlanı Ekle'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Name
                _buildTextField(
                  controller: _nameController,
                  label: 'Hayvan Adı',
                  hint: 'Hayvanın adını girin',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen hayvan adını girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Pet Type
                _buildDropdown(
                  label: 'Hayvan Türü',
                  value: _selectedType,
                  items: AppConstants.petTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Hayvan Açıklaması',
                  hint:
                      'Hayvanı detaylı olarak açıklayın (renk, boyut, özellikler, davranış...)',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen hayvan açıklaması girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Pet Image
                _buildImagePickerField(),

                const SizedBox(height: AppConstants.mediumPadding),

                // City
                _buildDropdown(
                  label: 'Şehir',
                  value: _selectedCity,
                  items: AppConstants.cities,
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Location Picker
                _buildLocationPickerField(),

                const SizedBox(height: AppConstants.mediumPadding),

                // Age
                _buildTextField(
                  controller: _ageController,
                  label: 'Yaş (Ay)',
                  hint: 'Yaşını ay olarak girin',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen yaş girin';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Lütfen geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Gender
                _buildDropdown(
                  label: 'Cinsiyet',
                  value: _selectedGender,
                  items: AppConstants.genderOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Health Status
                _buildHealthStatusSection(),

                const SizedBox(height: AppConstants.mediumPadding),

                // Contact Number
                _buildPhoneNumberField(
                  controller: _contactNumberController,
                  label: 'Telefon Numarası',
                  hint: '5xxxxxxxx',
                  selectedCountryCode: _selectedCountryCode,
                  onCountryCodeChanged: (value) {
                    setState(() {
                      _selectedCountryCode = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // WhatsApp Number
                _buildPhoneNumberField(
                  controller: _whatsappNumberController,
                  label: 'WhatsApp Numarası',
                  hint: '5xxxxxxxx',
                  selectedCountryCode: _selectedCountryCode,
                  onCountryCodeChanged: (value) {
                    setState(() {
                      _selectedCountryCode = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.extraLargePadding),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'İlanı Ekle',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String selectedCountryCode,
    required void Function(String?) onCountryCodeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Row(
          children: [
            // Country Code Dropdown
            Container(
              width: 120,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCountryCode,
                  isExpanded: true,
                  items: AppConstants.countryCodes.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(country['flag']!),
                          const SizedBox(width: 4),
                          Text(
                            country['code']!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onCountryCodeChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone Number Input
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen telefon numarası girin';
                  }
                  if (value.length < 10) {
                    return 'Telefon numarası en az 10 haneli olmalı';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hayvan Fotoğrafı',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedImage != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fotoğraf eklemek için dokunun',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library, size: 20),
                label: const Text('Galeriden Seç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (_selectedImage != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete, size: 20),
                  label: const Text('Kaldır'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLocationPickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konum',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _selectedLatitude != null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedLocationName,
                      style: TextStyle(
                        color: _selectedLatitude != null
                            ? Colors.black87
                            : Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickLocationFromMap,
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text('Haritadan Konum Seç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_selectedLatitude != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Konum seçildi',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sağlık Durumu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Aşılı'),
                value: _isVaccinated,
                onChanged: (value) {
                  setState(() {
                    _isVaccinated = value ?? false;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Kısırlaştırılmış'),
                value: _isNeutered,
                onChanged: (value) {
                  setState(() {
                    _isNeutered = value ?? false;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _pickLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
        _selectedLocationName = result['address'] ?? 'Seçilen konum';
      });
    }
  }

  Future<String?> _uploadImageToSupabase() async {
    if (_selectedImage == null) return null;

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'adoption-pets/$fileName';

      await Supabase.instance.client.storage
          .from(AppConstants.petImagesBucket)
          .upload(filePath, _selectedImage!);

      final imageUrl = Supabase.instance.client.storage
          .from(AppConstants.petImagesBucket)
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showErrorSnackBar('Lütfen giriş yapın');
        return;
      }

      // Upload image if selected
      String imageUrl =
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400'; // Default image
      if (_selectedImage != null) {
        final uploadedImageUrl = await _uploadImageToSupabase();
        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        } else {
          _showErrorSnackBar(
            'Resim yüklenirken hata oluştu. Lütfen tekrar deneyin.',
          );
          return;
        }
      }

      // Create adoption pet data map (without id - will be generated by database)
      final adoptionPetData = {
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'image_url': imageUrl,
        'description': _descriptionController.text.trim(),
        'city': _selectedCity,
        'contact_number':
            '$_selectedCountryCode${_contactNumberController.text.trim()}',
        'whatsapp_number':
            '$_selectedCountryCode${_whatsappNumberController.text.trim()}',
        'age': int.parse(_ageController.text.trim()),
        'gender': _selectedGender,
        'is_vaccinated': _isVaccinated,
        'is_neutered': _isNeutered,
        'latitude': _selectedLatitude,
        'longitude': _selectedLongitude,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'user_id': user.id,
        'is_active': true,
      };

      // Insert into database
      await Supabase.instance.client
          .from(AppConstants.adoptionPetsTable)
          .insert(adoptionPetData)
          .select();

      if (mounted) {
        _showSuccessSnackBar('İlan başarıyla eklendi');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('İlan eklenirken hata oluştu: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
