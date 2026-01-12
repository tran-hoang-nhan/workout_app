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
    final dynamic exerciseIdRaw = json['exercise_id'] ?? json['exerciseId'];
    final int exerciseIdParsed = exerciseIdRaw is int
        ? exerciseIdRaw
        : (exerciseIdRaw is String ? int.tryParse(exerciseIdRaw) ?? 0 : 0);
    final dynamic orderIndexRaw = json['order_index'] ?? json['orderIndex'];
    final int orderIndexParsed = orderIndexRaw is int
        ? orderIndexRaw
        : (orderIndexRaw is String ? int.tryParse(orderIndexRaw) ?? 0 : 0);
    final dynamic durationRaw =
        json['duration_seconds'] ?? json['durationSeconds'];
    final int? durationParsed = durationRaw is int
        ? durationRaw
        : (durationRaw is String ? int.tryParse(durationRaw) : null);
    final dynamic repsRaw = json['reps'];
    final int? repsParsed =
        repsRaw is int ? repsRaw : (repsRaw is String ? int.tryParse(repsRaw) : null);
    final dynamic restRaw = json['rest_seconds'] ?? json['restSeconds'];
    final int? restParsed =
        restRaw is int ? restRaw : (restRaw is String ? int.tryParse(restRaw) : null);
    return WorkoutItem(
      id: json['id'] ?? 0,
      workoutId: json['workout_id'] ?? 0,
      exerciseId: exerciseIdParsed,
      orderIndex: orderIndexParsed,
      durationSeconds: durationParsed,
      reps: repsParsed,
      restSeconds: restParsed,
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
