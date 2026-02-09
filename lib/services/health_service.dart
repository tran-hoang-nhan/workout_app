import '../repositories/health_repository.dart';
import 'package:flutter/material.dart';
import '../models/health_data.dart';
import '../models/health_params.dart';
import '../utils/health_utils.dart' as health_utils;
import './health_integration_service.dart';
import './notification_service.dart';
import '../repositories/daily_stats_repository.dart';

class HealthService {
  final HealthRepository _repository;
  final HealthIntegrationService _healthIntegration;
  final NotificationService _notifications;
  final DailyStatsRepository _dailyStatsRepository;

  HealthService({HealthRepository? repository,  HealthIntegrationService? healthIntegration,  NotificationService? notifications,  DailyStatsRepository? dailyStatsRepository,}): 
    _repository = repository ?? HealthRepository(), 
    _healthIntegration = healthIntegration ?? HealthIntegrationService(), 
    _notifications = notifications ?? NotificationService(), 
    _dailyStatsRepository = dailyStatsRepository ?? DailyStatsRepository();

  Future<HealthData?> checkHealthProfile(String userId) async {
    final profile = await _repository.getHealthData(userId);
    if (profile == null) return null;
    final steps = await _healthIntegration.getTodaySteps();

    try {
      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);
      await _dailyStatsRepository.updateActivityStats(userId: userId, date: date, steps: steps);
    } catch (e) {
      debugPrint('Error syncing steps to Supabase: $e');
    }

    return HealthData(
      userId: profile.userId,
      age: profile.age,
      weight: profile.weight,
      height: profile.height,
      injuries: profile.injuries,
      medicalConditions: profile.medicalConditions,
      activityLevel: profile.activityLevel,
      waterIntake: profile.waterIntake,
      dietType: profile.dietType,
      allergies: profile.allergies,
      gender: profile.gender,
      steps: steps,
      waterReminderEnabled: profile.waterReminderEnabled,
      waterReminderInterval: profile.waterReminderInterval,
      wakeTime: profile.wakeTime,
      sleepTime: profile.sleepTime,
    );
  }

  Future<void> syncWaterReminders({required bool enabled, required int intervalHours, required String wakeTime, required String sleepTime, int currentWaterMl = 0, int goalWaterMl = 2000,}) async {
    bool isGoalReached = currentWaterMl >= goalWaterMl;
    debugPrint("🔔 Syncing water reminders: enabled=$enabled, goalReached=$isGoalReached ($currentWaterMl/$goalWaterMl)");
    if (enabled && !isGoalReached) {
      await _notifications.scheduleWaterReminder(intervalHours: intervalHours, wakeTime: wakeTime, sleepTime: sleepTime);
    } else {
      await _notifications.cancelAllReminders();
      if (enabled && isGoalReached) {
        debugPrint("🎯 Water goal reached. Reminders stopped.");
      }
    }
  }

  Future<void> updateQuickMetrics({required String userId, double? weight, double? height,}) async {
    await _repository.updateQuickMetrics(userId: userId, weight: weight, height: height);
  }

  Future<void> updateFullProfile(HealthUpdateParams params) async {
    await _repository.updateFullProfile(params);
    await syncWaterReminders(
      enabled: params.waterReminderEnabled,
      intervalHours: params.waterReminderInterval,
      wakeTime: params.wakeTime,
      sleepTime: params.sleepTime,
    );
  }

  double calculateBMI(double weight, double height) => health_utils.calculateBMI(weight, height);
  String getBMICategory(double bmi) => health_utils.getBMICategory(bmi);
  int calculateBMR(double weight, double height, int age, String gender) => health_utils.calculateBMR(weight, height, age, gender);
  int calculateTDEE(int bmr, String activityLevel) => health_utils.calculateTDEE(bmr, activityLevel);
  int calculateMaxHeartRate(int age) => health_utils.calculateMaxHeartRate(age);
  ({int min, int max}) calculateZone1(int maxHR) => health_utils.calculateZone1(maxHR);
  ({int min, int max}) calculateZone2(int maxHR) => health_utils.calculateZone2(maxHR);
  ({int min, int max}) calculateZone3(int maxHR) => health_utils.calculateZone3(maxHR);
  ({int min, int max}) calculateZone4(int maxHR) => health_utils.calculateZone4(maxHR);
  ({int min, int max}) calculateZone5(int maxHR) => health_utils.calculateZone5(maxHR);
}
