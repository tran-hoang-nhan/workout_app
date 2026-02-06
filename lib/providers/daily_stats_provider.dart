import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/daily_stats_repository.dart';
import '../models/daily_stats.dart';
import './auth_provider.dart';

final dailyStatsRepositoryProvider = Provider<DailyStatsRepository>((ref) {
  return DailyStatsRepository();
});

final dailyStatsProvider = FutureProvider.family<DailyStats?, DateTime>((ref, rawDate) async {
  final date = DateTime(rawDate.year, rawDate.month, rawDate.day);
  final userId = ref.watch(currentUserIdProvider).value;
  if (userId == null) return null;
  final repo = ref.watch(dailyStatsRepositoryProvider);
  return await repo.getDailyStats(userId, date);
});

final weeklyStatsProvider = FutureProvider<List<DailyStats>>((ref) async {
  final userId = ref.watch(currentUserIdProvider).value;
  if (userId == null) return [];
  final repo = ref.watch(dailyStatsRepositoryProvider);
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  return await repo.getStatsRange(userId, startOfWeek, endOfWeek);
});

final monthStatsProvider = FutureProvider.family<List<DailyStats>, DateTime>((
  ref,
  month,
) async {
  final userId = ref.watch(currentUserIdProvider).value;
  if (userId == null) return [];
  final repo = ref.watch(dailyStatsRepositoryProvider);
  final startOfMonth = DateTime(month.year, month.month, 1);
  final endOfMonth = DateTime(month.year, month.month + 1, 0);
  return await repo.getStatsRange(userId, startOfMonth, endOfMonth);
});
