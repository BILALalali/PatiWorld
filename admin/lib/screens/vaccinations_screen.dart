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
            content: Text(
              'Aşı kayıtları yüklenirken hata oluştu: ${e.toString()}',
            ),
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
        title: const Text('Kaydı Sil'),
        content: Text(
          '${vaccination.petName} adlı aşı kaydını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Color(AppConstants.errorColor),
            ),
            child: const Text('Sil'),
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
              content: Text('Kayıt başarıyla silindi'),
              backgroundColor: Colors.green,
            ),
          );
          _loadVaccinations();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kayıt silinirken hata oluştu: ${e.toString()}'),
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
                    'Aşı kaydı bulunmuyor',
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
                      leading: Icon(
                        Icons.medical_services,
                        size: 50,
                        color: Color(AppConstants.primaryColor),
                      ),
                      title: Text(
                        vaccination.petName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hayvan Türü: ${vaccination.petType}'),
                          Text('Aşı Adı: ${vaccination.vaccineName}'),
                          if (vaccination.vaccineDate != null)
                            Text(
                              'Aşı Tarihi: ${_formatDate(vaccination.vaccineDate!)}',
                            ),
                          if (vaccination.nextVaccineDate != null)
                            Text(
                              'Sonraki Aşı: ${_formatDate(vaccination.nextVaccineDate!)}',
                            ),
                          if (vaccination.notes != null &&
                              vaccination.notes!.isNotEmpty)
                            Text('Notlar: ${vaccination.notes}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteVaccination(vaccination),
                        tooltip: 'Sil',
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
