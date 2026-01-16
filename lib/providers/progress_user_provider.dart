import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/progress_user_repository.dart';
import '../models/progress_user.dart';
import './auth_provider.dart';

final progressUserRepositoryProvider = Provider<ProgressUserRepository>((ref) {
  return ProgressUserRepository();
});

final progressDailyProvider = FutureProvider.family<ProgressUser?, DateTime>((ref, date) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return null;
  final repo = ref.watch(progressUserRepositoryProvider);
  return await repo.getProgress(userId, date);
});

final progressWeeklyProvider = FutureProvider<List<ProgressUser>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return [];
  final repo = ref.watch(progressUserRepositoryProvider);
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  return await repo.getProgressRange(userId, startOfWeek, endOfWeek);
});