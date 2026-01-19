import '../../models/workout_item.dart';

enum WorkoutSessionNextActionType { enterRest, advance, complete }

class WorkoutSessionNextAction {
  final WorkoutSessionNextActionType type;
  final int? restSeconds;

  const WorkoutSessionNextAction._(this.type, {this.restSeconds});

  const WorkoutSessionNextAction.enterRest(int seconds)
      : this._(WorkoutSessionNextActionType.enterRest, restSeconds: seconds);

  const WorkoutSessionNextAction.advance()
      : this._(WorkoutSessionNextActionType.advance);

  const WorkoutSessionNextAction.complete()
      : this._(WorkoutSessionNextActionType.complete);
}

WorkoutSessionNextAction computeNextAction({
  required int currentIndex,
  required int totalItems,
  required bool inRest,
  required WorkoutItem item,
}) {
  final reps = item.reps ?? 0;
  final rest = item.restSeconds ?? 0;
  if (!inRest && reps > 0 && rest > 0) {
    return WorkoutSessionNextAction.enterRest(rest);
  }
  if (currentIndex < totalItems - 1) {
    return const WorkoutSessionNextAction.advance();
  }
  return const WorkoutSessionNextAction.complete();
}

WorkoutSessionNextAction computeAfterTimerFinishedAction({
  required int currentIndex,
  required int totalItems,
  required bool inRest,
  required WorkoutItem item,
}) {
  final rest = item.restSeconds ?? 0;
  if (!inRest && rest > 0) {
    return WorkoutSessionNextAction.enterRest(rest);
  }
  if (currentIndex < totalItems - 1) {
    return const WorkoutSessionNextAction.advance();
  }
  return const WorkoutSessionNextAction.complete();
}

