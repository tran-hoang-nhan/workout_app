import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/health_service.dart';

// Providers for health data
final healthServiceProvider = Provider((ref) => HealthService());

// Check if user has health data
final hasHealthDataProvider = FutureProvider<bool>((ref) async {
  try {
    // Wait a bit for Supabase auth to initialize
    await Future.delayed(const Duration(milliseconds: 200));
    
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session?.user.id;
    
    debugPrint('[hasHealthDataProvider] ========== CHECK START ==========');
    debugPrint('[hasHealthDataProvider] Session exists: ${session != null}');
    debugPrint('[hasHealthDataProvider] UserId: $userId');
    
    if (userId == null) {
      debugPrint('[hasHealthDataProvider] No userId, returning false');
      debugPrint('[hasHealthDataProvider] ========== CHECK END (no user) ==========');
      return false;
    }

    // Query health table with user_id column
    final response = await Supabase.instance.client
        .from('health')
        .select('user_id, age, weight')
        .eq('user_id', userId);

    debugPrint('[hasHealthDataProvider] Query executed');
    debugPrint('[hasHealthDataProvider] Response type: ${response.runtimeType}');
    debugPrint('[hasHealthDataProvider] Response: $response');
    debugPrint('[hasHealthDataProvider] Response isEmpty: ${response.isEmpty}');
    debugPrint('[hasHealthDataProvider] Response length: ${response.length}');
    
    final hasData = response.isNotEmpty;
    debugPrint('[hasHealthDataProvider] Final result - Has health data: $hasData');
    debugPrint('[hasHealthDataProvider] ========== CHECK END ==========');
    return hasData;
  } catch (e, stackTrace) {
    debugPrint('[hasHealthDataProvider] ========== ERROR ==========');
    debugPrint('[hasHealthDataProvider] Error: $e');
    debugPrint('[hasHealthDataProvider] StackTrace: $stackTrace');
    return false;
  }
});

// State notifier for form state management
class HealthFormNotifier extends StateNotifier<HealthFormState> {
  HealthFormNotifier()
      : super(
          HealthFormState(
            age: 28,
            weight: 68,
            height: 175,
            gender: 'male',
            activityLevel: 'moderately_active',
            sleepHours: 7,
            waterIntake: 2000,
            dietType: 'normal',
            injuries: [],
            medicalConditions: [],
            allergies: [],
          ),
        );

  void setAge(int age) => state = state.copyWith(age: age);
  void setWeight(double weight) => state = state.copyWith(weight: weight);
  void setHeight(double height) => state = state.copyWith(height: height);
  void setGender(String gender) => state = state.copyWith(gender: gender);
  void setActivityLevel(String level) => state = state.copyWith(activityLevel: level);
  void setSleepHours(double hours) => state = state.copyWith(sleepHours: hours.toInt());
  void setWaterIntake(double intake) => state = state.copyWith(waterIntake: intake.toInt());
  void setDietType(String type) => state = state.copyWith(dietType: type);

  void addInjury(String injury) {
    if (injury.isNotEmpty && !state.injuries.contains(injury)) {
      state = state.copyWith(injuries: [...state.injuries, injury]);
    }
  }

  void removeInjury(int index) {
    final updated = [...state.injuries];
    updated.removeAt(index);
    state = state.copyWith(injuries: updated);
  }

  void addCondition(String condition) {
    if (condition.isNotEmpty && !state.medicalConditions.contains(condition)) {
      state = state.copyWith(medicalConditions: [...state.medicalConditions, condition]);
    }
  }

  void removeCondition(int index) {
    final updated = [...state.medicalConditions];
    updated.removeAt(index);
    state = state.copyWith(medicalConditions: updated);
  }

  void addAllergy(String allergy) {
    if (allergy.isNotEmpty && !state.allergies.contains(allergy)) {
      state = state.copyWith(allergies: [...state.allergies, allergy]);
    }
  }

  void removeAllergy(int index) {
    final updated = [...state.allergies];
    updated.removeAt(index);
    state = state.copyWith(allergies: updated);
  }

  void loadFromHealthData(HealthData data) {
    debugPrint('DEBUG loadFromHealthData - age: ${data.age}, weight: ${data.weight}, height: ${data.height}, gender: ${data.gender}');
    state = HealthFormState(
      age: data.age,
      weight: data.weight,
      height: data.height ?? 175,
      gender: data.gender ?? 'male',
      activityLevel: data.activityLevel,
      sleepHours: data.sleepHours,
      waterIntake: data.waterIntake,
      dietType: data.dietType,
      injuries: data.injuries,
      medicalConditions: data.medicalConditions,
      allergies: data.allergies,
    );
  }

  Future<void> saveHealthData(String userId, String goal, HealthService healthService) async {
    await healthService.saveHealthData(
      userId: userId,
      age: state.age,
      weight: state.weight,
      height: state.height,
      gender: state.gender,
      activityLevel: state.activityLevel,
      goal: goal,
      dietType: state.dietType,
      sleepHours: state.sleepHours,
      waterIntake: state.waterIntake,
      injuries: state.injuries,
      medicalConditions: state.medicalConditions,
      allergies: state.allergies,
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
    required int sleepHours,
    required int waterIntake,
    required String injuries,
    required String medicalConditions,
    required String allergies,
  }) async {
    // Convert comma-separated strings to List
    final injuriesList = injuries.trim().isEmpty 
        ? <String>[] 
        : injuries.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    final conditionsList = medicalConditions.trim().isEmpty 
        ? <String>[] 
        : medicalConditions.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    final allergiesList = allergies.trim().isEmpty 
        ? <String>[] 
        : allergies.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    debugPrint('[HealthFormNotifier] Saving onboarding for user: $userId');
    debugPrint('[HealthFormNotifier] Injuries: $injuriesList, Conditions: $conditionsList, Allergies: $allergiesList');
    
    // Update state
    state = state.copyWith(
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      activityLevel: activityLevel,
      dietType: dietType,
      sleepHours: sleepHours,
      waterIntake: waterIntake,
      injuries: injuriesList,
      medicalConditions: conditionsList,
      allergies: allergiesList,
    );
    
    // Save to database
    final healthService = HealthService();
    await healthService.saveHealthData(
      userId: userId,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
      dietType: dietType,
      sleepHours: sleepHours,
      waterIntake: waterIntake,
      injuries: injuriesList,
      medicalConditions: conditionsList,
      allergies: allergiesList,
    );
  }

  void reset() {
    state = HealthFormState(
      age: 28,
      weight: 68,
      height: 175,
      gender: 'male',
      activityLevel: 'moderately_active',
      sleepHours: 7,
      waterIntake: 2000,
      dietType: 'normal',
      injuries: [],
      medicalConditions: [],
      allergies: [],
    );
  }
}

class HealthFormState {
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String activityLevel;
  final int sleepHours;
  final int waterIntake;
  final String dietType;
  final List<String> injuries;
  final List<String> medicalConditions;
  final List<String> allergies;

  HealthFormState({
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.sleepHours,
    required this.waterIntake,
    required this.dietType,
    required this.injuries,
    required this.medicalConditions,
    required this.allergies,
  });

  HealthFormState copyWith({
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activityLevel,
    int? sleepHours,
    int? waterIntake,
    String? dietType,
    List<String>? injuries,
    List<String>? medicalConditions,
    List<String>? allergies,
  }) {
    return HealthFormState(
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      sleepHours: sleepHours ?? this.sleepHours,
      waterIntake: waterIntake ?? this.waterIntake,
      dietType: dietType ?? this.dietType,
      injuries: injuries ?? this.injuries,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
    );
  }
}

// Provider for health form state
final healthFormProvider = StateNotifierProvider<HealthFormNotifier, HealthFormState>((ref) {
  return HealthFormNotifier();
});

// Provider for loading health profile from Supabase and syncing to form
final syncHealthProfileProvider = FutureProvider<void>((ref) async {
  final healthService = ref.watch(healthServiceProvider);

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    return;
  }

  final result = await healthService.checkHealthProfile();
  if (result.hasProfile && result.healthData != null) {
    // Debug: check height value
    debugPrint('DEBUG syncHealthProfileProvider - height: ${result.healthData!.height}');
    // Sync health data to form provider
    ref.read(healthFormProvider.notifier).loadFromHealthData(result.healthData!);
  }
});

// Provider for loading health profile from Supabase
final healthProfileProvider = FutureProvider<(bool, HealthData?)>((ref) async {
  final healthService = ref.watch(healthServiceProvider);

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    return (false, null);
  }

  final result = await healthService.checkHealthProfile();
  if (result.hasProfile && result.healthData != null) {
    return (true, result.healthData);
  }

  return (false, null);
});

// Provider for health calculations
final healthCalculationsProvider = Provider<HealthCalculations>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  final formState = ref.watch(healthFormProvider);

  final bmi = healthService.calculateBMI(formState.weight, formState.height);
  final bmiCategory = healthService.getBMICategory(bmi);
  final bmr =
      healthService.calculateBMR(formState.weight, formState.height, formState.age, formState.gender);
  final tdee = healthService.calculateTDEE(bmr, formState.activityLevel);
  final maxHR = healthService.calculateMaxHeartRate(formState.age);
  final fatBurnZone = healthService.calculateFatBurnZone(maxHR);
  final cardioZone = healthService.calculateCardioZone(maxHR);

  return HealthCalculations(
    bmi: bmi,
    bmiCategory: bmiCategory,
    bmr: bmr,
    tdee: tdee,
    maxHeartRate: maxHR,
    fatBurnZone: fatBurnZone,
    cardioZone: cardioZone,
  );
});

class HealthCalculations {
  final double bmi;
  final String bmiCategory;
  final int bmr;
  final int tdee;
  final int maxHeartRate;
  final ({int min, int max}) fatBurnZone;
  final ({int min, int max}) cardioZone;

  HealthCalculations({
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.tdee,
    required this.maxHeartRate,
    required this.fatBurnZone,
    required this.cardioZone,
  });
}

// Provider for saving health profile
final saveHealthProfileProvider = FutureProvider.family<String?, HealthProfileSaveParams>((ref, params) async {
  final healthService = ref.watch(healthServiceProvider);

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return 'Chưa đăng nhập';

  final userId = session.user.id;
  final formState = ref.watch(healthFormProvider);

  // Convert empty lists to ["Không"] for display purposes
  final injuries = formState.injuries.isEmpty ? ['Không'] : formState.injuries;
  final medicalConditions = formState.medicalConditions.isEmpty ? ['Không'] : formState.medicalConditions;
  final allergies = formState.allergies.isEmpty ? ['Không'] : formState.allergies;

  final result = await healthService.saveHealthProfile(
    userId,
    formState.age,
    formState.weight,
    formState.height,
    injuries,
    medicalConditions,
    formState.activityLevel,
    formState.sleepHours,
    formState.waterIntake,
    formState.dietType,
    allergies,
  );

  if (result.error != null) {
    return result.error;
  }

  // Update user profile with height and gender if needed
  if (params.height != null || params.gender != null) {
    await healthService.updateUserProfile(userId, params.height, params.gender);
  }

  // Reload data from Supabase after save
  ref.invalidate(syncHealthProfileProvider);

  return null;
});

class HealthProfileSaveParams {
  final double? height;
  final String? gender;

  HealthProfileSaveParams({this.height, this.gender});
}
