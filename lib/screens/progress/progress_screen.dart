import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/progress_provider.dart';
import '../../providers/weight_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(progressStatsProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);
    final weightDataAsync = ref.watch(loadWeightDataProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tiến độ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Theo dõi hành trình fitness của bạn',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: statsAsync.when(
                  data: (stats) => Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: '${stats.totalCalories.toInt()}',
                        color: AppColors.primary,
                      )),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildStatCard(
                        icon: Icons.fitness_center,
                        label: 'Workouts',
                        value: '${stats.totalWorkouts}',
                        color: AppColors.info,
                      )),
                    ],
                  ),
                  loading: () => Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: '---',
                        color: AppColors.primary,
                      )),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildStatCard(
                        icon: Icons.fitness_center,
                        label: 'Workouts',
                        value: '---',
                        color: AppColors.info,
                      )),
                    ],
                  ),
                  error: (_, __) => Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        label: 'Calories',
                        value: '0',
                        color: AppColors.primary,
                      )),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: _buildStatCard(
                        icon: Icons.fitness_center,
                        label: 'Workouts',
                        value: '0',
                        color: AppColors.info,
                      )),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Weight Progress Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: weightDataAsync.when(
                  data: (data) => _buildWeightCard(data.weight, data.weightHistory.length),
                  loading: () => _buildWeightCard(0, 0),
                  error: (_, __) => _buildWeightCard(0, 0),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

            // Workout History
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: historyAsync.when(
                  data: (history) => _buildHistorySection(history.length),
                  loading: () => _buildHistorySection(0),
                  error: (_, __) => _buildHistorySection(0),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard(double currentWeight, int recordCount) {
    final hasData = recordCount > 0;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cân nặng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Icon(
                  hasData ? Icons.show_chart : Icons.scale,
                  size: 64,
                  color: hasData 
                    ? AppColors.success.withValues(alpha: 0.5)
                    : AppColors.grey.withValues(alpha: 0.3),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  hasData 
                    ? '$recordCount bản ghi cân nặng'
                    : 'Chưa có dữ liệu cân nặng',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(int historyCount) {
    final hasData = historyCount > 0;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử tập luyện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Icon(
                  hasData ? Icons.check_circle : Icons.history,
                  size: 64,
                  color: hasData
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.grey.withValues(alpha: 0.3),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  hasData
                    ? '$historyCount buổi tập'
                    : 'Chưa có lịch sử tập luyện',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
                if (!hasData) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Bắt đầu workout để theo dõi tiến độ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
