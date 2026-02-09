class ProgressUser {
  final int? id;
  final String userId;
  final DateTime date;
  final int workoutsCompleted;
  final int totalDurationSeconds;
  final double totalCaloriesBurned;
  final int steps;
  final int waterGlasses;
  final int waterMl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProgressUser({
    this.id,
    required this.userId,
    required this.date,
    this.workoutsCompleted = 0,
    this.totalDurationSeconds = 0,
    this.totalCaloriesBurned = 0.0,
    this.steps = 0,
    this.waterGlasses = 0,
    this.waterMl = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProgressUser.fromJson(Map<String, dynamic> json) {
    return ProgressUser(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      workoutsCompleted: json['workouts_completed'] as int? ?? 0,
      totalDurationSeconds: json['total_duration_seconds'] as int? ?? 0,
      totalCaloriesBurned:
          (json['total_calories_burned'] as num?)?.toDouble() ?? 0.0,
      steps: json['steps'] as int? ?? 0,
      waterGlasses: json['water_glasses'] as int? ?? 0,
      waterMl: json['water_ml'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'workouts_completed': workoutsCompleted,
      'total_duration_seconds': totalDurationSeconds,
      'total_calories_burned': totalCaloriesBurned,
      'steps': steps,
      'water_glasses': waterGlasses,
      'water_ml': waterMl,
    };
  }

  ProgressUser copyWith({
    int? id,
    String? userId,
    DateTime? date,
    int? workoutsCompleted,
    int? totalDurationSeconds,
    double? totalCaloriesBurned,
    int? steps,
    int? waterGlasses,
    int? waterMl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProgressUser(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      workoutsCompleted: workoutsCompleted ?? this.workoutsCompleted,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      steps: steps ?? this.steps,
      waterGlasses: waterGlasses ?? this.waterGlasses,
      waterMl: waterMl ?? this.waterMl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
