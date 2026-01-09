import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../constants/app_constants.dart';
import '../../../models/daily_stats.dart';
import '../../../utils/app_error.dart';
import '../../../widgets/loading_animation.dart';

class WeeklyActivityChart extends StatelessWidget {
  final AsyncValue<List<DailyStats>> statsAsync;

  const WeeklyActivityChart({
    super.key,
    required this.statsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hoạt động hàng tuần',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.more_horiz, color: AppColors.grey),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 200,
              child: statsAsync.when(
                data: (stats) => BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 3000,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt() % 7],
                                style: const TextStyle(color: AppColors.grey, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (i) {
                      final dayStats = stats.where((s) => s.date.weekday == (i + 1)).toList();
                      final calories = dayStats.isNotEmpty ? dayStats.first.caloriesBurned.toDouble() : 0.0;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: calories,
                            color: AppColors.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 3000,
                              color: AppColors.primary.withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                loading: () => const Center(child: AppLoading(size: 40)),
                error: (e, _) => Center(
                  child: Text(
                    e is AppError ? e.userMessage : 'Lỗi: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
