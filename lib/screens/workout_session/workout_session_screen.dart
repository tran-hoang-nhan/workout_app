import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/workout.dart';
import '../../models/workout_item.dart';
import '../../models/exercise.dart';
import 'widgets/workout_completion_dialog.dart';
import 'widgets/workout_exercise_card.dart';
import 'workout_session_next_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/progress_provider.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final Workout workout;
  final List<WorkoutItem> items;
  final List<Exercise> exercises;

  const WorkoutSessionScreen({
    super.key,
    required this.workout,
    required this.items,
    required this.exercises,
  });

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  int _currentIndex = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _inRest = false;
  bool _started = false;
  bool _isCompleting = false;
  int _restElapsedSeconds = 0;
  final Stopwatch _sessionStopwatch = Stopwatch();

  WorkoutItem get _currentItem => widget.items[_currentIndex];
  Exercise get _currentExercise => widget.exercises[_currentIndex];

  @override
  void dispose() {
    _timer?.cancel();
    _sessionStopwatch.stop();
    super.dispose();
  }

  void _start() {
    if (!_sessionStopwatch.isRunning) {
      _restElapsedSeconds = 0;
      _sessionStopwatch.start();
    }
    final item = _currentItem;
    if ((item.durationSeconds ?? 0) > 0) {
      setState(() {
        _started = true;
        _inRest = false;
        _remainingSeconds = item.durationSeconds ?? 0;
      });
      _runTimer();
    } else {
      setState(() {
        _started = true;
        _inRest = false;
        _remainingSeconds = 0;
      });
    }
  }

  void _enterRest(int seconds) {
    setState(() {
      _inRest = true;
      _remainingSeconds = seconds;
    });
    _runTimer();
  }

  void _advanceToNext() {
    if (_currentIndex < widget.items.length - 1) {
      setState(() {
        _currentIndex++;
        _inRest = false;
        _started = false;
        _remainingSeconds = 0;
      });
    } else {
      _showCompletion();
    }
  }

  void _runTimer() {
    _timer?.cancel();

    if (_remainingSeconds <= 0) {
      final action = computeAfterTimerFinishedAction(
        currentIndex: _currentIndex,
        totalItems: widget.items.length,
        inRest: _inRest,
        item: _currentItem,
      );
      if (action.type == WorkoutSessionNextActionType.enterRest) {
        _enterRest(action.restSeconds ?? 0);
      } else if (action.type == WorkoutSessionNextActionType.advance) {
        _advanceToNext();
        return;
      } else {
        _showCompletion();
        return;
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          if (_inRest) {
            _restElapsedSeconds++;
          }
        });
      } else {
        t.cancel();
        if (!_inRest && (_currentItem.restSeconds ?? 0) > 0) {
          _enterRest(_currentItem.restSeconds ?? 0);
        } else {
          final action = computeAfterTimerFinishedAction(
            currentIndex: _currentIndex,
            totalItems: widget.items.length,
            inRest: _inRest,
            item: _currentItem,
          );
          if (action.type == WorkoutSessionNextActionType.enterRest) {
            _enterRest(action.restSeconds ?? 0);
          } else if (action.type == WorkoutSessionNextActionType.advance) {
            _advanceToNext();
          } else {
            _showCompletion();
          }
        }
      }
    });
  }

  void _next() {
    _timer?.cancel();
    final action = computeNextAction(
      currentIndex: _currentIndex,
      totalItems: widget.items.length,
      inRest: _inRest,
      item: _currentItem,
    );
    if (action.type == WorkoutSessionNextActionType.enterRest) {
      _enterRest(action.restSeconds ?? 0);
    } else if (action.type == WorkoutSessionNextActionType.advance) {
      _advanceToNext();
    } else {
      _showCompletion();
    }
  }

  int _plannedTotalSeconds() {
    int total = 0;
    for (final it in widget.items) {
      total += (it.durationSeconds ?? 0);
      total += (it.restSeconds ?? 0);
    }
    return total;
  }

  double _fallbackCaloriesPerMinute(String? category) {
    final c = (category ?? '').toLowerCase();
    if (c.contains('hiit')) return 12;
    if (c.contains('cardio')) return 10;
    if (c.contains('yoga')) return 4;
    return 8;
  }

  double _estimateCaloriesBurned({
    required int totalSeconds,
    required int restElapsedSeconds,
    required double? userWeightKg,
  }) {
    final activeSeconds = (totalSeconds - restElapsedSeconds).clamp(
      0,
      totalSeconds,
    );
    if (activeSeconds <= 0) return 0;

    final values = widget.exercises
        .map((e) => e.caloriesPerMinute)
        .whereType<double>()
        .where((v) => v.isFinite && v > 0)
        .toList();

    final basePerMinute = values.isNotEmpty
        ? values.reduce((a, b) => a + b) / values.length
        : _fallbackCaloriesPerMinute(widget.workout.category);

    final weightFactor =
        (userWeightKg != null && userWeightKg > 0 && userWeightKg.isFinite)
        ? (userWeightKg / 70).clamp(0.7, 1.6)
        : 1.0;

    final caloriesPerSecond = (basePerMinute / 60.0) * weightFactor;
    final calories = caloriesPerSecond * activeSeconds;
    if (!calories.isFinite || calories.isNaN) return 0;
    return double.parse(calories.toStringAsFixed(2));
  }

  Future<void> _showCompletion() async {
    if (_isCompleting) return;
    _isCompleting = true;
    final totalItems = widget.items.length;
    _timer?.cancel();
    _sessionStopwatch.stop();
    final actualSeconds = (_sessionStopwatch.elapsedMilliseconds / 1000)
        .floor();
    final totalSeconds = actualSeconds > 0
        ? actualSeconds
        : _plannedTotalSeconds();
    try {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId != null) {
        final weightKg = ref.read(healthFormProvider).weight;
        final calories = _estimateCaloriesBurned(
          totalSeconds: totalSeconds,
          restElapsedSeconds: _restElapsedSeconds,
          userWeightKg: weightKg,
        );
        await ref
            .read(progressRepositoryProvider)
            .recordWorkout(
              userId: userId,
              workoutId: widget.workout.id,
              workoutTitle: widget.workout.title,
              caloriesBurned: calories,
              durationSeconds: totalSeconds,
            );
        ref.invalidate(progressStatsProvider);
        ref.invalidate(workoutHistoryProvider);
      }
    } catch (e) {
      debugPrint('Error recording workout: $e');
    }

    if (!mounted) return;
    showWorkoutCompletionDialog(
      context,
      workoutTitle: widget.workout.title,
      totalItems: totalItems,
      totalSeconds: totalSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final ex = _currentExercise;
    final hasDuration = (item.durationSeconds ?? 0) > 0;
    final isTimeBased = hasDuration;

    return Scaffold(
      appBar: AppBar(title: Text('Tiến độ: ${widget.workout.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${_currentIndex + 1}/${widget.items.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: WorkoutExerciseCard(
                exercise: ex,
                item: item,
                started: _started,
                inRest: _inRest,
                isTimeBased: isTimeBased,
                remainingSeconds: _remainingSeconds,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _started ? _next : _start,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _started ? 'Tiếp' : 'Bắt đầu',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
