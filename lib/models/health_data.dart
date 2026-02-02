class HealthData {
  final String userId;
  final int age;
  final double weight;
  final double? height;
  final List<String> injuries;
  final List<String> medicalConditions;
  final String activityLevel;
  final int waterIntake;
  final String dietType;
  final List<String> allergies;
  final String? gender;
  final int steps;
  final bool waterReminderEnabled;
  final int waterReminderInterval;
  final String wakeTime;
  final String sleepTime;


  HealthData({
    required this.userId,
    required this.age,
    required this.weight,
    this.height,
    required this.injuries,
    required this.medicalConditions,
    required this.activityLevel,
    required this.waterIntake,
    required this.dietType,
    required this.allergies,
    this.gender,
    this.steps = 0,
    this.waterReminderEnabled = false,
    this.waterReminderInterval = 2,
    this.wakeTime = '07:00',
    this.sleepTime = '23:00',
  });

  factory HealthData.fromJson(Map<String, dynamic> json, String userId, {String? gender}) {
    return HealthData(
      userId: userId,
      age: json['age'] as int? ?? 25,
      weight: (json['weight'] as num?)?.toDouble() ?? 65.0,
      height: (json['height'] as num?)?.toDouble(),
      injuries: List<String>.from(json['injuries'] ?? []),
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      activityLevel: json['activity_level'] as String? ?? 'moderately_active',
      waterIntake: json['water_intake_goal'] as int? ?? 2000,
      dietType: json['diet_type'] as String? ?? 'normal',
      allergies: List<String>.from(json['allergies'] ?? []),
      gender: gender,
      steps: json['steps'] as int? ?? 0,
      waterReminderEnabled: json['water_reminder_enabled'] as bool? ?? false,
      waterReminderInterval: json['water_reminder_interval'] as int? ?? 2,
      wakeTime: json['wake_time'] as String? ?? '07:00',
      sleepTime: json['sleep_time'] as String? ?? '23:00',
    );
  }
}
