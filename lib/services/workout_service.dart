import '../models/workout.dart';
import '../models/workout_item.dart';
import '../models/exercise.dart';
import '../repositories/workout_repository.dart';

class WorkoutService {
  final WorkoutRepository _workoutRepository;

  WorkoutService({WorkoutRepository? repository})
    : _workoutRepository = repository ?? WorkoutRepository();

  Future<List<Workout>> getAllWorkouts() async {
    final response = await _workoutRepository.getAllWorkouts();
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    final response = await _workoutRepository.getWorkoutsByLevel(level);
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<({Workout workout, List<WorkoutItem> items, List<Exercise> exercises})>
  getWorkoutDetail(int workoutId) async {
    final workoutData = await _workoutRepository.getWorkoutById(workoutId);
    final workout = Workout.fromJson(workoutData);
    final itemsData = await _workoutRepository.getWorkoutItems(workoutId);
    List<WorkoutItem> items = itemsData
        .map((data) => WorkoutItem.fromJson(data))
        .toList();
    items.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (items.isEmpty) {
      return (
        workout: workout,
        items: <WorkoutItem>[],
        exercises: <Exercise>[],
      );
    }

    final exerciseIds = items
        .map((item) => item.exerciseId)
        .where((id) => id > 0)
        .toSet()
        .toList();
    final exercisesData = await _workoutRepository.getExercisesByIds(
      exerciseIds,
    );
    final exercises = exercisesData
        .map((data) => Exercise.fromJson(data))
        .toList();
    return (workout: workout, items: items, exercises: exercises);
  }

  Future<List<Workout>> searchWorkouts(String query) async {
    final response = await _workoutRepository.searchWorkouts(query);
    return response.map((data) => Workout.fromJson(data)).toList();
  }

  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    final key = category.trim().toLowerCase();
    if (key == 'tất cả') return getAllWorkouts();

    final (titleKeywords, muscleKeywords) = _mapFilterKeywords(category);

    final resultsById = <int, Workout>{};

    final byTitle = await _workoutRepository.getWorkoutsByTitleKeywords(
      titleKeywords,
    );
    for (final data in byTitle) {
      final workout = Workout.fromJson(data);
      resultsById[workout.id] = workout;
    }

    final exerciseIds = await _workoutRepository
        .getExerciseIdsByMuscleGroupKeywords(muscleKeywords);
    final workoutIds = await _workoutRepository.getWorkoutIdsByExerciseIds(
      exerciseIds,
    );
    final byIds = await _workoutRepository.getWorkoutsByIds(workoutIds);
    for (final data in byIds) {
      final workout = Workout.fromJson(data);
      resultsById[workout.id] = workout;
    }

    final merged = resultsById.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return merged;
  }

  (List<String> titleKeywords, List<String> muscleKeywords) _mapFilterKeywords(
    String category,
  ) {
    final key = category.trim().toLowerCase();
    switch (key) {
      case 'toàn thân':
        return (
          ['toàn thân', 'toan than', 'full body'],
          ['toàn thân', 'toan than', 'full body'],
        );
      case 'ngực':
        return (['ngực', 'nguc', 'chest'], ['ngực', 'nguc', 'chest']);
      case 'lưng':
        return (['lưng', 'lung', 'back'], ['lưng', 'lung', 'back']);
      case 'chân':
        return (['chân', 'chan', 'legs'], ['chân', 'chan', 'legs']);
      case 'tay':
        return (['tay', 'arms', 'arm'], ['tay', 'arms', 'arm']);
      case 'cardio':
        return (['cardio'], ['cardio']);
      case 'yoga':
        return (['yoga'], ['yoga']);
      case 'hiit':
        return (['hiit'], ['hiit']);
      default:
        return ([key], [key]);
    }
  }
}
