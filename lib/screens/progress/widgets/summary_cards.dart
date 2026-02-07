import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../models/progress_user.dart';
import '../../../utils/app_error.dart';
import '../../../widgets/loading_animation.dart';

class ProgressSummaryCards extends StatelessWidget {
  final AsyncValue<ProgressUser?> statsAsync;

  const ProgressSummaryCards({
    super.key,
    required this.statsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: statsAsync.when(
          data: (stats) => GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.3,
            children: [
              _buildStatSquare(
                'Calo',
                '${stats?.totalCaloriesBurned.toInt() ?? 0}',
                'calo',
                Icons.local_fire_department,
                AppColors.primary,
              ),
              _buildStatSquare(
                'Tập luyện',
                '${(stats?.totalDurationSeconds ?? 0) ~/ 60}',
                'phút',
                Icons.timer,
                AppColors.info,
              ),
              _buildStatSquare(
                'Bước chân',
                '${stats?.steps ?? 0}',
                'bước',
                Icons.directions_walk,
                Colors.orange,
              ),
              _buildStatSquare(
                'Nước uống',
                '${stats?.waterMl ?? 0}',
                'ml',
                Icons.local_drink,
                Colors.blue,
              ),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: AppLoading(size: 40),
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              e is AppError ? e.userMessage : 'Lỗi: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatSquare(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
