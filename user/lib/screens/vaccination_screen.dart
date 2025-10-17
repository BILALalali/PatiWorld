import 'package:flutter/material.dart';
import '../models/vaccination.dart';
import '../constants/app_constants.dart';
import 'add_vaccination_screen.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  List<Vaccination> vaccinations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    // بيانات تجريبية للقاحات
    setState(() {
      vaccinations = [
        Vaccination(
          id: '1',
          petName: 'قطة صغيرة',
          petType: 'قطة',
          vaccineName: 'لقاح أساسي',
          vaccineDate: DateTime.now().subtract(const Duration(days: 20)),
          nextVaccineDate: DateTime.now().add(const Duration(days: 10)),
          vaccineNumber: 1,
          notes: 'لقاح أساسي للقطط الصغيرة',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          userId: 'user1',
        ),
        Vaccination(
          id: '2',
          petName: 'كلب لابرادور',
          petType: 'كلب',
          vaccineName: 'لقاح ضد داء الكلب',
          vaccineDate: DateTime.now().subtract(const Duration(days: 5)),
          nextVaccineDate: DateTime.now().add(const Duration(days: 25)),
          vaccineNumber: 2,
          notes: 'لقاح سنوي ضد داء الكلب',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          userId: 'user1',
        ),
        Vaccination(
          id: '3',
          petName: 'قطة كبيرة',
          petType: 'قطة',
          vaccineName: 'لقاح سنوي',
          vaccineDate: DateTime.now().subtract(const Duration(days: 30)),
          nextVaccineDate: DateTime.now().add(const Duration(days: 0)), // انتهى الموعد
          vaccineNumber: 3,
          notes: 'لقاح سنوي شامل',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          userId: 'user1',
        ),
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول اللقاحات'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vaccinations.isEmpty
              ? _buildEmptyState()
              : _buildVaccinationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddVaccinationScreen(),
            ),
          ).then((_) => _loadVaccinations());
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
          Icon(
            Icons.medical_services_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            'لا توجد لقاحات مسجلة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'أضف لقاحات حيواناتك الأليفة لتتبع مواعيدها',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationsList() {
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
        itemCount: vaccinations.length,
        itemBuilder: (context, index) {
          return _buildVaccinationCard(vaccinations[index]);
        },
      ),
    );
  }

  Widget _buildVaccinationCard(Vaccination vaccination) {
    final isOverdue = vaccination.isVaccineOverdue;
    final daysUntilNext = vaccination.daysUntilNextVaccine;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          border: isOverdue 
              ? Border.all(color: Colors.red, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination.petName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          vaccination.petType,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue 
                          ? Colors.red.withValues(alpha: 0.1)
                          : daysUntilNext <= 7 
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isOverdue 
                            ? Colors.red.withValues(alpha: 0.3)
                            : daysUntilNext <= 7 
                                ? Colors.orange.withValues(alpha: 0.3)
                                : Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isOverdue 
                          ? 'انتهى الموعد'
                          : daysUntilNext <= 7 
                              ? 'قريباً'
                              : 'مجدول',
                      style: TextStyle(
                        color: isOverdue 
                            ? Colors.red[700]
                            : daysUntilNext <= 7 
                                ? Colors.orange[700]
                                : Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.mediumPadding),
              
              // Vaccine Info
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vaccination.vaccineName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'لقاح #${vaccination.vaccineNumber}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.mediumPadding),
              
              // Dates
              Row(
                children: [
                  Expanded(
                    child: _buildDateInfo(
                      'تاريخ اللقاح',
                      vaccination.vaccineDate,
                      Icons.event,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Expanded(
                    child: _buildDateInfo(
                      'اللقاح التالي',
                      vaccination.nextVaccineDate,
                      Icons.schedule,
                      isOverdue ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              
              if (vaccination.notes.isNotEmpty) ...[
                const SizedBox(height: AppConstants.mediumPadding),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    vaccination.notes,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: AppConstants.mediumPadding),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _editVaccination(vaccination),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('تعديل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                      onPressed: () => _deleteVaccination(vaccination),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('حذف'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}/${date.month}/${date.year}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _editVaccination(Vaccination vaccination) {
    _showInfoSnackBar('ميزة التعديل قيد التطوير');
  }

  void _deleteVaccination(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف لقاح ${vaccination.petName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(vaccination);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Vaccination vaccination) async {
    try {
      setState(() {
        vaccinations.removeWhere((v) => v.id == vaccination.id);
      });
      
      _showSuccessSnackBar('تم حذف اللقاح بنجاح');
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء حذف اللقاح');
    }
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}