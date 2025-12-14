import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class ProfileStatsSection extends StatelessWidget {
  final String totalWorkouts;
  final String totalTime;
  final String caloriesBurned;
  final String streakDays;

  const ProfileStatsSection({
    super.key,
    this.totalWorkouts = '0',
    this.totalTime = '0h',
    this.caloriesBurned = '0k',
    this.streakDays = '0 ngày',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow('Tổng buổi tập', totalWorkouts),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow('Tổng thời gian', totalTime),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow('Calories đã đốt', caloriesBurned),
          const SizedBox(height: AppSpacing.md),
          _buildStatRow('Chuỗi ngày', streakDays, isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontSize: AppFontSize.md),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSize.lg,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.primary : AppColors.black,
          ),
        ),
      ],
    );
  }
}
