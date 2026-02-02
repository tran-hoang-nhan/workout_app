class HealthUpdateParams {
  final String userId;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final String activityLevel;
  final String goal;
  final String dietType;
  final int waterIntake;
  final List<String> injuries;
  final List<String> medicalConditions;
  final List<String> allergies;
  final bool? waterReminderEnabled;
  final int? waterReminderInterval;
  final String? wakeTime;
  final String? sleepTime;

  HealthUpdateParams({
    required this.userId,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.dietType,
    required this.waterIntake,
    required this.injuries,
    required this.medicalConditions,
    required this.allergies,
    this.waterReminderEnabled,
    this.waterReminderInterval,
    this.wakeTime,
    this.sleepTime,
  });

  Map<String, dynamic> toHealthMap() {
    final map = {
      'user_id': userId,
      'age': age,
      'weight': weight,
      'height': height,
      'activity_level': activityLevel,
      'diet_type': dietType,
      'water_intake_goal': waterIntake,
      'injuries': injuries,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (waterReminderEnabled != null) {
      map['water_reminder_enabled'] = waterReminderEnabled!;
    }
    if (waterReminderInterval != null) {
      map['water_reminder_interval'] = waterReminderInterval!;
    }
    if (wakeTime != null) {
      map['wake_time'] = wakeTime!;
    }
    if (sleepTime != null) {
      map['sleep_time'] = sleepTime!;
    }

    return map;
  }

  Map<String, dynamic> toProfileMap() {
    return {'gender': gender, 'goal': goal};
  }

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
      waterReminderInterval:
          waterReminderInterval ?? this.waterReminderInterval,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
    );
  }
}
