import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../repositories/daily_stats_repository.dart';
import './auth_provider.dart';

final dailyStatsRepositoryProvider = Provider<DailyStatsRepository>((ref) {
  return DailyStatsRepository();
});

final dailyStatsProvider = FutureProvider.family<DailyStats?, DateTime>((ref, rawDate,) async {
  final date = DateTime(rawDate.year, rawDate.month, rawDate.day);
  final userId = ref.watch(currentUserIdProvider).value;
  if (userId == null) return null;
  final repo = ref.watch(dailyStatsRepositoryProvider);
  return await repo.getDailyStats(userId, date);
});
