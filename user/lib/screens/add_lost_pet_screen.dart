import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../services/lost_pet_service.dart';
import '../services/storage_service.dart';
import '../l10n/app_localizations.dart';

class AddLostPetScreen extends StatefulWidget {
  const AddLostPetScreen({super.key});

  @override
  State<AddLostPetScreen> createState() => _AddLostPetScreenState();
}

class _AddLostPetScreenState extends State<AddLostPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _whatsappNumberController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedType = AppConstants.petTypes.first;
  String _selectedCity = AppConstants.cities.first;
  String _selectedGender = AppConstants.genderOptions.first;
  String _selectedContactCountryCode = '+90';
  String _selectedWhatsAppCountryCode = '+90';
  DateTime _selectedLostDate = DateTime.now();
  bool _isVaccinated = false;
  bool _isNeutered = false;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addLostPetListing),
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
                _buildImagePicker(),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildTextField(
                  controller: _nameController,
                  label: l10n.petName,
                  hint: l10n.enterPetName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterPetName;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildDropdown(
                  label: l10n.petType,
                  value: _selectedType,
                  items: AppConstants.petTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildTextField(
                  controller: _descriptionController,
                  label: l10n.petDescription,
                  hint: l10n.describePetInDetail,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterPetDescription;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildDropdown(
                  label: l10n.city,
                  value: _selectedCity,
                  items: AppConstants.cities,
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildDateField(
                  label: l10n.lostDate,
                  selectedDate: _selectedLostDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedLostDate = date;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildTextField(
                  controller: _ageController,
                  label: l10n.ageInMonths,
                  hint: l10n.enterAgeInMonthsOptional,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null) {
                        return l10n.pleaseEnterValidNumber;
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildDropdown(
                  label: l10n.gender,
                  value: _selectedGender,
                  items: AppConstants.genderOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildHealthStatusSection(),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildPhoneNumberField(
                  controller: _contactNumberController,
                  label: l10n.phoneNumber,
                  hint: '5xxxxxxxx',
                  selectedCountryCode: _selectedContactCountryCode,
                  onCountryCodeChanged: (value) {
                    setState(() {
                      _selectedContactCountryCode = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildPhoneNumberField(
                  controller: _whatsappNumberController,
                  label: l10n.whatsappNumber,
                  hint: '5xxxxxxxx',
                  selectedCountryCode: _selectedWhatsAppCountryCode,
                  onCountryCodeChanged: (value) {
                    setState(() {
                      _selectedWhatsAppCountryCode = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.extraLargePadding),
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
                        : Text(
                            l10n.addListing,
                            style: const TextStyle(
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

  Widget _buildImagePicker() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.petPhoto,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.addPhoto,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.selectFromGallery,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
          ),
        ),
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showImagePickerOptions,
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(l10n.change),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                    icon: const Icon(Icons.delete, size: 16),
                    label: Text(l10n.delete),
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
            ),
          ),
      ],
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

  Widget _buildDateField({
    required String label,
    required DateTime selectedDate,
    required void Function(DateTime) onDateSelected,
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
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
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
    final l10n = AppLocalizations.of(context)!;
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
                    return l10n.pleaseEnterPhoneNumber;
                  }
                  if (value.length < 10) {
                    return l10n.phoneNumberMinLength;
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

  Widget _buildHealthStatusSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.healthStatus,
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
                title: Text(l10n.vaccinated),
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
                title: Text(l10n.neutered),
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

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;

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
        _showErrorSnackBar(l10n.pleaseLogin);
        return;
      }

      String? imageUrl;
      if (_selectedImage != null) {
        try {
          imageUrl = await StorageService.uploadLostPetImage(
            imageFile: _selectedImage!,
            userId: user.id,
            petName: _nameController.text.trim(),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.imageUploadedSuccessfully),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            String errorMessage = '${l10n.imageUploadFailed}: ${e.toString()}';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: l10n.storageSettings,
                  textColor: Colors.white,
                  onPressed: () {
                    _showStorageSetupDialog();
                  },
                ),
              ),
            );
          }

          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
        imageUrl =
            'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400';
      }

      await LostPetService.addLostPet(
        name: _nameController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim(),
        city: _selectedCity,
        lostDate: _selectedLostDate,
        contactNumber:
            '$_selectedContactCountryCode${_contactNumberController.text.trim()}',
        whatsappNumber:
            '$_selectedWhatsAppCountryCode${_whatsappNumberController.text.trim()}',
        imageUrl: imageUrl,
        ageMonths: _ageController.text.isNotEmpty
            ? int.parse(_ageController.text.trim())
            : null,
        gender: _selectedGender,
        isVaccinated: _isVaccinated,
        isNeutered: _isNeutered,
        userId: user.id,
      );

      if (mounted) {
        _showSuccessSnackBar(l10n.listingAddedSuccessfully);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('${l10n.errorAddingListing}: ${e.toString()}');
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

  void _showImagePickerOptions() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.selectFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: Text(l10n.cancel),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        if (!StorageService.isValidImageType(imageFile.path)) {
          _showErrorSnackBar(l10n.pleaseSelectValidImageFile);
          return;
        }

        if (!StorageService.isValidImageSize(imageFile)) {
          _showErrorSnackBar(l10n.imageSizeMustBeLessThan5MB);
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      _showErrorSnackBar('${l10n.errorSelectingImage}: ${e.toString()}');
    }
  }

  void _showStorageSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Setup'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To fix image upload issues, please follow these steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('1. Go to Supabase Dashboard'),
              Text('2. Select "PatiWorld" project'),
              Text('3. Click "Storage" from sidebar'),
              Text('4. Click "New bucket"'),
              Text('5. Create bucket named: pet-images'),
              Text('6. Enable "Public"'),
              Text('7. Set File size limit: 5MB'),
              Text(
                '8. Allowed MIME types: image/jpeg, image/png, image/gif, image/webp',
              ),
              Text('9. Click "Create bucket"'),
              SizedBox(height: 8),
              Text(
                'Repeat same steps to create another bucket named: profile-images',
              ),
              SizedBox(height: 16),
              Text(
                'After creating buckets, restart the app and try uploading image again.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
