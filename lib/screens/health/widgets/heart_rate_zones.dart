import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class HeartRateZones extends StatelessWidget {
  final HealthCalculations calculations;

  const HeartRateZones({
    super.key,
    required this.calculations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 20),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Vùng nhịp tim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max HR',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              Text(
                '${calculations.maxHeartRate.toStringAsFixed(0)} bpm',
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildHeartRateZoneRow(
            'Đốt mỡ (60-70%)',
            '${calculations.fatBurnZone.min}-${calculations.fatBurnZone.max} bpm',
            Colors.orange.shade500,
            0.65,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildHeartRateZoneRow(
            'Cardio (70-85%)',
            '${calculations.cardioZone.min}-${calculations.cardioZone.max} bpm',
            Colors.red.shade500,
            0.80,
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateZoneRow(String label, String value, Color color, double progress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
