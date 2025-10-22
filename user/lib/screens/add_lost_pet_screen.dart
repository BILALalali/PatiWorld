import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';
import '../services/lost_pet_service.dart';
import '../services/storage_service.dart';

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
  String _selectedContactCountryCode = '+90'; // Default to Turkey
  String _selectedWhatsAppCountryCode = '+90'; // Default to Turkey
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıp Hayvan İlanı Ekle'),
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
                // Pet Image
                _buildImagePicker(),

                const SizedBox(height: AppConstants.mediumPadding),

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

                // Lost Date
                _buildDateField(
                  label: 'Kayıp Tarihi',
                  selectedDate: _selectedLostDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedLostDate = date;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Age
                _buildTextField(
                  controller: _ageController,
                  label: 'Yaş (Ay)',
                  hint: 'Yaşını ay olarak girin (opsiyonel)',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null) {
                        return 'Lütfen geçerli bir sayı girin';
                      }
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
                  selectedCountryCode: _selectedContactCountryCode,
                  onCountryCodeChanged: (value) {
                    setState(() {
                      _selectedContactCountryCode = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // WhatsApp Number
                _buildPhoneNumberField(
                  controller: _whatsappNumberController,
                  label: 'WhatsApp Numarası',
                  hint: '5xxxxxxxx',
                  selectedCountryCode: _selectedWhatsAppCountryCode,
                  onCountryCodeChanged: (value) {
                    setState(() {
                      _selectedWhatsAppCountryCode = value!;
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

  Widget _buildImagePicker() {
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
                        'Fotoğraf Ekle',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Galeriden seç',
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
                    label: const Text('Değiştir'),
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
                    label: const Text('Sil'),
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
      String? imageUrl;
      if (_selectedImage != null) {
        try {
          // رفع الصورة
          imageUrl = await StorageService.uploadLostPetImage(
            imageFile: _selectedImage!,
            userId: user.id,
            petName: _nameController.text.trim(),
          );

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resim başarıyla yüklendi!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          // إظهار رسالة خطأ واضحة
          if (mounted) {
            String errorMessage = 'Resim yükleme başarısız: ${e.toString()}';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Storage Ayarları',
                  textColor: Colors.white,
                  onPressed: () {
                    _showStorageSetupDialog();
                  },
                ),
              ),
            );
          }

          // إيقاف العملية إذا فشل رفع الصورة
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else {
        // Use default image if no image selected
        imageUrl =
            'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400';
      }

      // Add lost pet using service
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('İptal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        // التحقق من صحة الصورة
        if (!StorageService.isValidImageType(imageFile.path)) {
          _showErrorSnackBar(
            'Lütfen geçerli bir resim dosyası seçin (JPG, PNG, GIF)',
          );
          return;
        }

        if (!StorageService.isValidImageSize(imageFile)) {
          _showErrorSnackBar('Resim boyutu 5MB\'dan küçük olmalıdır');
          return;
        }

        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Resim seçilirken hata oluştu: ${e.toString()}');
    }
  }

  void _showStorageSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعداد Storage'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'لحل مشكلة رفع الصور، يرجى اتباع الخطوات التالية:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('1. اذهب إلى Supabase Dashboard'),
              Text('2. اختر مشروع "PatiWorld"'),
              Text('3. اضغط على "Storage" من القائمة الجانبية'),
              Text('4. اضغط "New bucket"'),
              Text('5. أنشئ bucket بالاسم: pet-images'),
              Text('6. فعّل "Public"'),
              Text('7. اضبط File size limit: 5MB'),
              Text(
                '8. Allowed MIME types: image/jpeg, image/png, image/gif, image/webp',
              ),
              Text('9. اضغط "Create bucket"'),
              SizedBox(height: 8),
              Text('كرر نفس الخطوات لإنشاء bucket آخر باسم: profile-images'),
              SizedBox(height: 16),
              Text(
                'بعد إنشاء الـ buckets، أعد تشغيل التطبيق وجرب رفع الصورة مرة أخرى.',
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
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }
}
