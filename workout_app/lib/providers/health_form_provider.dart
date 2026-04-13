import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'health_provider.dart';
import 'auth_provider.dart';

class HealthFormNotifier extends Notifier<HealthUpdateParams> {
  @override
  HealthUpdateParams build() {
    final userId = ref.watch(currentUserIdProvider).value ?? '';
    return HealthUpdateParams.initial(userId);
  }

  void setAge(int age) => state = state.copyWith(age: age);
  void setWeight(double weight) => state = state.copyWith(weight: weight);
  void setHeight(double height) => state = state.copyWith(height: height);
  void setGender(String gender) => state = state.copyWith(gender: gender);
  void setGoal(String goal) => state = state.copyWith(goal: goal);
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
  void setWaterIntake(double ml) =>
      state = state.copyWith(waterIntake: ml.toInt());
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
    state = HealthUpdateParams(
      userId: data.userId,
      age: data.age,
      weight: data.weight,
      height: data.height,
      gender: data.gender,
      goal: data.goal,
      injuries: data.injuries,
      medicalConditions: data.medicalConditions,
      activityLevel: data.activityLevel,
      waterIntake: data.waterIntake,
      dietType: data.dietType,
      allergies: data.allergies,
      waterReminderEnabled: data.waterReminderEnabled,
      waterReminderInterval: data.waterReminderInterval,
      wakeTime: data.wakeTime ?? state.wakeTime,
      sleepTime: data.sleepTime ?? state.sleepTime,
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
    state = params;
  }

  void updateAndSave(HealthUpdateParams params) {
    state = params;
    ref.read(healthControllerProvider.notifier).saveFullProfile(params);
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
    NotifierProvider<HealthFormNotifier, HealthUpdateParams>(
      HealthFormNotifier.new,
    );
