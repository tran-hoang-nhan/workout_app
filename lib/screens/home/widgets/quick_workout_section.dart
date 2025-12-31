import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class QuickWorkout {
  final String name;
  final String duration;
  final String difficulty;
  final IconData icon;
  final Color color;

  QuickWorkout({
    required this.name,
    required this.duration,
    required this.difficulty,
    required this.icon,
    required this.color,
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
        color: const Color(0xFF00C6FF),
      ),
      QuickWorkout(
        name: 'Tập Lưng & Vai',
        duration: '45 phút',
        difficulty: 'Trung bình',
        icon: Icons.fitness_center,
        color: const Color(0xFF8B00FF),
      ),
      QuickWorkout(
        name: 'Core & Stability',
        duration: '30 phút',
        difficulty: 'Khó',
        icon: Icons.accessibility,
        color: const Color(0xFFFF4B2B),
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
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: AppFontSize.sm,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: quickWorkouts.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final workout = quickWorkouts[index];
              return _buildWorkoutCard(workout);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(QuickWorkout workout) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: workout.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Mesh Gradient Background Effect
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      workout.color.withValues(alpha: 0.1),
                      workout.color.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: workout.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(workout.icon, color: workout.color, size: 24),
                      ),
                      _buildDifficultyTag(workout.difficulty, workout.color),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    workout.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: AppColors.grey.withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            workout.duration,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: workout.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: workout.color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyTag(String difficulty, Color baseColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AppColors.black,
        ),
      ),
    );
  }
}
