import '../repositories/health_repository.dart';
import '../models/health_data.dart';
import '../models/health_params.dart';
import '../utils/health_utils.dart' as health_utils;
import './health_integration_service.dart';
import './notification_service.dart';

class HealthService {
  final HealthRepository _repository;
  final HealthIntegrationService _healthIntegration;
  final NotificationService _notifications;

  HealthService({
    HealthRepository? repository,
    HealthIntegrationService? healthIntegration,
    NotificationService? notifications,
  }) : _repository = repository ?? HealthRepository(),
       _healthIntegration = healthIntegration ?? HealthIntegrationService(),
       _notifications = notifications ?? NotificationService();

  Future<HealthData?> checkHealthProfile(String userId) async {
    final profile = await _repository.getHealthData(userId);
    if (profile == null) return null;
    final steps = await _healthIntegration.getTodaySteps();
    return HealthData(
      userId: profile.userId,
      age: profile.age,
      weight: profile.weight,
      height: profile.height,
      injuries: profile.injuries,
      medicalConditions: profile.medicalConditions,
      activityLevel: profile.activityLevel,
      sleepHours: profile.sleepHours,
      waterIntake: profile.waterIntake,
      dietType: profile.dietType,
      allergies: profile.allergies,
      gender: profile.gender,
      steps: steps,
      waterReminderEnabled: profile.waterReminderEnabled,
      waterReminderInterval: profile.waterReminderInterval,
    );
  }

  Future<void> syncWaterReminders(bool enabled, int intervalHours) async {
    if (enabled) {
      await _notifications.scheduleWaterReminder(intervalHours: intervalHours);
    } else {
      await _notifications.cancelAllReminders();
    }
  }

  Future<void> updateQuickMetrics({
    required String userId,
    double? weight,
    double? height,
    String? gender,
    String? goal,
  }) async {
    await _repository.updateQuickMetrics(
      userId: userId,
      weight: weight,
      height: height,
    );
  }

  Future<void> updateFullProfile(HealthUpdateParams params) async {
    await _repository.updateFullProfile(params);
    if (params.waterReminderEnabled != null &&
        params.waterReminderInterval != null) {
      await syncWaterReminders(
        params.waterReminderEnabled!,
        params.waterReminderInterval!,
      );
    }
  }

  double calculateBMI(double weight, double height) =>
      health_utils.calculateBMI(weight, height);
  String getBMICategory(double bmi) => health_utils.getBMICategory(bmi);
  int calculateBMR(double weight, double height, int age, String gender) =>
      health_utils.calculateBMR(weight, height, age, gender);
  int calculateTDEE(int bmr, String activityLevel) =>
      health_utils.calculateTDEE(bmr, activityLevel);
  int calculateMaxHeartRate(int age) => health_utils.calculateMaxHeartRate(age);
  ({int min, int max}) calculateZone1(int maxHR) =>
      health_utils.calculateZone1(maxHR);
  ({int min, int max}) calculateZone2(int maxHR) =>
      health_utils.calculateZone2(maxHR);
  ({int min, int max}) calculateZone3(int maxHR) =>
      health_utils.calculateZone3(maxHR);
  ({int min, int max}) calculateZone4(int maxHR) =>
      health_utils.calculateZone4(maxHR);
  ({int min, int max}) calculateZone5(int maxHR) =>
      health_utils.calculateZone5(maxHR);
}
