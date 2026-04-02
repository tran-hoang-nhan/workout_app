import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../utils/label_utils.dart';
import '../../../constants/app_constants.dart';

class WorkoutHeader extends StatelessWidget {
  final Workout workout;
  const WorkoutHeader({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (workout.level != null) ...[
                _buildMetadataChip(
                  label: LabelUtils.getWorkoutLevelLabel(workout.level).toUpperCase(),
                  color: LabelUtils.getDifficultyColor(workout.level),
                  icon: Icons.bolt_rounded,
                ),
                const SizedBox(width: 8),
              ],
              if (workout.estimatedDuration != null)
                _buildMetadataChip(
                  label: '${workout.estimatedDuration} PHÚT',
                  color: AppColors.grey,
                  icon: Icons.timer_outlined,
                  isOutlined: true,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            workout.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip({
    required String label,
    required Color color,
    required IconData icon,
    bool isOutlined = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: isOutlined ? Border.all(color: color.withValues(alpha: 0.2)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
