import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class ProfileStatsSection extends StatelessWidget {
  final String totalWorkouts;
  final String totalTime;
  final String caloriesBurned;
  final String streakDays;

  const ProfileStatsSection({
    super.key,
    required this.totalWorkouts,
    required this.totalTime,
    required this.caloriesBurned,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chỉ số cá nhân',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            // Large Streak Card
            Expanded(
              flex: 4,
              child: _buildBentoCard(
                streakDays,
                'Chuỗi ngày',
                Icons.whatshot_rounded,
                AppColors.primary,
                height: 180,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Stacked smaller cards
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  _buildBentoCard(
                    totalWorkouts,
                    'Buổi tập',
                    Icons.fitness_center_rounded,
                    const Color(0xFF8B00FF),
                    height: 82,
                    isCompact: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildBentoCard(
                    totalTime,
                    'Thời gian',
                    Icons.schedule_rounded,
                    const Color(0xFF00C6FF),
                    height: 82,
                    isCompact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildBentoCard(
          caloriesBurned,
          'Calories đã đốt',
          Icons.local_fire_department_rounded,
          const Color(0xFFFF4B2B),
          height: 90,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildBentoCard(
    String value,
    String label,
    IconData icon,
    Color color, {
    double? height,
    bool isCompact = false,
    bool isWide = false,
  }) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: isCompact || isWide ? AppSpacing.md : AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: isCompact ? 40 : 80,
              color: color.withValues(alpha: 0.05),
            ),
          ),
          if (isCompact)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            )
          else if (isWide)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
