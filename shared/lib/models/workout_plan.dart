import 'exercise.dart';
import 'workout_item.dart';
import 'workout.dart';
import 'workout_detail.dart';

class WorkoutPlan {
  final int? id;
  final String title;
  final String goal;
  final String level;
  final List<Exercise> exercises;
  final List<WorkoutItem>? items;
  final String? notes;

  WorkoutPlan({
    this.id,
    required this.title,
    required this.goal,
    required this.level,
    required this.exercises,
    this.items,
    this.notes,
  });

  /// Converts this plan to a standard [Workout] object.
  Workout toWorkout() {
    return Workout(
      id: id ?? 0,
      title: title,
      description: notes,
      level: level,
    );
  }

  /// Converts this plan and its references to a standard [WorkoutDetail] object.
  WorkoutDetail toWorkoutDetail() {
    return WorkoutDetail(
      workout: toWorkout(),
      items: items ?? [],
      exercises: exercises,
    );
  }

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    var data = json;
    if (json.containsKey('workout_suggestion')) {
      data = json['workout_suggestion'] as Map<String, dynamic>;
    }

    final rawExercises = data['exercises'] as List? ?? [];
    
    // In AI suggestions, 'exercises' field contains workout metrics (reps, rest).
    // In enriched/standard workouts, it contains full Exercise objects.
    // We parse them as Exercises here.
    final List<Exercise> parsedExercises = rawExercises.map((e) {
      final map = e as Map<String, dynamic>;
      // Ensure 'id' is present if 'exercise_id' is used
      if (!map.containsKey('id') && map.containsKey('exercise_id')) {
        map['id'] = map['exercise_id'];
      }
      return Exercise.fromJson(map);
    }).toList();

    // The 'items' are the workout steps (reps, duration, etc.)
    // They are usually in 'items' or 'exercises' (in AI suggestions)
    final List<WorkoutItem> parsedItems = (data['items'] as List? ?? rawExercises)
        .map((e) => WorkoutItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return WorkoutPlan(
      id: data['id'] as int?,
      title: data['title'] ?? '',
      goal: data['goal'] ?? '',
      level: data['level'] ?? '',
      exercises: parsedExercises,
      items: parsedItems,
      notes: data['notes'] ?? data['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'goal': goal,
      'level': level,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'items': items?.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  WorkoutPlan copyWith({
    int? id,
    String? title,
    String? goal,
    String? level,
    List<Exercise>? exercises,
    List<WorkoutItem>? items,
    String? notes,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      exercises: exercises ?? this.exercises,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }
}
