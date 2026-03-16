class HealthUpdateParams {
  final String userId;
  final int age;
  final double weight;
  final double height;
  final String? gender;
  final String activityLevel;
  final String goal;
  final String dietType;
  final int waterIntake;
  final List<String> injuries;
  final List<String> medicalConditions;
  final List<String> allergies;
  final bool waterReminderEnabled;
  final int waterReminderInterval;
  final String wakeTime;
  final String sleepTime;

  HealthUpdateParams({
    required this.userId,
    required this.age,
    required this.weight,
    required this.height,
    this.gender,
    required this.activityLevel,
    required this.goal,
    required this.dietType,
    required this.waterIntake,
    required this.injuries,
    required this.medicalConditions,
    required this.allergies,
    this.waterReminderEnabled = false,
    this.waterReminderInterval = 2,
    this.wakeTime = '07:00',
    this.sleepTime = '23:00',
  });

  static HealthUpdateParams initial([String userId = '']) => HealthUpdateParams(
    userId: userId,
    age: 25,
    weight: 70,
    height: 170,
    activityLevel: 'sedentary',
    goal: 'maintain',
    dietType: 'Balanced',
    waterIntake: 2000,
    injuries: [],
    medicalConditions: [],
    allergies: [],
  );

  HealthUpdateParams copyWith({
    String? userId,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? activityLevel,
    String? goal,
    String? dietType,
    int? waterIntake,
    List<String>? injuries,
    List<String>? medicalConditions,
    List<String>? allergies,
    bool? waterReminderEnabled,
    int? waterReminderInterval,
    String? wakeTime,
    String? sleepTime,
  }) {
    return HealthUpdateParams(
      userId: userId ?? this.userId,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dietType: dietType ?? this.dietType,
      waterIntake: waterIntake ?? this.waterIntake,
      injuries: injuries ?? this.injuries,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      waterReminderEnabled: waterReminderEnabled ?? this.waterReminderEnabled,
      waterReminderInterval: waterReminderInterval ?? this.waterReminderInterval,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
    );
  }

  factory HealthUpdateParams.fromJson(Map<String, dynamic> json) {
    return HealthUpdateParams(
      userId: json['user_id'] as String,
      age: json['age'] as int,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      gender: json['gender'] as String?,
      activityLevel: json['activity_level'] as String,
      goal: json['goal'] as String,
      dietType: json['diet_type'] as String,
      waterIntake: json['water_intake'] as int,
      injuries: List<String>.from(json['injuries'] ?? []),
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      waterReminderEnabled: json['water_reminder_enabled'] as bool? ?? false,
      waterReminderInterval: json['water_reminder_interval'] as int? ?? 2,
      wakeTime: json['wake_time'] as String? ?? '07:00',
      sleepTime: json['sleep_time'] as String? ?? '23:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activity_level': activityLevel,
      'goal': goal,
      'diet_type': dietType,
      'water_intake': waterIntake,
      'injuries': injuries,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'water_reminder_enabled': waterReminderEnabled,
      'water_reminder_interval': waterReminderInterval,
      'wake_time': wakeTime,
      'sleep_time': sleepTime,
    };
  }
}
