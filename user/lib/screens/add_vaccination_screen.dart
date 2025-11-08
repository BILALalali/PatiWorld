import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../models/vaccination.dart';
import '../services/vaccination_service.dart';
import '../services/auth_debug_service.dart';
import '../l10n/app_localizations.dart';

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
  final _customVaccineNameController = TextEditingController();

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
      
      // Check if the vaccine name is in the predefined list
      if (AppConstants.vaccineTypes.contains(vaccination.vaccineName)) {
        _selectedVaccineType = vaccination.vaccineName;
      } else {
        // It's a custom vaccine name
        _selectedVaccineType = 'Diğer';
        _customVaccineNameController.text = vaccination.vaccineName;
      }
      
      _vaccineDate = vaccination.vaccineDate;
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
    _customVaccineNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vaccinationToEdit != null
              ? l10n.editVaccination
              : l10n.addVaccination,
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
                _buildTextField(
                  controller: _petNameController,
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
                  value: _selectedPetType,
                  items: AppConstants.petTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedPetType = value!;
                    });
                  },
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildDropdown(
                  label: l10n.vaccineType,
                  value: _selectedVaccineType,
                  items: AppConstants.vaccineTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedVaccineType = value!;
                      // Clear custom vaccine name if user selects a predefined type
                      if (value != 'Diğer') {
                        _customVaccineNameController.clear();
                      }
                    });
                  },
                ),

                // Show custom vaccine name field only when "Diğer" is selected
                if (_selectedVaccineType == 'Diğer') ...[
                  const SizedBox(height: AppConstants.mediumPadding),
                  _buildTextField(
                    controller: _customVaccineNameController,
                    label: l10n.customVaccineName,
                    hint: l10n.enterCustomVaccineName,
                    validator: (value) {
                      if (_selectedVaccineType == 'Diğer' &&
                          (value == null || value.trim().isEmpty)) {
                        return l10n.pleaseEnterCustomVaccineName;
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: AppConstants.mediumPadding),
                _buildDateField(),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildNumberField(),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildNextVaccineDateField(),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildTextField(
                  controller: _notesController,
                  label: l10n.notesOptional,
                  hint: l10n.enterAdditionalNotes,
                  maxLines: 3,
                ),

                const SizedBox(height: AppConstants.mediumPadding),
                _buildNextVaccineInfo(),

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
                            widget.vaccinationToEdit != null
                                ? l10n.updateVaccination
                                : l10n.addVaccination,
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vaccineDate,
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vaccineNumber,
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.nextVaccineDate,
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
    final l10n = AppLocalizations.of(context)!;

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
                l10n.nextVaccineInfo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            l10n.nextVaccineReminderDate,
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
            '${l10n.nextVaccineNumber}: ${_vaccineNumber + 1}',
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

      // Use custom vaccine name if "Diğer" is selected, otherwise use the selected type
      final vaccineName = _selectedVaccineType == 'Diğer'
          ? _customVaccineNameController.text.trim()
          : _selectedVaccineType;

      final vaccination = Vaccination(
        id:
            widget.vaccinationToEdit?.id ??
            '', // Will be generated by database for new vaccinations
        petName: _petNameController.text.trim(),
        petType: _selectedPetType,
        vaccineName: vaccineName,
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
