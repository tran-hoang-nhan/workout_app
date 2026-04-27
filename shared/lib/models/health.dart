class BodyMetric {
  final int? id;
  final String userId;
  final double weight;
  final double? bmi;
  final DateTime recordedAt;

  BodyMetric({
    this.id,
    required this.userId,
    required this.weight,
    this.bmi,
    required this.recordedAt,
  });

  factory BodyMetric.fromJson(Map<String, dynamic> json) {
    return BodyMetric(
      id: json['id'] as int?,
      userId: json['user_id'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      recordedAt: json['recorded_at'] != null ? DateTime.parse(json['recorded_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'weight': weight,
      'bmi': bmi,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}

class DailyStats {
  final String? id;
  final String userId;
  final DateTime date;
  final double activeEnergyBurned;
  final int activeMinutes;
  final double distanceMeters;
  final int? avgHeartRate;
  final int? minHeartRate;
  final int? maxHeartRate;
  final int? restingHeartRate;
  final Map<String, dynamic>? heartRateZones;

  DailyStats({
    this.id,
    required this.userId,
    required this.date,
    this.activeEnergyBurned = 0,
    this.activeMinutes = 0,
    this.distanceMeters = 0,
    this.avgHeartRate,
    this.minHeartRate,
    this.maxHeartRate,
    this.restingHeartRate,
    this.heartRateZones,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      id: json['id']?.toString(),
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      activeEnergyBurned: (json['active_energy_burned'] as num?)?.toDouble() ?? 0,
      activeMinutes: json['active_minutes'] as int? ?? 0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0,
      avgHeartRate: json['avg_heart_rate'] as int?,
      minHeartRate: json['min_heart_rate'] as int?,
      maxHeartRate: json['max_heart_rate'] as int?,
      restingHeartRate: json['resting_heart_rate'] as int?,
      heartRateZones: json['heart_rate_zones'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'active_energy_burned': activeEnergyBurned,
      'active_minutes': activeMinutes,
      'distance_meters': distanceMeters,
      'avg_heart_rate': avgHeartRate,
      'min_heart_rate': minHeartRate,
      'max_heart_rate': maxHeartRate,
      'resting_heart_rate': restingHeartRate,
      'heart_rate_zones': heartRateZones,
    };
  }
}

class HealthData {
  final String userId;
  final double weight;
  final double height;
  final int age;
  final String? gender;
  final String activityLevel;
  final String goal;
  final String dietType;
  final List<String> injuries;
  final List<String> medicalConditions;
  final List<String> allergies;
  final int waterIntake;
  final bool waterReminderEnabled;
  final int waterReminderInterval;
  final String? wakeTime;
  final String? sleepTime;

  HealthData({
    required this.userId,
    required this.weight,
    required this.height,
    required this.age,
    this.gender,
    required this.activityLevel,
    required this.goal,
    this.dietType = 'Balanced',
    this.injuries = const [],
    this.medicalConditions = const [],
    this.allergies = const [],
    required this.waterIntake,
    this.waterReminderEnabled = false,
    this.waterReminderInterval = 2,
    this.wakeTime,
    this.sleepTime,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      userId: json['user_id'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String?,
      activityLevel: json['activity_level'] as String? ?? 'Sedentary',
      goal: json['goal'] as String? ?? 'Maintenance',
      dietType: json['diet_type'] as String? ?? 'Balanced',
      injuries: List<String>.from(json['injuries'] ?? []),
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      waterIntake: json['water_intake_goal'] as int? ?? 2000,
      waterReminderEnabled: json['water_reminder_enabled'] as bool? ?? false,
      waterReminderInterval: json['water_reminder_interval'] as int? ?? 2,
      wakeTime: json['wake_time'] as String?,
      sleepTime: json['sleep_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activity_level': activityLevel,
      'goal': goal,
      'diet_type': dietType,
      'injuries': injuries,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'water_intake_goal': waterIntake,
      'water_reminder_enabled': waterReminderEnabled,
      'water_reminder_interval': waterReminderInterval,
      'wake_time': wakeTime,
      'sleep_time': sleepTime,
    };
  }
}

class HealthCalculations {
  final double bmi;
  final String bmiCategory;
  final double bmr;
  final double tdee;
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
}
