import 'exercise.dart';
import 'workout_item.dart';

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

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    var data = json;
    if (json.containsKey('workout_suggestion')) {
      data = json['workout_suggestion'] as Map<String, dynamic>;
    }

    return WorkoutPlan(
      id: data['id'] as int?,
      title: data['title'] ?? '',
      goal: data['goal'] ?? '',
      level: data['level'] ?? '',
      exercises: (data['exercises'] as List? ?? []).map((e) {
        final map = e as Map<String, dynamic>;
        if (!map.containsKey('id') && map.containsKey('exercise_id')) {
          map['id'] = map['exercise_id'];
        }
        return Exercise.fromJson(map);
      }).toList(),
      items: (data['items'] as List? ?? data['exercises'] as List? ?? [])
          .map((e) => WorkoutItem.fromJson(e as Map<String, dynamic>))
          .toList(),
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
}
