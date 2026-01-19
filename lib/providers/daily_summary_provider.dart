import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/daily_summary_repository.dart';
import '../models/daily_summary.dart';
import '../services/daily_summary_sync_service.dart';
import './auth_provider.dart';

final dailySummaryRepositoryProvider = Provider<DailySummaryRepository>((ref) {
  return DailySummaryRepository();
});

final dailySummarySyncServiceProvider = Provider<DailySummarySyncService>((ref) {
  return DailySummarySyncService();
});

final dailySummaryProvider = FutureProvider.family<DailySummary?, DateTime>((ref, date) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return null;
  final repo = ref.watch(dailySummaryRepositoryProvider);
  return await repo.getDailySummary(userId, date);
});

final syncDailySummaryProvider = FutureProvider<void>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return;
  final service = ref.watch(dailySummarySyncServiceProvider);
  await service.syncTodayData(userId);
  ref.invalidate(dailySummaryProvider);
});
