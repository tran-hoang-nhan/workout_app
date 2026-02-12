import 'workout.dart';

class AIChatMessage {
  final String id;
  final String content;
  final bool isAI;
  final Workout? workout;
  final DateTime timestamp;

  AIChatMessage({
    required this.id,
    required this.content,
    required this.isAI,
    this.workout,
    required this.timestamp,
  });
}
