import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import '../../../constants/app_constants.dart';
import '../../../models/daily_summary.dart';
import './heart_rate_stat_card.dart';

class HeartRateStatsGrid extends StatelessWidget {
  final AsyncValue<List<HealthDataPoint>> dataAsync;
  final AsyncValue<double?> restingHRAsync;
  final AsyncValue<DailySummary?> summaryAsync;

  const HeartRateStatsGrid({
    super.key,
    required this.dataAsync,
    required this.restingHRAsync,
    required this.summaryAsync,
  });

  @override
  Widget build(BuildContext context) {
    return dataAsync.when(
      data: (data) {
        int min = 0;
        int max = 0;
        int avg = 0;
        int? resting;

        if (data.isNotEmpty) {
          final values = data.map((e) => double.tryParse(e.value.toString()) ?? 0).toList();
          min = values.reduce((a, b) => a < b ? a : b).toInt();
          max = values.reduce((a, b) => a > b ? a : b).toInt();
          avg = (values.reduce((a, b) => a + b) / values.length).toInt();
        } else {
          final summary = summaryAsync.value;
          if (summary != null) {
            min = summary.minHeartRate ?? 0;
            max = summary.maxHeartRate ?? 0;
            avg = summary.avgHeartRate ?? 0;
            resting = summary.restingHeartRate;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thống kê sức khỏe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  HeartRateStatCard(title: 'Thấp nhất', value: '$min bpm', icon: Icons.trending_down, color: Colors.blue),
                  HeartRateStatCard(title: 'Cao nhất', value: '$max bpm', icon: Icons.trending_up, color: Colors.red),
                  HeartRateStatCard(title: 'Trung bình', value: '$avg bpm', icon: Icons.analytics_outlined, color: Colors.orange),
                  restingHRAsync.when(
                    data: (rhr) {
                      final val = rhr?.toInt() ?? resting;
                      return HeartRateStatCard(title: 'Nhịp tim nghỉ', value: '${val ?? "--"} bpm', icon: Icons.favorite_border, color: Colors.purple);
                    },
                    loading: () => const HeartRateStatCard(title: 'Nhịp tim nghỉ', value: '...', icon: Icons.favorite_border, color: Colors.purple),
                    error: (_, _) => HeartRateStatCard(title: 'Nhịp tim nghỉ', value: '${resting ?? "N/A"} bpm', icon: Icons.favorite_border, color: Colors.purple),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
