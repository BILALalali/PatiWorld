import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';
import '../services/admin_service.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await AdminService.getUsers();
      setState(() {
        _users = List<User>.from(users);
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
              'Kullanıcılar yüklenirken hata oluştu: ${e.toString()}',
            ),
            backgroundColor: Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  Future<void> _toggleUserActive(User user) async {
    try {
      await AdminService.toggleUserActive(user.id, !user.isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive
                  ? 'Kullanıcı başarıyla devre dışı bırakıldı'
                  : 'Kullanıcı başarıyla etkinleştirildi',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kullanıcı durumu güncellenirken hata oluştu: ${e.toString()}',
            ),
            backgroundColor: Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcıyı Sil'),
        content: Text(
          '${user.email} adlı kullanıcıyı silmek istediğinizden emin misiniz?',
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
        await AdminService.deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kullanıcı başarıyla silindi'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Kullanıcı silinirken hata oluştu: ${e.toString()}',
              ),
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
          : _users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: AppConstants.mediumPadding),
                  Text(
                    'Kullanıcı bulunmuyor',
                    style: TextStyle(
                      fontSize: AppConstants.subtitleFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: AppConstants.mediumPadding,
                    ),
                    child: ListTile(
                      leading: user.profileImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppConstants.smallRadius,
                              ),
                              child: CachedNetworkImage(
                                imageUrl: user.profileImageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person),
                              ),
                            )
                          : const Icon(Icons.person, size: 50),
                      title: Text(
                        user.fullName ?? user.email,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('E-posta: ${user.email}'),
                          if (user.phoneNumber != null)
                            Text('Telefon: ${user.phoneNumber}'),
                          Text(
                            'Durum: ${user.isActive ? "Aktif" : "Pasif"}',
                            style: TextStyle(
                              color: user.isActive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              user.isActive ? Icons.block : Icons.check_circle,
                              color: user.isActive
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            onPressed: () => _toggleUserActive(user),
                            tooltip: user.isActive
                                ? 'Devre Dışı Bırak'
                                : 'Etkinleştir',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user),
                            tooltip: 'Sil',
                          ),
                        ],
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
