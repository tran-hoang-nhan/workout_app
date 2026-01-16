import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/workout.dart';
import '../../models/workout_item.dart';
import '../../models/exercise.dart';
import '../exercises/widgets/exercise_animation_widget.dart';

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

  WorkoutItem get _currentItem => widget.items[_currentIndex];
  Exercise get _currentExercise => widget.exercises[_currentIndex];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
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

  void _runTimer() {
    _timer?.cancel();

    if (_remainingSeconds <= 0) {
      if (!_inRest && (_currentItem.restSeconds ?? 0) > 0) {
        setState(() {
          _inRest = true;
          _remainingSeconds = _currentItem.restSeconds ?? 0;
        });
      } else {
        _next();
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
          setState(() {
            _inRest = true;
            _remainingSeconds = _currentItem.restSeconds ?? 0;
          });
          _runTimer();
        } else {
          _next();
        }
      }
    });
  }

  void _next() {
    _timer?.cancel();
    final reps = _currentItem.reps ?? 0;
    final rest = _currentItem.restSeconds ?? 0;
    if (!_inRest && reps > 0 && rest > 0) {
      setState(() {
        _inRest = true;
        _remainingSeconds = rest;
      });
      _runTimer();
      return;
    }
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

  int _plannedTotalSeconds() {
    int total = 0;
    for (final it in widget.items) {
      total += (it.durationSeconds ?? 0);
      total += (it.restSeconds ?? 0);
    }
    return total;
  }

  void _showCompletion() {
    final totalItems = widget.items.length;
    final totalSeconds = _plannedTotalSeconds();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withValues(alpha: 0.1),
                  Colors.blue.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hoàn thành set!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.workout.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(label: 'Bài', value: '$totalItems'),
                    _StatChip(label: 'Thời gian', value: '$totalSeconds giây'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Về trang trước'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final ex = _currentExercise;
    final hasDuration = (item.durationSeconds ?? 0) > 0;
    final hasReps = (item.reps ?? 0) > 0;
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
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (ex.animationUrl != null &&
                                ex.animationUrl!.isNotEmpty)
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ExerciseAnimationWidget(
                                    animationUrl: ex.animationUrl!,
                                    height: 240,
                                  ),
                                ),
                              )
                            else if (ex.thumbnailUrl != null &&
                                ex.thumbnailUrl!.isNotEmpty)
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: ex.thumbnailUrl!,
                                    height: 240,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 240,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          height: 240,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Center(
                              child: Builder(
                                builder: (_) {
                                  final chips = <Widget>[];
                                  if (hasDuration) {
                                    chips.add(
                                      _InfoChip(
                                        icon: Icons.timer_outlined,
                                        color: Colors.purple,
                                        text:
                                            'Tập: ${item.durationSeconds} giây',
                                      ),
                                    );
                                  } else if (hasReps) {
                                    chips.add(
                                      _InfoChip(
                                        icon: Icons.repeat,
                                        color: Colors.green,
                                        text: 'Số lần: ${item.reps}',
                                      ),
                                    );
                                  } else {
                                    chips.add(
                                      _InfoChip(
                                        icon: Icons.fitness_center,
                                        color: Colors.blueGrey,
                                        text: 'Tập tự do',
                                      ),
                                    );
                                  }
                                  if ((item.restSeconds ?? 0) > 0) {
                                    chips.add(
                                      _InfoChip(
                                        icon: Icons.pause_circle_outline,
                                        color: Colors.red,
                                        text: 'Nghỉ: ${item.restSeconds} giây',
                                      ),
                                    );
                                  }
                                  return Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: chips,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (ex.description != null)
                              Text(
                                ex.description!,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_started)
                      Column(
                        children: [
                          Text(
                            _inRest
                                ? 'Nghỉ'
                                : (isTimeBased
                                      ? 'Đang tập'
                                      : 'Tập theo số lần'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isTimeBased || _inRest) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${_remainingSeconds}s',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      )
                    else
                      Center(
                        child: Builder(
                          builder: (_) {
                            String text;
                            if (hasDuration) {
                              text =
                                  'Tập ${item.durationSeconds} giây${(item.restSeconds ?? 0) > 0 ? ' • Nghỉ ${item.restSeconds} giây' : ''}';
                            } else if (hasReps) {
                              text =
                                  'Số lần ${item.reps}${(item.restSeconds ?? 0) > 0 ? ' • Nghỉ ${item.restSeconds} giây' : ''}';
                            } else {
                              text =
                                  'Tập tự do${(item.restSeconds ?? 0) > 0 ? ' • Nghỉ ${item.restSeconds} giây' : ''}';
                            }
                            return Text(
                              text,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),
                  ],
                ),
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _InfoChip({required this.icon, required this.text, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.black54),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
