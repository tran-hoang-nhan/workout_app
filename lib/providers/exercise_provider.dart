import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExercises();
});

final exerciseByIdProvider = FutureProvider.family<Exercise?, int>((ref, id) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExerciseById(id);
});

final searchExercisesProvider = FutureProvider.family<List<Exercise>, String>((ref, query) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.searchExercises(query);
});

final exercisesByMuscleGroupProvider = FutureProvider.family<List<Exercise>, String>((ref, muscleGroup) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return repository.getExercisesByMuscleGroup(muscleGroup);
});
