import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthData {
  final String userId;
  final int age;
  final double weight;
  final List<String> injuries;
  final List<String> medicalConditions;
  final String activityLevel;
  final int sleepHours;
  final int waterIntake;
  final String dietType;
  final List<String> allergies;
  final String? gender;
  final double? height;

  HealthData({
    required this.userId,
    required this.age,
    required this.weight,
    required this.injuries,
    required this.medicalConditions,
    required this.activityLevel,
    required this.sleepHours,
    required this.waterIntake,
    required this.dietType,
    required this.allergies,
    this.gender,
    this.height,
  });

  HealthData copyWith({
    String? userId,
    int? age,
    double? weight,
    List<String>? injuries,
    List<String>? medicalConditions,
    String? activityLevel,
    int? sleepHours,
    int? waterIntake,
    String? dietType,
    List<String>? allergies,
    String? gender,
    double? height,
  }) {
    return HealthData(
      userId: userId ?? this.userId,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      injuries: injuries ?? this.injuries,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      activityLevel: activityLevel ?? this.activityLevel,
      sleepHours: sleepHours ?? this.sleepHours,
      waterIntake: waterIntake ?? this.waterIntake,
      dietType: dietType ?? this.dietType,
      allergies: allergies ?? this.allergies,
      gender: gender ?? this.gender,
      height: height ?? this.height,
    );
  }

  int calculateBMR() {
    if (height == null || gender == null) return 0;
    if (gender == 'male') {
      return (88.362 + (13.397 * weight) + (4.799 * height!) - (5.677 * age)).round();
    } else {
      return (447.593 + (9.247 * weight) + (3.098 * height!) - (4.330 * age)).round();
    }
  }

  int calculateTDEE() {
    int bmr = calculateBMR();
    double multiplier = 1.375;
    switch (activityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'lightly_active':
        multiplier = 1.375;
        break;
      case 'moderately_active':
        multiplier = 1.55;
        break;
      case 'very_active':
        multiplier = 1.725;
        break;
    }
    return (bmr * multiplier).round();
  }

  int calculateMaxHeartRate() {
    return 220 - age;
  }

  List<int> calculateFatBurnZone() {
    int maxHr = calculateMaxHeartRate();
    return [
      (maxHr * 0.6).round(),
      (maxHr * 0.7).round(),
    ];
  }

  List<int> calculateCardioZone() {
    int maxHr = calculateMaxHeartRate();
    return [
      (maxHr * 0.7).round(),
      (maxHr * 0.85).round(),
    ];
  }
}

class HealthService {
  final supabase = Supabase.instance.client;

  // Check if user is logged in and has health profile
  Future<({bool isLoggedIn, bool hasProfile, String? userId, HealthData? healthData})>
      checkHealthProfile() async {
    try {
      final session = supabase.auth.currentSession;

      if (session == null) {
        return (isLoggedIn: false, hasProfile: false, userId: null, healthData: null);
      }

      final userId = session.user.id;

      try {
        // Fetch health data
        final healthResponse = await supabase
            .from('health')
            .select()
            .eq('user_id', userId)
            .single();

        // Fetch profile data from profiles table separately
        final profileResponse = await supabase
            .from('profiles')
            .select('height, gender')
            .eq('id', userId)
            .single();

        final profileData = (
          height: (profileResponse['height'] as num?)?.toDouble(),
          gender: profileResponse['gender'] as String?,
        );
        
        final healthData = _mapHealthData(healthResponse, userId, profileData);
        return (isLoggedIn: true, hasProfile: true, userId: userId, healthData: healthData);
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST116') {
          // No record found
          return (
            isLoggedIn: true,
            hasProfile: false,
            userId: userId,
            healthData: null,
          );
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('Error checking health profile: $e');
      return (isLoggedIn: false, hasProfile: false, userId: null, healthData: null);
    }
  }

  // Load additional user data from profiles table
  Future<({double? height, String? gender})> loadUserProfile(String userId) async {
    try {
      final data = await supabase
          .from('profiles')
          .select('height, gender')
          .eq('id', userId)
          .single();

      return (height: (data['height'] as num?)?.toDouble(), gender: data['gender'] as String?);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return (height: null, gender: null);
    }
  }

  // Save health profile to Supabase
  Future<({HealthData? healthData, String? error})> saveHealthProfile(
    String userId,
    int age,
    double weight,
    List<String> injuries,
    List<String> medicalConditions,
    String activityLevel,
    int sleepHours,
    int waterIntake,
    String dietType,
    List<String> allergies,
  ) async {
    try {
      final data = {
        'user_id': userId,
        'age': age,
        'weight': weight,
        'injuries': injuries,
        'medical_conditions': medicalConditions,
        'activity_level': activityLevel,
        'sleep_hours_avg': sleepHours,
        'water_intake_goal': waterIntake,
        'diet_type': dietType,
        'allergies': allergies,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await supabase.from('health').upsert(data).select('*, profiles(height, gender)');

      if (result.isEmpty) {
        return (healthData: null, error: 'Lỗi lưu hồ sơ sức khỏe');
      }

      // Extract height and gender from joined profiles data
      final resultData = result.first;
      final profilesData = resultData['profiles'] as Map<String, dynamic>?;
      final profileData = (
        height: (profilesData?['height'] as num?)?.toDouble(),
        gender: profilesData?['gender'] as String?,
      );
      final healthData = _mapHealthData(resultData, userId, profileData);
      return (healthData: healthData, error: null);
    } catch (e) {
      debugPrint('Error saving health profile: $e');
      return (healthData: null, error: e.toString());
    }
  }

  // Update user profile with additional info
  Future<String?> updateUserProfile(
    String userId,
    double? height,
    String? gender,
  ) async {
    try {
      final data = <String, dynamic>{};
      if (height != null) data['height'] = height;
      if (gender != null) data['gender'] = gender;

      if (data.isEmpty) return null;

      await supabase.from('profiles').update(data).eq('id', userId);
      return null;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return e.toString();
    }
  }

  // Health calculation functions
  double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  int calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'male') {
      return (10 * weight + 6.25 * height - 5 * age + 5).round();
    } else {
      return (10 * weight + 6.25 * height - 5 * age - 161).round();
    }
  }

  int calculateTDEE(int bmr, String activityLevel) {
    const activityMultipliers = {
      'sedentary': 1.2,
      'lightly_active': 1.375,
      'moderately_active': 1.55,
      'very_active': 1.725,
    };
    final multiplier = activityMultipliers[activityLevel] ?? 1.55;
    return (bmr * multiplier).round();
  }

  int calculateMaxHeartRate(int age) {
    return 220 - age;
  }

  ({int min, int max}) calculateFatBurnZone(int maxHeartRate) {
    return (
      min: (maxHeartRate * 0.6).round(),
      max: (maxHeartRate * 0.7).round(),
    );
  }

  ({int min, int max}) calculateCardioZone(int maxHeartRate) {
    return (
      min: (maxHeartRate * 0.7).round(),
      max: (maxHeartRate * 0.85).round(),
    );
  }

  // Helper to map Supabase data to HealthData
  HealthData _mapHealthData(Map<String, dynamic> data, String userId, ({double? height, String? gender}) profileData) {
    return HealthData(
      userId: userId,
      age: (data['age'] as num?)?.toInt() ?? 25,
      weight: (data['weight'] as num?)?.toDouble() ?? 65,
      injuries: List<String>.from(data['injuries'] as List? ?? []),
      medicalConditions: List<String>.from(data['medical_conditions'] as List? ?? []),
      activityLevel: data['activity_level'] as String? ?? 'moderately_active',
      sleepHours: (data['sleep_hours_avg'] as num?)?.toInt() ?? 7,
      waterIntake: (data['water_intake_goal'] as num?)?.toInt() ?? 2000,
      dietType: data['diet_type'] as String? ?? 'normal',
      allergies: List<String>.from(data['allergies'] as List? ?? []),
      gender: profileData.gender ?? (data['gender'] as String?),
      height: profileData.height ?? (data['height'] as num?)?.toDouble(),
    );
  }
}
