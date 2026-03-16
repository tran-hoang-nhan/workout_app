import 'exercise.dart';

class WorkoutPlan {
  final String title;
  final String goal;
  final String level;
  final List<Exercise> exercises;
  final String? notes;

  WorkoutPlan({
    required this.title,
    required this.goal,
    required this.level,
    required this.exercises,
    this.notes,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      title: json['title'] ?? '',
      goal: json['goal'] ?? '',
      level: json['level'] ?? '',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'goal': goal,
      'level': level,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }
}
