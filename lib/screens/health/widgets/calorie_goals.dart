import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class CalorieGoals extends StatelessWidget {
  final HealthCalculations calculations;

  const CalorieGoals({
    super.key,
    required this.calculations,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mục tiêu calo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCalorieGoalRow(
            'Thâm hụt',
            '${(calculations.tdee * 0.85).toStringAsFixed(0)} kcal',
            Colors.blue.shade400,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCalorieGoalRow(
            'Duy trì',
            '${calculations.tdee.toStringAsFixed(0)} kcal',
            Colors.green.shade400,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCalorieGoalRow(
            'Dư thừa',
            '${(calculations.tdee * 1.15).toStringAsFixed(0)} kcal',
            Colors.orange.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieGoalRow(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Mục tiêu calo',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
