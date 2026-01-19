import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/heart_rate_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/daily_summary_provider.dart';
import './widgets/heart_rate_chart.dart';
import './widgets/heart_rate_header.dart';
import './widgets/heart_rate_stats_grid.dart';
import './widgets/heart_rate_time_in_zones.dart';

class HeartRateDetailScreen extends ConsumerWidget {
  const HeartRateDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heartRateDataAsync = ref.watch(heartRateDataProvider);
    final restingHRAsync = ref.watch(restingHeartRateProvider);
    final calculations = ref.watch(healthCalculationsProvider);
    final timeInZonesAsync = ref.watch(timeInZonesProvider(calculations.maxHeartRate));
    final dailySummaryAsync = ref.watch(dailySummaryProvider(DateTime.now()));

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'Chi tiết nhịp tim',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.black),
            onPressed: () => ref.refresh(syncDailySummaryProvider),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeartRateHeader(dataAsync: heartRateDataAsync),
            HeartRateChart(dataAsync: heartRateDataAsync),
            HeartRateStatsGrid(
              dataAsync: heartRateDataAsync,
              restingHRAsync: restingHRAsync,
              summaryAsync: dailySummaryAsync,
            ),
            HeartRateTimeInZones(
              zonesAsync: timeInZonesAsync,
              summaryAsync: dailySummaryAsync,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
