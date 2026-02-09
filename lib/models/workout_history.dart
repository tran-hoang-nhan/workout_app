class WorkoutHistory {
  final int id;
  final String userId;
  final int? workoutId;
  final String? workoutTitleSnapshot;
  final double? totalCaloriesBurned;
  final int? durationSeconds;
  final DateTime completedAt;

  String? get workoutName => workoutTitleSnapshot;

  WorkoutHistory({
    required this.id,
    required this.userId,
    this.workoutId,
    this.workoutTitleSnapshot,
    this.totalCaloriesBurned,
    this.durationSeconds,
    required this.completedAt,
  });

  factory WorkoutHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutHistory(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      workoutId: json['workout_id'],
      workoutTitleSnapshot: json['workout_title_snapshot'],
      totalCaloriesBurned: json['total_calories_burned']?.toDouble(),
      durationSeconds: json['duration_seconds'] is int
          ? json['duration_seconds']
          : (json['duration_seconds'] as double?)?.toInt(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : DateTime.now(),
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

  WorkoutHistory copyWith({
    int? id,
    String? userId,
    int? workoutId,
    String? workoutTitleSnapshot,
    double? totalCaloriesBurned,
    int? durationSeconds,
    DateTime? completedAt,
  }) {
    return WorkoutHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutId: workoutId ?? this.workoutId,
      workoutTitleSnapshot: workoutTitleSnapshot ?? this.workoutTitleSnapshot,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
