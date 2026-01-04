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
      Icons.person_rounded,
      Icons.auto_awesome_motion_rounded,
      Icons.insights_rounded,
      Icons.health_and_safety_rounded,
    ];

    return Container(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icons[currentStep - 1],
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'HỒ SƠ CÁ NHÂN'.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w900,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'BƯỚC $currentStep / $totalSteps',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
