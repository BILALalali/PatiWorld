import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../models/lost_pet.dart';
import '../services/admin_service.dart';

class LostPetsScreen extends StatefulWidget {
  const LostPetsScreen({super.key});

  @override
  State<LostPetsScreen> createState() => _LostPetsScreenState();
}

class _LostPetsScreenState extends State<LostPetsScreen> {
  List<LostPet> _lostPets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLostPets();
  }

  Future<void> _loadLostPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lostPets = await AdminService.getLostPets();
      setState(() {
        _lostPets = lostPets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İlanlar yüklenirken hata oluştu: ${e.toString()}'),
            backgroundColor: Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  Future<void> _deleteLostPet(LostPet lostPet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: Text(
          '${lostPet.name} adlı ilanı silmek istediğinizden emin misiniz?',
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
        await AdminService.deleteLostPet(lostPet.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İlan başarıyla silindi'),
              backgroundColor: Colors.green,
            ),
          );
          _loadLostPets();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('İlan silinirken hata oluştu: ${e.toString()}'),
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
          : _lostPets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Text(
                    'Kayıp hayvan ilanı bulunmuyor',
                    style: TextStyle(
                      fontSize: AppConstants.subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLostPets,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                itemCount: _lostPets.length,
                itemBuilder: (context, index) {
                  final lostPet = _lostPets[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: AppConstants.mediumPadding,
                    ),
                    child: ListTile(
                      leading: lostPet.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppConstants.smallRadius,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: lostPet.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.pets),
                              ),
                            )
                          : const Icon(Icons.pets, size: 60),
                      title: Text(
                        lostPet.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tür: ${lostPet.type}'),
                          Text('Şehir: ${lostPet.city}'),
                          Text(
                            'Kayıp Tarihi: ${_formatDate(lostPet.lostDate)}',
                          ),
                          if (lostPet.contactNumber.isNotEmpty)
                            Text('İletişim: ${lostPet.contactNumber}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteLostPet(lostPet),
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
