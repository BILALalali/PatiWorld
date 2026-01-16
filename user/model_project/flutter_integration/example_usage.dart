/*
Profesyonel Hayvan Benzerlik Uygulaması - Ana Ekran
*/

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';

void main() {
  runApp(const AnimalSimilarityApp());
}

class AnimalSimilarityApp extends StatelessWidget {
  const AnimalSimilarityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hayvan Benzerlik Bulucu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 4,
          shadowColor: Colors.blueAccent,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  ApiResponse? _apiResponse;
  bool _isLoading = false;
  List<AnimalMatch> _matches = [];
  DatabaseStatistics? _statistics;

  // Renkler
  final Map<String, Color> _confidenceColors = {
    'ÇOK YÜKSEK': Colors.green,
    'YÜKSEK': Colors.lightGreen,
    'ORTA': Colors.orange,
    'DÜŞÜK': Colors.redAccent,
    'ÇOK DÜŞÜK': Colors.red,
  };

  final Map<String, IconData> _animalIcons = {
    'cats': Icons.pets,
    'dogs': Icons.pets,
    'birds': Icons.flight,
  };

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final response = await AnimalSimilarityAPI.getStatistics();
    if (response.success && response.data != null) {
      setState(() {
        _statistics = DatabaseStatistics.fromJson(response.data);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _apiResponse = null;
        _matches = [];
      });
    }
  }

  Future<void> _searchSimilar() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _matches = [];
    });

    try {
      final response = await AnimalSimilarityAPI.searchSimilarImage(
        _selectedImage!,
      );

      setState(() {
        _apiResponse = response;
        _isLoading = false;
      });

      if (response.success) {
        final matchesData = response.data['matches'] as List?;
        if (matchesData != null) {
          setState(() {
            _matches = matchesData
                .map((item) => AnimalMatch.fromJson(item))
                .toList();
          });

          // Başarı mesajı
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_matches.length} benzerlik bulundu'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        // Hata mesajı
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${response.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İstisna: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text('Görüntü seçilmedi', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _matches = [];
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    if (_statistics == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Veritabanı İstatistikleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.image, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  'Toplam Görüntü: ${_statistics!.totalImages}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  'Veritabanı Boyutu: ${_statistics!.databaseSizeMB.toStringAsFixed(2)} MB',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._statistics!.animalsByType.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '• ${entry.key}: ${entry.value} görüntü',
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(AnimalMatch match, int index) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _confidenceColors[match.confidence] ?? Colors.grey,
          child: Icon(
            _animalIcons[match.animalType] ?? Icons.pets,
            color: Colors.white,
          ),
        ),
        title: Text(
          match.breed,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Benzerlik: ${match.scorePercentage}',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Güven: ${match.confidence} • Kalite: ${match.matchQuality}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Chip(
          label: Text('#${index + 1}'),
          backgroundColor: Colors.blue[50],
        ),
        onTap: () {
          _showMatchDetails(match);
        },
      ),
    );
  }

  void _showMatchDetails(AnimalMatch match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${match.breed} Detayları'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.pets),
                title: const Text('Hayvan Türü'),
                subtitle: Text(match.animalType.toUpperCase()),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Irk'),
                subtitle: Text(match.breed),
              ),
              ListTile(
                leading: const Icon(Icons.score),
                title: const Text('Benzerlik Skoru'),
                subtitle: Text(
                  '${match.similarity.toStringAsFixed(3)} (${match.scorePercentage})',
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.verified,
                  color: _confidenceColors[match.confidence],
                ),
                title: const Text('Güven Seviyesi'),
                subtitle: Text(match.confidence),
              ),
              ListTile(
                leading: const Icon(Icons.assessment),
                title: const Text('Eşleşme Kalitesi'),
                subtitle: Text(match.matchQuality),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('KAPAT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 Hayvan Benzerlik Bulucu'),
        actions: [
          IconButton(icon: const Icon(Icons.info), onPressed: _showInfoDialog),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // İstatistikler
            _buildStatisticsCard(),

            const SizedBox(height: 20),

            // Görüntü Seçme Butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeriden Seç'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera ile Çek'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Görüntü Önizleme
            _buildImagePreview(),

            const SizedBox(height: 20),

            // Arama Butonu
            if (_selectedImage != null)
              ElevatedButton(
                onPressed: _isLoading ? null : _searchSimilar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text(
                        'BENZER HAYVANLARI BUL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

            const SizedBox(height: 20),

            // Sonuçlar
            if (_matches.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏆 Benzerlik Sonuçları',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._matches.asMap().entries.map((entry) {
                    return _buildMatchCard(entry.value, entry.key);
                  }).toList(),
                ],
              ),

            // Yükleniyor
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Benzerlik aranıyor...'),
                    ],
                  ),
                ),
              ),

            // Sonuç yok
            if (!_isLoading &&
                _selectedImage != null &&
                _matches.isEmpty &&
                _apiResponse != null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'Benzer görüntü bulunamadı',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAnimalDialog,
        icon: const Icon(Icons.add),
        label: const Text('Hayvan Ekle'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ℹ Uygulama Bilgisi'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hayvan Benzerlik Bulucu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Bu uygulama ile:\n'
                '• Kayıp hayvanlarınızın fotoğrafını yükleyin\n'
                '• Veritabanındaki benzer hayvanları bulun\n'
                '• %95+ doğrulukla eşleşmeleri görün\n'
                '• Yeni hayvanlar ekleyerek veritabanını genişletin',
              ),
              SizedBox(height: 10),
              Text(
                'Teknoloji: AI + Deep Learning + Flutter',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TAMAM'),
          ),
        ],
      ),
    );
  }

  void _showAddAnimalDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAnimalDialog(onAnimalAdded: _loadStatistics),
    );
  }
}

class AddAnimalDialog extends StatefulWidget {
  final VoidCallback onAnimalAdded;

  const AddAnimalDialog({super.key, required this.onAnimalAdded});

  @override
  _AddAnimalDialogState createState() => _AddAnimalDialogState();
}

class _AddAnimalDialogState extends State<AddAnimalDialog> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _animalType = 'cats';
  String _breed = '';
  String _description = '';
  bool _isSubmitting = false;

  final Map<String, List<String>> _breedsByType = {
    'cats': [
      'persian',
      'siamese',
      'bengal',
      'british',
      'maine',
      'ragdoll',
      'sphynx',
    ],
    'dogs': [
      'german_shepherd',
      'golden_retriever',
      'labrador_retriever',
      'pomeranian',
      'siberian',
    ],
    'birds': ['canada', 'palm', 'pigeon', 'ring'],
  };

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitAnimal() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir görüntü seçin')));
      return;
    }

    if (_breed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ırk bilgisini girin')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await AnimalSimilarityAPI.addNewAnimal(
        imageFile: _selectedImage!,
        animalType: _animalType,
        breed: _breed,
        description: _description.isNotEmpty ? _description : null,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hayvan başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onAnimalAdded();

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${response.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İstisna: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('➕ Yeni Hayvan Ekle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Görüntü Seçme
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text('Görüntü Seç'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Hayvan Türü
            DropdownButtonFormField<String>(
              value: _animalType,
              decoration: const InputDecoration(
                labelText: 'Hayvan Türü',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              items: const [
                DropdownMenuItem(value: 'cats', child: Text('🐱 Kedi')),
                DropdownMenuItem(value: 'dogs', child: Text('🐶 Köpek')),
                DropdownMenuItem(value: 'birds', child: Text('🐦 Kuş')),
              ],
              onChanged: (value) {
                setState(() {
                  _animalType = value!;
                  _breed = '';
                });
              },
            ),

            const SizedBox(height: 15),

            // Irk
            DropdownButtonFormField<String>(
              value: _breed.isNotEmpty ? _breed : null,
              decoration: const InputDecoration(
                labelText: 'Irk',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _breedsByType[_animalType]!.map((breed) {
                return DropdownMenuItem(
                  value: breed,
                  child: Text(breed.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _breed = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            // Açıklama (opsiyonel)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Açıklama (opsiyonel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              onChanged: (value) {
                _description = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('İPTAL'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitAnimal,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text('EKLE'),
        ),
      ],
    );
  }
}
