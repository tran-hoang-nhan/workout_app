import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/workout.dart';
import '../../models/workout_item.dart';
import '../../models/exercise.dart';
import 'widgets/workout_completion_dialog.dart';
import 'widgets/workout_exercise_card.dart';
import 'workout_session_next_action.dart';

class WorkoutSessionScreen extends StatefulWidget {
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
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _currentIndex = 0;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _inRest = false;
  bool _started = false;
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

  void _showCompletion() {
    final totalItems = widget.items.length;
    _timer?.cancel();
    _sessionStopwatch.stop();
    final totalSeconds = (_sessionStopwatch.elapsedMilliseconds / 1000).floor();
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
