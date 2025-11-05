import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/vaccination.dart';
import '../services/admin_service.dart';

class VaccinationsScreen extends StatefulWidget {
  const VaccinationsScreen({super.key});

  @override
  State<VaccinationsScreen> createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends State<VaccinationsScreen> {
  List<Vaccination> _vaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vaccinations = await AdminService.getVaccinations();
      setState(() {
        _vaccinations = vaccinations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل سجلات اللقاحات: ${e.toString()}'),
            backgroundColor: Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  Future<void> _deleteVaccination(Vaccination vaccination) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السجل'),
        content: Text('هل أنت متأكد من حذف سجل لقاح ${vaccination.petName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Color(AppConstants.errorColor),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService.deleteVaccination(vaccination.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف السجل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _loadVaccinations();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حذف السجل: ${e.toString()}'),
              backgroundColor: Color(AppConstants.errorColor),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vaccinations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Text(
                    'لا توجد سجلات لقاحات',
                    style: TextStyle(
                      fontSize: AppConstants.subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadVaccinations,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                itemCount: _vaccinations.length,
                itemBuilder: (context, index) {
                  final vaccination = _vaccinations[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: AppConstants.mediumPadding,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.medical_services,
                        size: 50,
                        color: Colors.blue,
                      ),
                      title: Text(
                        vaccination.petName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('نوع اللقاح: ${vaccination.vaccineType}'),
                          Text(
                            'تاريخ اللقاح: ${_formatDate(vaccination.vaccinationDate)}',
                          ),
                          if (vaccination.nextVaccinationDate != null)
                            Text(
                              'اللقاح القادم: ${_formatDate(vaccination.nextVaccinationDate!)}',
                            ),
                          if (vaccination.veterinarianName != null)
                            Text('الطبيب: ${vaccination.veterinarianName}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteVaccination(vaccination),
                        tooltip: 'حذف',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
