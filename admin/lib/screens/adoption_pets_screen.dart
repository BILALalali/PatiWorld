import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../models/adoption_pet.dart';
import '../services/admin_service.dart';

class AdoptionPetsScreen extends StatefulWidget {
  const AdoptionPetsScreen({super.key});

  @override
  State<AdoptionPetsScreen> createState() => _AdoptionPetsScreenState();
}

class _AdoptionPetsScreenState extends State<AdoptionPetsScreen> {
  List<AdoptionPet> _adoptionPets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdoptionPets();
  }

  Future<void> _loadAdoptionPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adoptionPets = await AdminService.getAdoptionPets();
      setState(() {
        _adoptionPets = adoptionPets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الإعلانات: ${e.toString()}'),
            backgroundColor: Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  Future<void> _deleteAdoptionPet(AdoptionPet adoptionPet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الإعلان'),
        content: Text('هل أنت متأكد من حذف إعلان ${adoptionPet.petName}؟'),
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
        await AdminService.deleteAdoptionPet(adoptionPet.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الإعلان بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAdoptionPets();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل حذف الإعلان: ${e.toString()}'),
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
          : _adoptionPets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Text(
                    'لا توجد إعلانات تبني',
                    style: TextStyle(
                      fontSize: AppConstants.subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAdoptionPets,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                itemCount: _adoptionPets.length,
                itemBuilder: (context, index) {
                  final adoptionPet = _adoptionPets[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: AppConstants.mediumPadding,
                    ),
                    child: ListTile(
                      leading: adoptionPet.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppConstants.smallRadius,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: adoptionPet.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.favorite),
                              ),
                            )
                          : const Icon(Icons.favorite, size: 60),
                      title: Text(
                        adoptionPet.petName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('النوع: ${adoptionPet.petType}'),
                          if (adoptionPet.age != null)
                            Text('العمر: ${adoptionPet.age}'),
                          if (adoptionPet.gender != null)
                            Text('الجنس: ${adoptionPet.gender}'),
                          if (adoptionPet.location != null)
                            Text('الموقع: ${adoptionPet.location}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAdoptionPet(adoptionPet),
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
}
