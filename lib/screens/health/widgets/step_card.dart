import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';

class StepCard extends ConsumerWidget {
  final int steps;
  final double height;
  static const int stepsGoal = 10000;

  const StepCard({
    super.key,
    required this.steps,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = (steps / stepsGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildIconBox(Icons.directions_walk, AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'Bước chân',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.orange.shade50,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  steps.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Mục tiêu: $stepsGoal',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.grey.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.03),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
