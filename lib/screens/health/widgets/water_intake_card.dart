import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class WaterIntakeCard extends StatelessWidget {
  final HealthFormState formState;

  const WaterIntakeCard({
    super.key,
    required this.formState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade400, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mục tiêu nước hàng ngày',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.cyan.shade100,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${formState.waterIntake} ml',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '≈ ${(formState.waterIntake / 250).toStringAsFixed(0)} ly nước mỗi ngày',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.cyan.shade100,
                ),
              ),
            ],
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop_outlined, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}
