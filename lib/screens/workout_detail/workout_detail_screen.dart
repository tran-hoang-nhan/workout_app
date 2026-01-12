import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';
import 'widgets/workout_header.dart';
import 'widgets/workout_description.dart';
import 'widgets/exercise_list_item.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final workoutDetailAsync = ref.watch(workoutDetailProvider(widget.workout.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkoutHeader(workout: widget.workout),
            
            if (widget.workout.description != null)
              WorkoutDescription(description: widget.workout.description!),

            // Workout Items (Exercises)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bài tập trong set',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  workoutDetailAsync.when(
                    data: (detail) {
                      final exercises = detail.exercises;
                      if (exercises.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Text('Chưa có bài tập nào trong set này'),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercises.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final workoutItem = detail.items[index];
                          final exercise = exercises[index];
                          return ExerciseListItem(
                            exercise: exercise,
                            workoutItem: workoutItem,
                            currentIndex: index + 1,
                            totalCount: exercises.length,
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (err, stack) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Lỗi: $err'),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
