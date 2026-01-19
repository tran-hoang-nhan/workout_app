import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class RunningTrackerService {
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<StepCount>? _stepCountStream;
  Timer? _timer;
  Position? _lastPosition;
  int _initialSteps = -1;

  void Function(double distanceDelta)? onDistanceUpdated;
  void Function(int stepsDelta)? onStepsUpdated;
  void Function(int seconds)? onTimerTick;
  void Function(bool available)? onPedometerStatusChanged;
  void Function()? onTrackingStopped;

  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<bool> checkPedometerAvailability() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final activityStatus = await Permission.activityRecognition.request();
      return activityStatus.isGranted;
    }
    return true; 
  }

  void startTracking({bool usePedometer = true}) {
    _lastPosition = null;
    _initialSteps = -1;

    // Timer
    int seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds++;
      onTimerTick?.call(seconds);
    });

    // Pedometer
    if (usePedometer) {
      _stepCountStream = Pedometer.stepCountStream.listen(
        (event) {
          if (_initialSteps == -1) {
            _initialSteps = event.steps;
          }
          onStepsUpdated?.call(event.steps - _initialSteps);
        },
        onError: (e) {
          debugPrint('Pedometer Error: $e');
          onPedometerStatusChanged?.call(false);
        },
      );
    }

    // GPS
    LocationSettings locationSettings;
    if (kIsWeb) {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    } else if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Đang theo dõi quãng đường chạy bộ của bạn",
          notificationTitle: "Chạy bộ đang hoạt động",
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_lastPosition != null) {
        double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        onDistanceUpdated?.call(distance);
      }
      _lastPosition = position;
    });
  }

  void stopTracking() {
    _timer?.cancel();
    _positionStream?.cancel();
    _stepCountStream?.cancel();
    _timer = null;
    _positionStream = null;
    _stepCountStream = null;
    onTrackingStopped?.call();
  }

  void dispose() {
    stopTracking();
  }
}
