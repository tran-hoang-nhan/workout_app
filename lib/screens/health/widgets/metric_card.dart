import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String desc;
  final IconData icon;
  final Color color1;
  final Color color2;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.desc,
    required this.icon,
    required this.color1,
    required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        border: Border.all(color: Colors.grey.shade800),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color1, color2]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            desc,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class BMRTDEESection extends StatelessWidget {
  final HealthCalculations calculations;

  const BMRTDEESection({
    super.key,
    required this.calculations,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 200,
            child: MetricCard(
              label: 'BMR (kcal/ngày)',
              value: calculations.bmr.toString(),
              desc: 'Trao đổi chất cơ bản',
              icon: Icons.trending_up,
              color1: Colors.orange.shade500,
              color2: Colors.red.shade500,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SizedBox(
            height: 200,
            child: MetricCard(
              label: 'TDEE (kcal/ngày)',
              value: calculations.tdee.toString(),
              desc: 'Tổng năng lượng tiêu thụ',
              icon: Icons.fitness_center,
              color1: Colors.purple.shade500,
              color2: Colors.pink.shade500,
            ),
          ),
        ),
      ],
    );
  }
}
