import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:workout_app/constants/app_constants.dart';

Future<bool> showExitWorkoutDialog(
  BuildContext context, {
  required int completedExercises,
  required int totalExercises,
  required int elapsedSeconds,
  required double calories,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Exit Workout',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => _ExitWorkoutDialogContent(
      completedExercises: completedExercises,
      totalExercises: totalExercises,
      elapsedSeconds: elapsedSeconds,
      calories: calories,
    ),
    transitionBuilder: (context, anim1, anim2, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5 * anim1.value,
          sigmaY: 5 * anim1.value,
        ),
        child: FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _ExitWorkoutDialogContent extends StatelessWidget {
  final int completedExercises;
  final int totalExercises;
  final int elapsedSeconds;
  final double calories;

  const _ExitWorkoutDialogContent({
    required this.completedExercises,
    required this.totalExercises,
    required this.elapsedSeconds,
    required this.calories,
  });

  String _formatDuration(int seconds) {
    if (seconds < 0) return '00:00';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalExercises > 0 ? completedExercises / totalExercises : 0.0;
    final progressPercent = (progress * 100).toInt();

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Progress Visualization
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$progressPercent%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        'TIẾN ĐỘ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Title
              const Text(
                'Tạm dừng tập luyện?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Tiến trình của bạn gần hoàn thành rồi! Bạn có chắc muốn rời đi không?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Stats Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.fitness_center_rounded,
                      label: 'HOÀN THÀNH',
                      value: '$completedExercises/$totalExercises',
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: AppColors.cardBorder,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.timer_rounded,
                      label: 'THỜI GIAN',
                      value: _formatDuration(elapsedSeconds),
                      color: AppColors.info,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: AppColors.cardBorder,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.local_fire_department_rounded,
                      label: 'CALO',
                      value: '${calories.round()}',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                        ),
                      ),
                      child: const Text(
                        'TIẾP TỤC',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Thoát bài tập',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.black,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: AppColors.grey,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
