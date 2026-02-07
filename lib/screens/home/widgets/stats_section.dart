import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/daily_stats_provider.dart';
import '../../../providers/health_provider.dart';

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStatsAsync = ref.watch(dailyStatsProvider(today));
    final healthCalculations = ref.watch(healthCalculationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động hôm nay',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        todayStatsAsync.when(
          data: (stats) {
            final steps = stats?.stepsCount ?? 0;
            final calories = stats?.activeEnergyCalo ?? 0;
            final minutes = stats?.activeMinutes ?? 0;
            
            // Goals
            const stepGoal = 10000;
            final calorieGoal = (healthCalculations.tdee > 0 ? healthCalculations.tdee : 2000) * 1000;
            const minuteGoal = 60;

            return Column(
              children: [
                _buildProgressCard(
                  context,
                  title: 'Calo tiêu thụ',
                  value: calories.toStringAsFixed(0),
                  goal: calorieGoal.toStringAsFixed(0),
                  unit: 'calo',
                  progress: (calories / calorieGoal).clamp(0, 1),
                  color: const Color(0xFFFF7F00),
                  icon: Icons.local_fire_department_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleStatCard(
                        context,
                        title: 'Số bước',
                        value: steps.toString(),
                        unit: 'bước',
                        progress: (steps / stepGoal).clamp(0, 1),
                        color: const Color(0xFF3B82F6),
                        icon: Icons.directions_walk_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildSimpleStatCard(
                        context,
                        title: 'Tập luyện',
                        value: minutes.toString(),
                        unit: 'phút',
                        progress: (minutes / minuteGoal).clamp(0, 1),
                        color: const Color(0xFF10B981),
                        icon: Icons.timer_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (_, _) => _buildErrorState(),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context, {
    required String title,
    required String value,
    required String goal,
    required String unit,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        'Mục tiêu: $goal $unit',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.grey.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Text('Không thể tải dữ liệu'),
    );
  }
}

