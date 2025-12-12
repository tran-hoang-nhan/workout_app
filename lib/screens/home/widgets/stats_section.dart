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
        LayoutBuilder(
          builder: (context, constraints) {
            // Tính toán spacing responsive
            final screenWidth = constraints.maxWidth;
            final spacing = screenWidth > 400 ? 6.0 : 4.0;
            final padding = screenWidth > 400 ? 10.0 : 8.0;
            
            return GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: 0.95,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: stats.map((stat) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1A3F),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    border: Border.all(color: const Color(0xFF1A3A5F)),
                  ),
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: stat.gradient,
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
                        child: Icon(
                          stat.icon,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stat.value,
                        style: TextStyle(
                          fontSize: screenWidth > 400 ? 15 : 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat.label,
                        style: TextStyle(
                          fontSize: screenWidth > 400 ? 10 : 9,
                          color: AppColors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
