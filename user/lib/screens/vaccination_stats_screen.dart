import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/vaccination_service.dart';

class VaccinationStatsScreen extends StatefulWidget {
  const VaccinationStatsScreen({super.key});

  @override
  State<VaccinationStatsScreen> createState() => _VaccinationStatsScreenState();
}

class _VaccinationStatsScreenState extends State<VaccinationStatsScreen> {
  Map<String, int>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final vaccinationStats = await VaccinationService.getVaccinationStats();
      setState(() {
        stats = vaccinationStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('فشل في جلب الإحصائيات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات اللقاحات'),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : stats == null
            ? _buildErrorState()
            : _buildStatsContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 100, color: Colors.red[300]),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            'فشل في تحميل الإحصائيات',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.red[600]),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          ElevatedButton(
            onPressed: _loadStats,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // إجمالي اللقاحات
          _buildStatCard(
            title: 'إجمالي اللقاحات',
            count: stats!['total'] ?? 0,
            icon: Icons.medical_services,
            color: Colors.blue,
          ),

          const SizedBox(height: AppConstants.mediumPadding),

          // اللقاحات المجدولة
          _buildStatCard(
            title: 'اللقاحات المجدولة',
            count: stats!['scheduled'] ?? 0,
            icon: Icons.schedule,
            color: Colors.green,
          ),

          const SizedBox(height: AppConstants.mediumPadding),

          // اللقاحات القادمة
          _buildStatCard(
            title: 'اللقاحات القادمة (7 أيام)',
            count: stats!['upcoming'] ?? 0,
            icon: Icons.warning,
            color: Colors.orange,
          ),

          const SizedBox(height: AppConstants.mediumPadding),

          // اللقاحات المنتهية الصلاحية
          _buildStatCard(
            title: 'اللقاحات المنتهية الصلاحية',
            count: stats!['overdue'] ?? 0,
            icon: Icons.error,
            color: Colors.red,
          ),

          const SizedBox(height: AppConstants.largePadding),

          // نصيحة
          _buildTipCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppConstants.mediumPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    '$count لقاح',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          gradient: LinearGradient(
            colors: [
              Colors.blue.withValues(alpha: 0.1),
              Colors.purple.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.blue[700],
                  size: 24,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'نصيحة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'احرص على تحديث مواعيد اللقاحات بانتظام لضمان صحة حيوانك الأليف. يمكنك إضافة تذكيرات للقاحات القادمة.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.blue[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
