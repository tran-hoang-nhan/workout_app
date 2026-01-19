class RunningTrackerState {
  final bool isTracking;
  final double totalDistance;
  final int secondsElapsed;
  final int currentSessionSteps;
  final bool pedometerAvailable;

  RunningTrackerState({
    this.isTracking = false,
    this.totalDistance = 0.0,
    this.secondsElapsed = 0,
    this.currentSessionSteps = 0,
    this.pedometerAvailable = false,
  });

  RunningTrackerState copyWith({bool? isTracking, double? totalDistance, int? secondsElapsed, int? currentSessionSteps, bool? pedometerAvailable,}) {
    return RunningTrackerState(
      isTracking: isTracking ?? this.isTracking,
      totalDistance: totalDistance ?? this.totalDistance,
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      currentSessionSteps: currentSessionSteps ?? this.currentSessionSteps,
      pedometerAvailable: pedometerAvailable ?? this.pedometerAvailable,
    );
  }
}
