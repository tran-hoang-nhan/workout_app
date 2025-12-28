class HealthData {
  final String userId;
  final int age;
  final double weight;
  final double? height;
  final List<String> injuries;
  final List<String> medicalConditions;
  final String activityLevel;
  final int sleepHours;
  final int waterIntake;
  final String dietType;
  final List<String> allergies;
  final String? gender;

  HealthData({
    required this.userId,
    required this.age,
    required this.weight,
    this.height,
    required this.injuries,
    required this.medicalConditions,
    required this.activityLevel,
    required this.sleepHours,
    required this.waterIntake,
    required this.dietType,
    required this.allergies,
    this.gender,
  });

  factory HealthData.fromJson(Map<String, dynamic> json, String userId, {double? height, String? gender}) {
    return HealthData(
      userId: userId,
      age: json['age'] as int? ?? 25,
      weight: (json['weight'] as num?)?.toDouble() ?? 65.0,
      height: height,
      injuries: List<String>.from(json['injuries'] ?? []),
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      activityLevel: json['activity_level'] as String? ?? 'moderately_active',
      sleepHours: json['sleep_hours_avg'] as int? ?? 7,
      waterIntake: json['water_intake_goal'] as int? ?? 2000,
      dietType: json['diet_type'] as String? ?? 'normal',
      allergies: List<String>.from(json['allergies'] ?? []),
      gender: gender,
    );
  }
}
