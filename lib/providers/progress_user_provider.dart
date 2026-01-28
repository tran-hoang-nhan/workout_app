import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/progress_user_repository.dart';
import '../models/progress_user.dart';
import './auth_provider.dart';
import '../utils/app_error.dart';

final progressUserControllerProvider =
    AsyncNotifierProvider<ProgressUserController, void>(() {
      return ProgressUserController();
    });

class ProgressUserController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateWater(int deltaMl) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) throw UnauthorizedException('Chưa đăng nhập');

      final repo = ref.read(progressUserRepositoryProvider);
      final rawNow = DateTime.now();
      final now = DateTime(rawNow.year, rawNow.month, rawNow.day);

      // Update with ml and glasses
      final deltaGlasses = (deltaMl / 250).round();

      await repo.updateActivityProgress(
        userId: userId,
        date: now,
        addWaterMl: deltaMl,
        addWaterGlasses: deltaGlasses,
      );

      ref.invalidate(progressDailyProvider(now));
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> updateSteps(int deltaSteps) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) throw UnauthorizedException('Chưa đăng nhập');

      final repo = ref.read(progressUserRepositoryProvider);
      final rawNow = DateTime.now();
      final now = DateTime(rawNow.year, rawNow.month, rawNow.day);

      await repo.updateActivityProgress(
        userId: userId,
        date: now,
        addSteps: deltaSteps,
      );

      ref.invalidate(progressDailyProvider(now));
    });

    if (state.hasError) throw state.error!;
  }
}

final progressUserRepositoryProvider = Provider<ProgressUserRepository>((ref) {
  return ProgressUserRepository();
});

final progressDailyProvider = FutureProvider.family<ProgressUser?, DateTime>((
  ref,
  rawDate,
) async {
  final date = DateTime(rawDate.year, rawDate.month, rawDate.day);
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
