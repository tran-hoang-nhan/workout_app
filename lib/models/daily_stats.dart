class DailyStats {
  final String? id;
  final String userId;
  final DateTime date;
  final double? weight;
  final double? height;
  final int caloriesBurned;
  final int workoutDuration;
  final int stepsCount;
  final int waterIntake;
  final DateTime? createdAt;

  DailyStats({
    this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.height,
    this.caloriesBurned = 0,
    this.workoutDuration = 0,
    this.stepsCount = 0,
    this.waterIntake = 0,
    this.createdAt,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      caloriesBurned: json['calories_burned'] as int? ?? 0,
      workoutDuration: json['workout_duration'] as int? ?? 0,
      stepsCount: json['steps_count'] as int? ?? 0,
      waterIntake: json['water_intake'] as int? ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'weight': weight,
      'height': height,
      'calories_burned': caloriesBurned,
      'workout_duration': workoutDuration,
      'steps_count': stepsCount,
      'water_intake': waterIntake,
    };
  }

  DailyStats copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? weight,
    double? height,
    int? caloriesBurned,
    int? workoutDuration,
    int? stepsCount,
    int? waterIntake,
    DateTime? createdAt,
  }) {
    return DailyStats(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      workoutDuration: workoutDuration ?? this.workoutDuration,
      stepsCount: stepsCount ?? this.stepsCount,
      waterIntake: waterIntake ?? this.waterIntake,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
