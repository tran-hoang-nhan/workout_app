import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class HeaderWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const HeaderWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.fitness_center,
      Icons.flag,
      Icons.restaurant,
      Icons.favorite,
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icons[currentStep - 1],
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Thiết lập hồ sơ sức khỏe',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bước $currentStep / $totalSteps',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
