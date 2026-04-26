import 'package:shared/shared.dart';
import '../repositories/health_repository.dart';
import '../repositories/daily_stats_repository.dart';
import '../services/notification_service.dart';

class HealthService {
  final HealthRepository _healthRepo;
  final DailyStatsRepository _dailyStatsRepo;
  final NotificationService? _notifications;

  HealthService({HealthRepository? healthRepo,DailyStatsRepository? dailyStatsRepo,NotificationService? notifications}) 
  : _healthRepo = healthRepo ?? HealthRepository(),_dailyStatsRepo = dailyStatsRepo ?? DailyStatsRepository(),_notifications = notifications;

  Future<HealthData?> getHealthData(String userId) async {
    return _healthRepo.getHealthData(userId);
  }

  Future<void> updateFullProfile(HealthUpdateParams params) async {
    await _healthRepo.updateFullProfile(params);
  }

  Future<DailyStats?> getTodayStats(String userId) async {
    return _dailyStatsRepo.getDailyStats(userId, DateTime.now());
  }

  Future<HealthData?> checkHealthProfile(String userId) => getHealthData(userId);

  Future<void> syncWaterReminders({required bool enabled, required int intervalHours, required String? wakeTime, required String? sleepTime, required int currentWaterMl, required int goalWaterMl,}) async {
    if (_notifications == null) return;
    await _notifications.cancelAllWaterReminders();
    if (!enabled) return;
    if (goalWaterMl > 0 && currentWaterMl >= goalWaterMl) return;

    final safeInterval = intervalHours > 0 ? intervalHours : 2;
    final normalizedWakeTime = _normalizeTimeOrDefault(wakeTime, '07:00');
    final normalizedSleepTime = _normalizeTimeOrDefault(sleepTime, '23:00');

    await _notifications.scheduleWaterReminder(
      intervalHours: safeInterval,
      wakeTime: normalizedWakeTime,
      sleepTime: normalizedSleepTime,
    );
  }

  String _normalizeTimeOrDefault(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;

    final parsed = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$',).firstMatch(value.trim());
    if (parsed == null) return fallback;

    final hour = int.parse(parsed.group(1)!);
    final minute = int.parse(parsed.group(2)!);
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> updateQuickMetrics({required String userId, double? weight, double? height,}) async {
    await _healthRepo.updateQuickMetrics(
      userId: userId,
      weight: weight,
      height: height,
    );
  }

  Future<void> cancelAllWaterReminders() async {
    if (_notifications != null) {
      await _notifications.cancelAllWaterReminders();
    }
  }

  double calculateBMI(double weight, double height) => HealthUtils.calculateBMI(weight, height);
  String getBMICategory(double bmi) => HealthUtils.getBMICategory(bmi);
  int calculateBMR(double weight, double height, int age, String gender) => HealthUtils.calculateBMR(weight, height, age, gender);
  int calculateTDEE(int bmr, String activityLevel) => HealthUtils.calculateTDEE(bmr, activityLevel);
  int calculateMaxHeartRate(int age) => HealthUtils.calculateMaxHeartRate(age);
  ({int min, int max}) calculateZone1(int maxHR) => HealthUtils.calculateZone1(maxHR);
  ({int min, int max}) calculateZone2(int maxHR) => HealthUtils.calculateZone2(maxHR);
  ({int min, int max}) calculateZone3(int maxHR) => HealthUtils.calculateZone3(maxHR);
  ({int min, int max}) calculateZone4(int maxHR) => HealthUtils.calculateZone4(maxHR);
  ({int min, int max}) calculateZone5(int maxHR) => HealthUtils.calculateZone5(maxHR);
}
