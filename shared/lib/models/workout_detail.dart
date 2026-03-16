import 'exercise.dart';
import 'workout.dart';
import 'workout_item.dart';

class WorkoutDetail {
  final Workout workout;
  final List<WorkoutItem> items;
  final List<Exercise> exercises;

  WorkoutDetail({
    required this.workout,
    required this.items,
    required this.exercises,
  });

  factory WorkoutDetail.fromJson(Map<String, dynamic> json) {
    return WorkoutDetail(
      workout: Workout.fromJson(json['workout'] as Map<String, dynamic>),
      items: (json['items'] as List? ?? [])
          .map((e) => WorkoutItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workout': workout.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}
