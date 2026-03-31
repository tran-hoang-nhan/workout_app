import 'package:flutter/material.dart';
import 'package:workout_app/constants/app_constants.dart';

Future<bool> showExitWorkoutDialog(
  BuildContext context, {
  required int completedExercises,
  required int totalExercises,
  required int elapsedSeconds,
  required double estimatedCalories,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _ExitWorkoutDialogContent(
      completedExercises: completedExercises,
      totalExercises: totalExercises,
      elapsedSeconds: elapsedSeconds,
      estimatedCalories: estimatedCalories,
    ),
  );
  return result ?? false;
}

class _ExitWorkoutDialogContent extends StatelessWidget {
  final int completedExercises;
  final int totalExercises;
  final int elapsedSeconds;
  final double estimatedCalories;

  const _ExitWorkoutDialogContent({
    required this.completedExercises,
    required this.totalExercises,
    required this.elapsedSeconds,
    required this.estimatedCalories,
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
    
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppBorderRadius.xxl),
                    topRight: Radius.circular(AppBorderRadius.xxl),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dừng luyện tập?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Body
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  children: [
                    const Text(
                      'Bạn có chắc muốn thoát không? Tiến trình tập luyện hiện tại sẽ không được lưu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniStat(
                          icon: Icons.fitness_center_rounded,
                          label: 'Đã tập',
                          value: '$completedExercises/$totalExercises',
                        ),
                        _buildMiniStat(
                          icon: Icons.timer_rounded,
                          label: 'Thời gian',
                          value: _formatDuration(elapsedSeconds),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.grey, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                              ),
                            ),
                            child: const Text(
                              'Tiếp tục',
                              style: TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                              ),
                            ),
                            child: const Text(
                              'Thoát',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.danger.withValues(alpha: 0.7), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
