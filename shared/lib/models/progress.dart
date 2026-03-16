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
  });

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
    );
  }

  factory ProgressUser.fromJson(Map<String, dynamic> json) {
    return ProgressUser(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      workoutsCompleted: json['workouts_completed'] as int? ?? 0,
      totalDurationSeconds: json['total_duration_seconds'] as int? ?? 0,
      totalCaloriesBurned: (json['total_calories_burned'] as num?)?.toDouble() ?? 0.0,
      steps: json['steps'] as int? ?? 0,
      waterGlasses: json['water_glasses'] as int? ?? 0,
      waterMl: json['water_ml'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
}

class WorkoutHistory {
  final int id;
  final String userId;
  final int? workoutId;
  final String? workoutTitleSnapshot;
  final double? totalCaloriesBurned;
  final int? durationSeconds;
  final DateTime completedAt;

  WorkoutHistory({
    required this.id,
    required this.userId,
    this.workoutId,
    this.workoutTitleSnapshot,
    this.totalCaloriesBurned,
    this.durationSeconds,
    required this.completedAt,
  });

  String get workoutName => workoutTitleSnapshot ?? 'Bài tập';

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutHistory(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      workoutId: json['workout_id'],
      workoutTitleSnapshot: json['workout_title_snapshot'],
      totalCaloriesBurned: (json['total_calories_burned'] as num?)?.toDouble(),
      durationSeconds: json['duration_seconds'] as int?,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workout_id': workoutId,
      'workout_title_snapshot': workoutTitleSnapshot,
      'total_calories_burned': totalCaloriesBurned,
      'duration_seconds': durationSeconds,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}

class ProgressStats {
  final int totalWorkouts;
  final double totalCalories;
  final int totalDuration;
  final double avgCaloriesPerSession;
  final int streak;

  double get totalCaloriesCalo => totalCalories;

  ProgressStats({
    required this.totalWorkouts,
    required this.totalCalories,
    required this.totalDuration,
    required this.avgCaloriesPerSession,
    this.streak = 0,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      totalWorkouts: json['total_workouts'] ?? 0,
      totalCalories: (json['total_calories_burned'] ?? json['total_calories'] ?? 0).toDouble(),
      totalDuration: json['total_duration_minutes'] ?? json['total_duration'] ?? 0,
      avgCaloriesPerSession: (json['avg_calories_per_session'] ?? 0).toDouble(),
      streak: json['streak'] ?? json['streak_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_workouts': totalWorkouts,
      'total_calories': totalCalories,
      'total_duration': totalDuration,
      'avg_calories_per_session': avgCaloriesPerSession,
      'streak': streak,
    };
  }
}
