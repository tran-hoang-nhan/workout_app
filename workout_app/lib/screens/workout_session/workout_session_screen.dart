import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:workout_app/screens/workout_session/widgets/workout_completion_dialog.dart';
import 'package:workout_app/screens/workout_session/widgets/workout_exercise_card.dart';
import 'package:workout_app/screens/workout_session/widgets/workout_countdown_overlay.dart';
import 'package:workout_app/screens/workout_session/widgets/exit_workout_dialog.dart';
import 'package:workout_app/constants/app_constants.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/progress_user_provider.dart';
import '../../providers/daily_stats_provider.dart';

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

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _started = false;
  bool _inRest = false;
  int _remainingSeconds = 0;
  bool _inCountdown = true;
  bool _isCompleting = false;
  bool _isPaused = false;
  DateTime? _targetEndTime;

  Timer? _timer;
  final Stopwatch _sessionStopwatch = Stopwatch();
  double _accumulatedCalories = 0;
  DateTime? _lastStepStartTime;

  /// Đang mở dialog thoát — tạm dừng đếm ngược + đồng hồ bài tập.
  bool _haltForExitDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _timer?.cancel();
    _sessionStopwatch.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Tự động tạm dừng khi app vào background
      if (_started && !_inCountdown && !_isPaused) {
        _togglePause(false);
      }
    }
  }

  WorkoutItem get _currentItem => widget.items[_currentIndex];

  void _startPreparation() {
    setState(() {
      _inCountdown = true;
      _started = false;
    });
  }

  void _start() {
    HapticFeedback.lightImpact();
    if (!_sessionStopwatch.isRunning) {
      _sessionStopwatch.start();
    }
    final item = _currentItem;
    setState(() {
      _started = true;
      _inRest = false;
      _inCountdown = false;
      _isPaused = false;
      _remainingSeconds = item.durationSeconds ?? 0;
      _lastStepStartTime = DateTime.now();
    });
    
    if (_remainingSeconds > 0) {
      _targetEndTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
      _runTimer();
    }
  }

  void _enterRest(int seconds) {
    setState(() {
      _inRest = true;
      _remainingSeconds = seconds;
      _started = true;
      _isPaused = false;
      _targetEndTime = DateTime.now().add(Duration(seconds: seconds));
      _lastStepStartTime = DateTime.now();
    });
    _runTimer();
  }

  void _advanceToNext({bool autoStart = false}) {
    if (_currentIndex < widget.items.length - 1) {
      setState(() {
        _currentIndex++;
        _inRest = false;
        _started = autoStart;
        _remainingSeconds = 0;
      });
      if (autoStart) {
        _startPreparation();
      }
    } else {
      // Trước khi hoàn thành, cộng nốt calo cuối cùng
      _accumulatedCalories = _caloriesBurnedSoFar();
      _showCompletion();
    }
  }

  void _runTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (_isPaused || _remainingSeconds <= 0 || _targetEndTime == null) return;
      
      final now = DateTime.now();
      final diff = _targetEndTime!.difference(now).inSeconds;

      if (diff != _remainingSeconds) {
        setState(() {
          _remainingSeconds = diff.clamp(0, 9999);
        });
        
        if (_remainingSeconds <= 3 && _remainingSeconds > 0) {
          HapticFeedback.lightImpact();
        }
        
        if (_remainingSeconds <= 0) {
          t.cancel();
          _handleTimerFinished();
        }
      }
    });
  }

  void _togglePause([bool? forcePlaying]) {
    if (!_started || _inCountdown) return;
    final bool shouldPause = forcePlaying != null ? !forcePlaying : !_isPaused;
    if (shouldPause == _isPaused) return;

    setState(() {
      _isPaused = shouldPause;
    });

    HapticFeedback.lightImpact();

    if (_isPaused) {
      _timer?.cancel();
      _sessionStopwatch.stop();
      _accumulatedCalories = _caloriesBurnedSoFar();
      _targetEndTime = null;
      _lastStepStartTime = null;
    } else {
      _sessionStopwatch.start();
      _lastStepStartTime = DateTime.now();
      if (_remainingSeconds > 0) {
        _targetEndTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
        _runTimer();
      }
    }
  }

  void _handleTimerFinished() {
    final isLast = _currentIndex >= widget.items.length - 1;
    if (!_inRest && !isLast && (_currentItem.restSeconds ?? 0) > 0) {
      _enterRest(_currentItem.restSeconds ?? 0);
    } else {
      _advanceToNext(autoStart: true);
    }
  }

  void _next() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    if (_inRest) {
      _advanceToNext(autoStart: true);
      return;
    }

    final isLast = _currentIndex >= widget.items.length - 1;
    final restSeconds = _currentItem.restSeconds ?? 0;

    if (isLast || restSeconds <= 0) {
      _accumulatedCalories = _caloriesBurnedSoFar();
      _advanceToNext(autoStart: true);
    } else {
      _accumulatedCalories = _caloriesBurnedSoFar();
      _enterRest(restSeconds);
    }
  }

  Future<void> _showCompletion() async {
    final actualSeconds = (_sessionStopwatch.elapsedMilliseconds / 1000).floor();
    final calories = _caloriesBurnedSoFar();
    
    // Log workout completion to backend
    try {
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.id;
      if (userId != null) {
        final history = WorkoutHistory(
          userId: userId,
          workoutId: widget.workout.id != 0 ? widget.workout.id : null,
          workoutTitleSnapshot: widget.workout.title,
          totalCaloriesBurned: calories,
          durationSeconds: actualSeconds,
          completedAt: DateTime.now(),
        );
        await ref.read(workoutServiceProvider).logWorkout(history);
        
        // Invalidate progress providers to refresh UI
        final now = DateTime.now();
        ref.invalidate(progressDailyProvider(now));
        ref.invalidate(dailyStatsProvider(now));
      }
    } catch (e) {
    }

    HapticFeedback.mediumImpact();

    if (!mounted) return;
    showWorkoutCompletionDialog(
      context,
      workoutTitle: widget.workout.title,
      totalItems: widget.items.length,
      totalSeconds: actualSeconds,
      calories: calories,
    );
  }

  /// Tính Calo dựa trên caloriesPerMinute của từng bài tập hoặc mặc định 7.0.
  double _caloriesBurnedSoFar() {
    double currentRate = 7.0; // Default
    if (_inRest) {
      currentRate = 3.0; // Rest burns less
    } else if (_currentIndex < widget.exercises.length) {
      currentRate = widget.exercises[_currentIndex].caloriesPerMinute ?? 7.0;
    }

    double currentStepCalories = 0;
    if (_lastStepStartTime != null && !_isPaused) {
      final now = DateTime.now();
      final ms = now.difference(_lastStepStartTime!).inMilliseconds;
      currentStepCalories = (ms / 60000.0) * currentRate;
    }

    return _accumulatedCalories + currentStepCalories;
  }

  Future<void> _handleExit() async {
    final hadPausedBefore = _isPaused;
    setState(() {
      _haltForExitDialog = true;
    });

    if (_started && !_inCountdown && !hadPausedBefore) {
      _togglePause(false);
    }

    final elapsedSeconds = (_sessionStopwatch.elapsedMilliseconds / 1000).floor();
    final calories = _caloriesBurnedSoFar();

    final shouldExit = await showExitWorkoutDialog(
      context,
      completedExercises: _currentIndex,
      totalExercises: widget.items.length,
      elapsedSeconds: elapsedSeconds,
      calories: calories,
    );

    if (!mounted) return;

    setState(() {
      _haltForExitDialog = false;
    });

    if (shouldExit) {
      Navigator.of(context).pop();
      return;
    }

    if (_started && !_inCountdown && !hadPausedBefore && _isPaused) {
      _togglePause(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNext = _currentIndex < widget.items.length - 1;
    final displayIndex = _inRest && hasNext ? _currentIndex + 1 : _currentIndex;
    final displayExercise = widget.exercises[displayIndex];
    final displayItem = widget.items[displayIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: _buildBackgroundDecoration(),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    children: [
                      _SessionProgressBar(
                        currentIndex: _currentIndex,
                        totalItems: widget.items.length,
                      ),
                      const SizedBox(height: 12),
                      _SessionHeader(
                        currentIndex: _currentIndex,
                        totalItems: widget.items.length,
                        onExit: _handleExit,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: WorkoutExerciseCard(
                            key: ValueKey('$_currentIndex-$_inRest'),
                            exercise: displayExercise,
                            item: displayItem,
                            started: _started && !_inCountdown,
                            inRest: _inRest,
                            isPaused: _isPaused,
                            onPlayPauseToggle: _togglePause,
                            isTimeBased: (displayItem.durationSeconds ?? 0) > 0,
                            remainingSeconds: _remainingSeconds,
                            exerciseTotalSeconds: displayItem.durationSeconds ?? 0,
                            restTotalSeconds: displayItem.restSeconds ?? 0,
                            isPreview: _inRest,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _inCountdown
                            ? null
                            : (_started ? _next : _start),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(64),
                          backgroundColor: _inRest ? Colors.orange : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.xl)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_inRest ? Icons.skip_next_rounded : (_started ? Icons.arrow_forward_rounded : Icons.play_arrow_rounded), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              _inCountdown
                                  ? 'Chuẩn bị...'
                                  : (_started
                                      ? (_inRest
                                          ? 'Bỏ qua nghỉ'
                                          : (hasNext ? 'Tiếp theo' : 'Hoàn thành'))
                                      : 'Bắt đầu ngay'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_inCountdown)
              WorkoutCountdownOverlay(
                text: _currentIndex == 0 ? 'BẮT ĐẦU BUỔI TẬP' : 'CHUẨN BỊ BÀI TIẾP',
                paused: _haltForExitDialog,
                onComplete: _start,
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    final colors = _inRest
        ? [
            Colors.orange.withValues(alpha: 0.12),
            Colors.orange.withValues(alpha: 0.04),
            Colors.orange.withValues(alpha: 0.08),
          ]
        : [
            AppColors.bgLight,
            AppColors.white.withValues(alpha: 0.5),
            AppColors.bgLight,
          ];

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  final int currentIndex;
  final int totalItems;
  final VoidCallback onExit;

  const _SessionHeader({required this.currentIndex, required this.totalItems, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BÀI TẬP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary.withValues(alpha: 0.6), letterSpacing: 1.2)),
            const SizedBox(height: 2),
            Row(
              children: [
                Text('${currentIndex + 1}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.black, height: 1.1)),
                Text(' / $totalItems', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.black.withValues(alpha: 0.3))),
              ],
            ),
          ],
        ),
        IconButton(onPressed: onExit, icon: const Icon(Icons.close_rounded, color: AppColors.black, size: 22)),
      ],
    );
  }
}

class _SessionProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalItems;
  const _SessionProgressBar({required this.currentIndex, required this.totalItems});

  @override
  Widget build(BuildContext context) {
    final progress = (currentIndex + 1) / totalItems;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        tween: Tween<double>(begin: 0, end: progress),
        builder: (context, value, _) {
          return LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          );
        },
      ),
    );
  }
}
