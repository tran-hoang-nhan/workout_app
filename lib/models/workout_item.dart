class WorkoutItem {
  final int id;
  final int workoutId;
  final int exerciseId;
  final int orderIndex;
  final int? durationSeconds;
  final int? reps;
  final int? restSeconds;

  WorkoutItem({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.orderIndex,
    this.durationSeconds,
    this.reps,
    this.restSeconds,
  });

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      id: json['id'] ?? 0,
      workoutId: json['workout_id'] ?? 0,
      exerciseId: json['exercise_id'] ?? 0,
      orderIndex: json['order_index'] ?? 0,
      durationSeconds: json['duration_seconds'],
      reps: json['reps'],
      restSeconds: json['rest_seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'order_index': orderIndex,
      'duration_seconds': durationSeconds,
      'reps': reps,
      'rest_seconds': restSeconds,
    };
  }

  WorkoutItem copyWith({
    int? id,
    int? workoutId,
    int? exerciseId,
    int? orderIndex,
    int? durationSeconds,
    int? reps,
    int? restSeconds,
  }) {
    return WorkoutItem(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}
