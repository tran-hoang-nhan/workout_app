class HealthUpdateParams {
  final String userId;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String activityLevel;
  final String goal;
  final String dietType;
  final int sleepHours;
  final int waterIntake;
  final List<String> injuries;
  final List<String> medicalConditions;
  final List<String> allergies;

  HealthUpdateParams({
    required this.userId,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.dietType,
    required this.sleepHours,
    required this.waterIntake,
    required this.injuries,
    required this.medicalConditions,
    required this.allergies,
  });

  Map<String, dynamic> toHealthMap() {
    return {
      'user_id': userId,
      'age': age,
      'weight': weight,
      'activity_level': activityLevel,
      'diet_type': dietType,
      'sleep_hours_avg': sleepHours,
      'water_intake_goal': waterIntake,
      'injuries': injuries,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toProfileMap() {
    return {
      'height': height,
      'gender': gender,
      'goal': goal,
    };
  }
}