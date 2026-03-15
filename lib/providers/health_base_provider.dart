import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/health_repository.dart';
import '../services/health_service.dart';
import '../services/health_integration_service.dart';
import '../services/notification_service.dart';
import '../models/health_data.dart';
import './auth_provider.dart';
import './progress_user_provider.dart';
import './daily_stats_provider.dart';
import './weight_provider.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository();
});

final healthIntegrationServiceProvider = Provider<HealthIntegrationService>((
  ref,
) {
  return HealthIntegrationService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final initializeNotificationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  await service.init();

  try {
    final userId = await ref.watch(currentUserIdProvider.future);
    if (userId != null) {
      debugPrint("🔄 Syncing water reminders on app launch for user: $userId");
      final healthData = await ref.read(healthDataProvider.future);

      if (healthData != null) {
        final healthService = ref.read(healthServiceProvider);
        final now = DateTime.now();
        final progress = await ref.read(progressDailyProvider(now).future);
        final currentWaterMl = progress?.waterMl ?? 0;

        debugPrint(
          "📊 Health data found. Goal: ${healthData.waterIntake}ml, Current: ${currentWaterMl}ml",
        );
        await healthService.syncWaterReminders(
          enabled: healthData.waterReminderEnabled,
          intervalHours: healthData.waterReminderInterval,
          wakeTime: healthData.wakeTime,
          sleepTime: healthData.sleepTime,
          currentWaterMl: currentWaterMl,
          goalWaterMl: healthData.waterIntake,
        );
      } else {
        debugPrint("⚠️ No health data found for user.");
      }
    }
  } catch (e) {
    debugPrint("❌ Error syncing notifications on launch: $e");
  }
});

final healthServiceProvider = Provider<HealthService>((ref) {
  final repo = ref.watch(healthRepositoryProvider);
  final healthIntegration = ref.watch(healthIntegrationServiceProvider);
  final notifications = ref.watch(notificationServiceProvider);
  final dailyStatsRepo = ref.watch(dailyStatsRepositoryProvider);
  final weightRepo = ref.watch(weightRepositoryProvider);
  return HealthService(
    repository: repo,
    healthIntegration: healthIntegration,
    notifications: notifications,
    dailyStatsRepository: dailyStatsRepo,
    weightRepository: weightRepo,
  );
});

final healthDataProvider = FutureProvider<HealthData?>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return null;
  final service = ref.watch(healthServiceProvider);
  return service.checkHealthProfile(userId);
});
