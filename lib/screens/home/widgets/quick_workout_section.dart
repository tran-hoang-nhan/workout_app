import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class QuickWorkout {
  final String name;
  final String duration;
  final String difficulty;
  final IconData icon;

  QuickWorkout({
    required this.name,
    required this.duration,
    required this.difficulty,
    required this.icon,
  });
}

class QuickWorkoutSection extends StatelessWidget {
  const QuickWorkoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<QuickWorkout> quickWorkouts = [
      QuickWorkout(
        name: 'Cardio Buổi Sáng',
        duration: '20 phút',
        difficulty: 'Dễ',
        icon: Icons.directions_run,
      ),
      QuickWorkout(
        name: 'Tập Lưng & Vai',
        duration: '45 phút',
        difficulty: 'Trung bình',
        icon: Icons.fitness_center,
      ),
      QuickWorkout(
        name: 'Core & Stability',
        duration: '30 phút',
        difficulty: 'Khó',
        icon: Icons.accessibility,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bài tập nhanh',
              style: TextStyle(
                fontSize: AppFontSize.lg,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: AppFontSize.sm,
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickWorkouts.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final workout = quickWorkouts[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Icon(Icons.local_fire_department, color: Colors.orange.shade600, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: const TextStyle(
                            fontSize: AppFontSize.sm,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: AppColors.grey),
                            const SizedBox(width: 4),
                            Text(
                              workout.duration,
                              style: const TextStyle(
                                fontSize: AppFontSize.xs,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(workout.difficulty).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      workout.difficulty,
                      style: TextStyle(
                        fontSize: AppFontSize.xs,
                        color: _getDifficultyColor(workout.difficulty),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Dễ':
        return Colors.green;
      case 'Trung bình':
        return Colors.yellow;
      case 'Khó':
        return Colors.red;
      default:
        return AppColors.grey;
    }
  }
}
