import 'package:shared/shared.dart';

enum MessageType { ai, user }

class ChatMessage {
  final String content;
  final MessageType type;
  final Workout? workout;
  final WorkoutDetail? detail;

  ChatMessage({
    required this.content,
    required this.type,
    this.workout,
    this.detail,
  });
}
