import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/workout.dart';
import '../../workout_detail/workout_detail_screen.dart';

class WorkoutSuggestionCard extends StatelessWidget {
  final Workout workout;

  const WorkoutSuggestionCard({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workout: workout),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7F00).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center, color: Color(0xFFFF7F00), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workout.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChip(Icons.timer_outlined, '${workout.estimatedDuration ?? 0} phút'),
                const SizedBox(width: 8),
                _buildChip(Icons.bar_chart, workout.level ?? 'Cơ bản'),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Bắt đầu ngay',
                  style: TextStyle(
                    color: Color(0xFFFF7F00),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: Color(0xFFFF7F00), size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
