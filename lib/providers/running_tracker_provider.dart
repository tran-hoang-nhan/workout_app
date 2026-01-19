import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/running_tracker_state.dart';
import '../services/running_tracker_service.dart';
import '../models/progress_user.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_user_provider.dart';

class RunningTrackerNotifier extends Notifier<RunningTrackerState> {
  static const double _stepsPerMeter = 1.31;
  late final RunningTrackerService _service;

  @override
  RunningTrackerState build() {
    _service = RunningTrackerService();
    
    _service.onDistanceUpdated = (delta) {
      state = state.copyWith(totalDistance: state.totalDistance + delta);
    };
    
    _service.onStepsUpdated = (steps) {
      state = state.copyWith(currentSessionSteps: steps);
    };
    
    _service.onTimerTick = (seconds) {
      state = state.copyWith(secondsElapsed: seconds);
    };
    
    _service.onPedometerStatusChanged = (available) {
      state = state.copyWith(pedometerAvailable: available);
    };

    ref.onDispose(() {
      _service.dispose();
    });

    return RunningTrackerState();
  }

  int get stepsCount {
    if (state.pedometerAvailable && state.currentSessionSteps > 0) {
      return state.currentSessionSteps;
    }
    return (state.totalDistance * _stepsPerMeter).round();
  }

  Future<void> toggleTracking() async {
    if (state.isTracking) {
      await stopTracking();
    } else {
      await startTracking();
    }
  }

  Future<void> startTracking() async {
    final hasPermission = await _service.requestPermissions();
    if (!hasPermission) return;

    final pedAvail = await _service.checkPedometerAvailability();
    
    state = RunningTrackerState(
      isTracking: true,
      pedometerAvailable: pedAvail,
    );

    _service.startTracking(usePedometer: pedAvail);
  }

  Future<void> stopTracking() async {
    final finalSteps = stepsCount;
    _service.stopTracking();

    if (finalSteps > 0) {
      await _saveProgress(finalSteps);
    }

    state = RunningTrackerState(isTracking: false);
  }

  Future<void> _saveProgress(int stepsToAdd) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      final repo = ref.read(progressUserRepositoryProvider);
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) return;

      final existingProgress = await repo.getProgress(userId, today);
      final updatedProgress = (existingProgress ?? ProgressUser(userId: userId, date: today)).copyWith(
        steps: (existingProgress?.steps ?? 0) + stepsToAdd,
      );

      await repo.saveProgress(updatedProgress);
      ref.invalidate(progressDailyProvider(today));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }
}

final runningTrackerProvider = NotifierProvider<RunningTrackerNotifier, RunningTrackerState>(() {
  return RunningTrackerNotifier();
});
