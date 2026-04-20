import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../repositories/health_repository.dart';
import '../services/health_service.dart';
import '../services/notification_service.dart';
import './auth_provider.dart';
import './daily_stats_provider.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});



final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final initializeNotificationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  await service.init();
});

final healthServiceProvider = Provider<HealthService>((ref) {
  final repo = ref.watch(healthRepositoryProvider);
  final notifications = ref.watch(notificationServiceProvider);
  final dailyStatsRepo = ref.watch(dailyStatsRepositoryProvider);

  return HealthService(
    healthRepo: repo,
    dailyStatsRepo: dailyStatsRepo,
    notifications: notifications,
  );
});

final healthDataProvider = FutureProvider<HealthData?>((ref) async {
  debugPrint('[healthDataProvider] Initializing...');
  final userId = await ref.watch(currentUserIdProvider.future);
  debugPrint('[healthDataProvider] Awaited userId: $userId');
  if (userId == null) return null;
  final service = ref.watch(healthServiceProvider);
  debugPrint('[healthDataProvider] Calling API checkHealthProfile for user $userId');
  final result = await service.checkHealthProfile(userId);
  debugPrint('[healthDataProvider] checkHealthProfile result: ${result?.toJson()}');
  return result;
});
