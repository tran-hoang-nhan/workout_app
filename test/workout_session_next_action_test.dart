import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/models/workout_item.dart';
import 'package:workout_app/screens/workout_session/workout_session_next_action.dart';

void main() {
  group('computeNextAction', () {
    test('enters rest for time-based item when restSeconds > 0', () {
      final item = WorkoutItem(
        id: 1,
        workoutId: 1,
        exerciseId: 1,
        orderIndex: 0,
        durationSeconds: 45,
        reps: null,
        restSeconds: 15,
      );

      final action = computeNextAction(
        currentIndex: 0,
        totalItems: 2,
        inRest: false,
        item: item,
      );

      expect(action.type, WorkoutSessionNextActionType.enterRest);
      expect(action.restSeconds, 15);
    });

    test('advances from rest when there is a next item', () {
      final item = WorkoutItem(
        id: 1,
        workoutId: 1,
        exerciseId: 1,
        orderIndex: 0,
        durationSeconds: 45,
        reps: null,
        restSeconds: 15,
      );

      final action = computeNextAction(
        currentIndex: 0,
        totalItems: 2,
        inRest: true,
        item: item,
      );

      expect(action.type, WorkoutSessionNextActionType.advance);
    });
  });
}

