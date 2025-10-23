import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../models/vaccination.dart';
import '../services/vaccination_service.dart';
import '../services/auth_debug_service.dart';

class AddVaccinationScreen extends StatefulWidget {
  final Vaccination? vaccinationToEdit;

  const AddVaccinationScreen({super.key, this.vaccinationToEdit});

  @override
  State<AddVaccinationScreen> createState() => _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends State<AddVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPetType = AppConstants.petTypes.first;
  String _selectedVaccineType = AppConstants.vaccineTypes.first;
  DateTime _vaccineDate = DateTime.now();
  DateTime _nextVaccineDate = DateTime.now().add(const Duration(days: 30));
  int _vaccineNumber = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.vaccinationToEdit != null) {
      final vaccination = widget.vaccinationToEdit!;
      _petNameController.text = vaccination.petName;
      _selectedPetType = vaccination.petType;
      _selectedVaccineType = vaccination.vaccineName;
      _vaccineDate = vaccination.vaccineDate;
      // التأكد من أن تاريخ اللقاح التالي ليس في الماضي
      _nextVaccineDate = vaccination.nextVaccineDate.isBefore(DateTime.now())
          ? DateTime.now().add(const Duration(days: 30))
          : vaccination.nextVaccineDate;
      _vaccineNumber = vaccination.vaccineNumber;
      _notesController.text = vaccination.notes;
    }
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vaccinationToEdit != null ? 'Aşı Düzenle' : 'Aşı Ekle',
        ),
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
                  controller: _petNameController,
                  label: 'Hayvan Adı',
                  hint: 'Hayvan adını girin',
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
                  value: _selectedPetType,
                  items: AppConstants.petTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedPetType = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Vaccine Type
                _buildDropdown(
                  label: 'Aşı Türü',
                  value: _selectedVaccineType,
                  items: AppConstants.vaccineTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedVaccineType = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Vaccine Date
                _buildDateField(),

                const SizedBox(height: AppConstants.mediumPadding),

                // Vaccine Number
                _buildNumberField(),

                const SizedBox(height: AppConstants.mediumPadding),

                // Next Vaccine Date
                _buildNextVaccineDateField(),

                const SizedBox(height: AppConstants.mediumPadding),

                // Notes
                _buildTextField(
                  controller: _notesController,
                  label: 'Notlar (İsteğe Bağlı)',
                  hint: 'Ek notlar girin',
                  maxLines: 3,
                ),

                const SizedBox(height: AppConstants.mediumPadding),

                // Next Vaccine Info
                _buildNextVaccineInfo(),

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
                        : Text(
                            widget.vaccinationToEdit != null
                                ? 'Aşı Güncelle'
                                : 'Aşı Ekle',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aşı Tarihi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        GestureDetector(
          onTap: _selectVaccineDate,
          child: Container(
            padding: const EdgeInsets.all(16),
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
                  '${_vaccineDate.day}/${_vaccineDate.month}/${_vaccineDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aşı Numarası',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (_vaccineNumber > 1) {
                  setState(() {
                    _vaccineNumber--;
                  });
                }
              },
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                '$_vaccineNumber',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {
                setState(() {
                  _vaccineNumber++;
                });
              },
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextVaccineDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sonraki Aşı Tarihi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        GestureDetector(
          onTap: _selectNextVaccineDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_nextVaccineDate.day}/${_nextVaccineDate.month}/${_nextVaccineDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextVaccineInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Sonraki Aşı Bilgileri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Sonraki aşı için hatırlatma tarihi:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.blue[600]),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            '${_nextVaccineDate.day}/${_nextVaccineDate.month}/${_nextVaccineDate.year}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Sonraki aşı numarası: ${_vaccineNumber + 1}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.blue[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _selectVaccineDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _vaccineDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _vaccineDate) {
      setState(() {
        _vaccineDate = picked;
      });
    }
  }

  Future<void> _selectNextVaccineDate() async {
    // التأكد من أن التاريخ الافتراضي ليس في الماضي
    final initialDate = _nextVaccineDate.isBefore(DateTime.now())
        ? DateTime.now().add(const Duration(days: 30))
        : _nextVaccineDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _nextVaccineDate) {
      setState(() {
        _nextVaccineDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Debug authentication status
    AuthDebugService.debugAuthStatus();

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID from authentication
      final user = Supabase.instance.client.auth.currentUser;
      print('Current user: $user');
      if (user == null) {
        _showErrorSnackBar('Lütfen giriş yapın');
        return;
      }
      print('User ID: ${user.id}');

      final vaccination = Vaccination(
        id: widget.vaccinationToEdit?.id ?? '', // Will be generated by database for new vaccinations
        petName: _petNameController.text.trim(),
        petType: _selectedPetType,
        vaccineName: _selectedVaccineType,
        vaccineDate: _vaccineDate,
        nextVaccineDate: _nextVaccineDate,
        vaccineNumber: _vaccineNumber,
        notes: _notesController.text.trim(),
        createdAt: widget.vaccinationToEdit?.createdAt ?? DateTime.now(),
        userId: user.id,
      );

      if (widget.vaccinationToEdit != null) {
        // تحديث لقاح موجود
        await VaccinationService.updateVaccination(vaccination);
        _showSuccessSnackBar('تم تحديث اللقاح بنجاح');
      } else {
        // إضافة لقاح جديد
        await VaccinationService.addVaccination(vaccination);
        _showSuccessSnackBar('تم إضافة اللقاح بنجاح');
      }

      if (mounted) {
        Navigator.pop(context, true); // إرجاع true للإشارة إلى نجاح العملية
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('فشل في حفظ اللقاح: $e');
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
