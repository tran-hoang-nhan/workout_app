import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../repositories/health_repository.dart';
import '../services/health_service.dart';
import '../models/health_data.dart';
import '../models/health_params.dart';
import '../utils/app_error.dart';
import './auth_provider.dart';
import './profile_provider.dart';
import '../services/health_integration_service.dart';
import '../services/notification_service.dart';

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
  
  // Sync water reminder on startup
  try {
    final userId = await ref.watch(currentUserIdProvider.future);
    if (userId != null) {
      debugPrint("🔄 Syncing water reminders on app launch for user: $userId");
      final healthService = ref.read(healthServiceProvider);
      // Use the repo directly or service to avoid circular dependency if any, 
      // but service is already available via provider.
      final healthData = await healthService.checkHealthProfile(userId);
      
      if (healthData != null) {
        debugPrint("📊 Health data found. Reminder enabled: ${healthData.waterReminderEnabled}, Interval: ${healthData.waterReminderInterval}");
        await healthService.syncWaterReminders(
          healthData.waterReminderEnabled,
          healthData.waterReminderInterval,
          healthData.wakeTime,
          healthData.sleepTime,
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
  return HealthService(
    repository: repo,
    healthIntegration: healthIntegration,
    notifications: notifications,
  );
});

final healthDataProvider = FutureProvider<HealthData?>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return null;
  final service = ref.watch(healthServiceProvider);
  return service.checkHealthProfile(userId);
});

// 1. HealthFormState
class HealthFormState {
  final int age;
  final double weight;
  final double height;
  final String gender;
  final List<String> injuries;
  final List<String> medicalConditions;
  final String activityLevel;
  final double waterIntake;
  final String dietType;
  final List<String> allergies;
  final bool waterReminderEnabled;
  final int waterReminderInterval;
  final String wakeTime;
  final String sleepTime;

  HealthFormState({
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.injuries,
    required this.medicalConditions,
    required this.activityLevel,
    required this.waterIntake,
    required this.dietType,
    required this.allergies,
    required this.waterReminderEnabled,
    required this.waterReminderInterval,
    required this.wakeTime,
    required this.sleepTime,
  });

  factory HealthFormState.initial() {
    return HealthFormState(
      age: 25,
      weight: 70,
      height: 170,
      gender: 'male',
      injuries: [],
      medicalConditions: [],
      activityLevel: 'moderately_active',
      waterIntake: 2000,
      dietType: 'normal',
      allergies: [],
      waterReminderEnabled: false,
      waterReminderInterval: 2,
      wakeTime: '07:00',
      sleepTime: '23:00',
    );
  }

  HealthFormState copyWith({
    int? age,
    double? weight,
    double? height,
    String? gender,
    List<String>? injuries,
    List<String>? medicalConditions,
    String? activityLevel,
    double? waterIntake,
    String? dietType,
    List<String>? allergies,
    bool? waterReminderEnabled,
    int? waterReminderInterval,
    String? wakeTime,
    String? sleepTime,
  }) {
    return HealthFormState(
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      injuries: injuries ?? List.from(this.injuries),
      medicalConditions: medicalConditions ?? List.from(this.medicalConditions),
      activityLevel: activityLevel ?? this.activityLevel,
      waterIntake: waterIntake ?? this.waterIntake,
      dietType: dietType ?? this.dietType,
      allergies: allergies ?? List.from(this.allergies),
      waterReminderEnabled: waterReminderEnabled ?? this.waterReminderEnabled,
      waterReminderInterval:
          waterReminderInterval ?? this.waterReminderInterval,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
    );
  }
}

class HealthFormNotifier extends Notifier<HealthFormState> {
  @override
  HealthFormState build() {
    return HealthFormState.initial();
  }

  void setAge(int age) => state = state.copyWith(age: age);
  void setWeight(double weight) => state = state.copyWith(weight: weight);
  void setHeight(double height) => state = state.copyWith(height: height);
  void setGender(String gender) => state = state.copyWith(gender: gender);
  void setWaterReminderEnabled(bool enabled) =>
      state = state.copyWith(waterReminderEnabled: enabled);
  void setWaterReminderInterval(int interval) =>
      state = state.copyWith(waterReminderInterval: interval);
  void setWakeTime(String time) => state = state.copyWith(wakeTime: time);
  void setSleepTime(String time) => state = state.copyWith(sleepTime: time);

  void addInjury(String injury) {
    if (!state.injuries.contains(injury)) {
      state = state.copyWith(injuries: [...state.injuries, injury]);
    }
  }

  void removeInjury(int index) {
    final list = List<String>.from(state.injuries);
    list.removeAt(index);
    state = state.copyWith(injuries: list);
  }

  void addCondition(String condition) {
    if (!state.medicalConditions.contains(condition)) {
      state = state.copyWith(
        medicalConditions: [...state.medicalConditions, condition],
      );
    }
  }

  void removeCondition(int index) {
    final list = List<String>.from(state.medicalConditions);
    list.removeAt(index);
    state = state.copyWith(medicalConditions: list);
  }

  void setActivityLevel(String level) =>
      state = state.copyWith(activityLevel: level);
  void setWaterIntake(double ml) => state = state.copyWith(waterIntake: ml);
  void setDietType(String type) => state = state.copyWith(dietType: type);

  void addAllergy(String allergy) {
    if (!state.allergies.contains(allergy)) {
      state = state.copyWith(allergies: [...state.allergies, allergy]);
    }
  }

  void removeAllergy(int index) {
    final list = List<String>.from(state.allergies);
    list.removeAt(index);
    state = state.copyWith(allergies: list);
  }

  void updateFromHealthData(HealthData data) {
    state = HealthFormState(
      age: data.age,
      weight: data.weight,
      height: data.height ?? state.height,
      gender: data.gender ?? state.gender,
      injuries: data.injuries,
      medicalConditions: data.medicalConditions,
      activityLevel: data.activityLevel,
      waterIntake: data.waterIntake.toDouble(),
      dietType: data.dietType,
      allergies: data.allergies,
      waterReminderEnabled: data.waterReminderEnabled,
      waterReminderInterval: data.waterReminderInterval,
      wakeTime: data.wakeTime,
      sleepTime: data.sleepTime,
    );
  }

  Future<void> saveHealthOnboarding({
    required String userId,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
    required String goal,
    required String dietType,
    required int waterIntake,
    required String injuries,
    required String medicalConditions,
    required String allergies,
    bool waterReminderEnabled = false,
    int waterReminderInterval = 2,
  }) async {
    final activityKey = _mapActivityLevel(activityLevel);
    final goalKey = _mapGoal(goal);
    final injuriesList = injuries
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final conditionsList = medicalConditions
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final allergiesList = allergies
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final params = HealthUpdateParams(
      userId: userId,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      activityLevel: activityKey,
      goal: goalKey,
      dietType: dietType,
      waterIntake: waterIntake,
      injuries: injuriesList,
      medicalConditions: conditionsList,
      allergies: allergiesList,
      waterReminderEnabled: waterReminderEnabled,
      waterReminderInterval: waterReminderInterval,
      wakeTime: state.wakeTime,
      sleepTime: state.sleepTime,
    );
    await ref.read(healthControllerProvider.notifier).saveFullProfile(params);
    state = state.copyWith(
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      activityLevel: activityKey,
      dietType: dietType,
      waterIntake: waterIntake.toDouble(),
      injuries: injuriesList,
      medicalConditions: conditionsList,
      allergies: allergiesList,
      waterReminderEnabled: waterReminderEnabled,
      waterReminderInterval: waterReminderInterval,
      wakeTime: state.wakeTime,
      sleepTime: state.sleepTime,
    );
  }

  String _mapActivityLevel(String label) {
    if (label.contains('Ít')) return 'sedentary';
    if (label.contains('Nhẹ')) return 'lightly_active';
    if (label.contains('Trung')) return 'moderately_active';
    if (label.contains('Rất')) return 'very_active';
    return 'sedentary';
  }

  String _mapGoal(String label) {
    if (label.contains('Giảm')) return 'lose';
    if (label.contains('Duy')) return 'maintain';
    if (label.contains('Tăng')) return 'gain';
    return 'maintain';
  }
}

final healthFormProvider =
    NotifierProvider<HealthFormNotifier, HealthFormState>(
      HealthFormNotifier.new,
    );
final healthControllerProvider = AsyncNotifierProvider<HealthController, void>(
  () {
    return HealthController();
  },
);

class HealthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveFullProfile(HealthUpdateParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final service = ref.read(healthServiceProvider);
        await service.updateFullProfile(params);
        ref.invalidate(healthDataProvider);
      } catch (e, st) {
        final handled = handleException(e, st);
        throw handled; // Re-throw to ensure caller can catch it
      }
    });
    // Check if state is error and rethrow if so, because guard wraps it
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> saveQuickMetrics({
    double? weight,
    double? height,
    String? gender,
    String? goal,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final userId = await ref.read(currentUserIdProvider.future);
        if (userId == null) throw UnauthorizedException('Chưa đăng nhập');

        final service = ref.read(healthServiceProvider);
        await service.updateQuickMetrics(
          userId: userId,
          weight: weight,
          height: height,
          gender: gender,
          goal: goal,
        );
        ref.invalidate(healthDataProvider);
      } catch (e, st) {
        throw handleException(e, st);
      }
    });
    if (state.hasError) {
      throw state.error!;
    }
  }
}

final syncHealthProfileProvider = FutureProvider<void>((ref) async {
  final healthData = await ref.watch(healthDataProvider.future);
  if (healthData != null) {
    ref.read(healthFormProvider.notifier).updateFromHealthData(healthData);
  }
});

class HealthCalculations {
  final double bmi;
  final String bmiCategory;
  final int bmr;
  final int tdee;
  final int maxHeartRate;
  final ({int min, int max}) zone1;
  final ({int min, int max}) zone2;
  final ({int min, int max}) zone3;
  final ({int min, int max}) zone4;
  final ({int min, int max}) zone5;

  HealthCalculations({
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.tdee,
    required this.maxHeartRate,
    required this.zone1,
    required this.zone2,
    required this.zone3,
    required this.zone4,
    required this.zone5,
  });

  factory HealthCalculations.empty() {
    return HealthCalculations(
      bmi: 0,
      bmiCategory: 'N/A',
      bmr: 0,
      tdee: 0,
      maxHeartRate: 0,
      zone1: (min: 0, max: 0),
      zone2: (min: 0, max: 0),
      zone3: (min: 0, max: 0),
      zone4: (min: 0, max: 0),
      zone5: (min: 0, max: 0),
    );
  }
}

final healthCalculationsProvider = Provider<HealthCalculations>((ref) {
  final form = ref.watch(healthFormProvider);
  final service = ref.watch(healthServiceProvider);
  final bmi = service.calculateBMI(form.weight, form.height);
  final bmiCategory = service.getBMICategory(bmi);
  final bmr = service.calculateBMR(
    form.weight,
    form.height,
    form.age,
    form.gender,
  );
  final tdee = service.calculateTDEE(bmr, form.activityLevel);
  final maxHR = service.calculateMaxHeartRate(form.age);
  final zone1 = service.calculateZone1(maxHR);
  final zone2 = service.calculateZone2(maxHR);
  final zone3 = service.calculateZone3(maxHR);
  final zone4 = service.calculateZone4(maxHR);
  final zone5 = service.calculateZone5(maxHR);

  return HealthCalculations(
    bmi: bmi,
    bmiCategory: bmiCategory,
    bmr: bmr,
    tdee: tdee,
    maxHeartRate: maxHR,
    zone1: zone1,
    zone2: zone2,
    zone3: zone3,
    zone4: zone4,
    zone5: zone5,
  );
});

final hasHealthDataProvider = FutureProvider<bool>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return false;
  final service = ref.watch(healthServiceProvider);
  final data = await service.checkHealthProfile(userId);
  return data != null;
});

class HealthProfileSaveParams {
  final double height;
  final String? gender;
  HealthProfileSaveParams({required this.height, this.gender});
}

final saveHealthProfileProvider =
    FutureProvider.family<void, HealthProfileSaveParams>((ref, params) async {
      try {
        final userId = await ref.read(currentUserIdProvider.future);
        if (userId == null) {
          throw UnauthorizedException('Chưa đăng nhập');
        }

        // Get current user profile to preserve goal
        final currentUser = await ref.read(fullUserProfileProvider.future);
        final currentGoal = currentUser?.goal ?? 'maintain';

        final form = ref.read(healthFormProvider);
        final updateParams = HealthUpdateParams(
          userId: userId,
          age: form.age,
          weight: form.weight,
          height: params.height,
          gender: params.gender ?? form.gender,
          activityLevel: form.activityLevel,
          goal: currentGoal,
          dietType: form.dietType,
          waterIntake: form.waterIntake.toInt(),
          injuries: form.injuries,
          medicalConditions: form.medicalConditions,
          allergies: form.allergies,
          waterReminderEnabled: form.waterReminderEnabled,
          waterReminderInterval: form.waterReminderInterval,
          wakeTime: form.wakeTime,
          sleepTime: form.sleepTime,
        );
        await ref
            .read(healthControllerProvider.notifier)
            .saveFullProfile(updateParams);
      } catch (e, st) {
        throw handleException(e, st);
      }
    });

final bmiProvider = Provider<double>((ref) {
  final calculations = ref.watch(healthCalculationsProvider);
  return calculations.bmi;
});
