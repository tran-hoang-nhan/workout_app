import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/running_tracker_provider.dart';

class RunningCard extends ConsumerWidget {
  const RunningCard({super.key});

  String _formatDuration(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerState = ref.watch(runningTrackerProvider);
    final trackerNotifier = ref.read(runningTrackerProvider.notifier);
    final isTracking = trackerState.isTracking;

    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isTracking ? Colors.teal.shade50 : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: isTracking ? Border.all(color: Colors.teal.withValues(alpha: 0.3), width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: isTracking 
                ? Colors.teal.withValues(alpha: 0.1) 
                : Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isTracking ? Colors.teal : Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.directions_run, 
                    color: isTracking ? Colors.white : Colors.teal,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTracking ? 'Đang chạy bộ...' : 'Chạy bộ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        isTracking ? 'Duy trì tốc độ nhé!' : 'Theo dõi quãng đường di chuyển',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isTracking)
                  _buildMetricColumn(
                    'Thời gian',
                    _formatDuration(trackerState.secondsElapsed),
                    '',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  'Quãng đường',
                  (trackerState.totalDistance / 1000).toStringAsFixed(2),
                  'km',
                ),
                _buildMetricColumn(
                  'Số bước',
                   trackerNotifier.stepsCount.toString(),
                  trackerState.pedometerAvailable && trackerState.currentSessionSteps > 0 ? 'bước' : 'bước (ước tính)',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => trackerNotifier.toggleTracking(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTracking ? Colors.red : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isTracking ? Icons.stop_circle : Icons.play_circle_filled),
                    const SizedBox(width: 8),
                    Text(
                      isTracking ? 'Kết thúc chạy bộ' : 'Bắt đầu chạy bộ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}