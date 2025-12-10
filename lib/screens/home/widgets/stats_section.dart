import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class StatCard {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;

  StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StatCard> stats = [
      StatCard(
        icon: Icons.local_fire_department,
        label: 'Calories',
        value: '324',
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7F00), Color(0xFFFF0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      StatCard(
        icon: Icons.flag_outlined,
        label: 'Mục tiêu',
        value: '75%',
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF00CCFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      StatCard(
        icon: Icons.schedule,
        label: 'Thời gian',
        value: '45m',
        gradient: const LinearGradient(
          colors: [Color(0xFF8B00FF), Color(0xFFFF1493)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 3.0,
          childAspectRatio: 1.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: stats.map((stat) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A1A3F),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(color: const Color(0xFF1A3A5F)),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: stat.gradient,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Icon(
                      stat.icon,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
