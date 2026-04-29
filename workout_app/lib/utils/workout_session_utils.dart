import 'package:shared/shared.dart';

class WorkoutSessionUtils {
  static double calculateCalories({
    required bool inRest,
    required int currentIndex,
    required List<Exercise> exercises,
    required double accumulatedCalories,
    required DateTime? lastStepStartTime,
    required bool inCountdown,
  }) {
    double currentRate = 7.0;
    if (inRest) {
      currentRate = 3.0; 
    } else if (currentIndex < exercises.length) {
      currentRate = exercises[currentIndex].caloriesPerMinute ?? 7.0;
    }

    double currentStepCalories = 0;
    if (lastStepStartTime != null && !inCountdown) {
      final now = DateTime.now();
      final ms = now.difference(lastStepStartTime).inMilliseconds;
      if (ms > 0) {
        currentStepCalories = (ms / 60000.0) * currentRate;
      }
    }

    return accumulatedCalories + currentStepCalories;
  }
}
