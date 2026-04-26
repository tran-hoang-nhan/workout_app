import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'daily_stats_provider.dart';
import 'progress_provider.dart';
import 'health_stats_provider.dart';

typedef StatsUIData = ({
  AsyncValue<DailyStats?> dailyStats,
  AsyncValue<({double calories, int minutes})> workoutStats,
  HealthCalculations healthCalculations,
  bool isToday,
  DateTime effectiveDate,
});

final statsSectionDataProvider = Provider.family<StatsUIData, DateTime?>((ref, date) {
  final now = DateTime.now();
  final effectiveDate = date != null ? DateTime(date.year, date.month, date.day): DateTime(now.year, now.month, now.day);
  final dailyStats = ref.watch(dailyStatsProvider(effectiveDate));
  final workoutStats = ref.watch(dailyWorkoutStatsProvider(effectiveDate));
  final healthCalculations = ref.watch(healthCalculationsProvider);
  final isToday = effectiveDate.year == now.year && effectiveDate.month == now.month && effectiveDate.day == now.day;
                  
  return (
    dailyStats: dailyStats,
    workoutStats: workoutStats,
    healthCalculations: healthCalculations,
    isToday: isToday,
    effectiveDate: effectiveDate,
  );
});
