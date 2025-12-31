import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class HealthIntegrationService {
  final Health _health = Health();

  // Define the types to get
  final types = [
    HealthDataType.STEPS,
  ];

  // Permissions for the types
  List<HealthDataAccess> get permissions => types.map((e) => HealthDataAccess.READ).toList();

  Future<bool> requestPermissions() async {
    // Request activity recognition permission for Android
    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) return false;
    }

    // Request health data permissions
    bool requested = await _health.requestAuthorization(types, permissions: permissions);
    return requested;
  }

  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Check if authorized
      bool? hasPermissions = await _health.hasPermissions(types, permissions: permissions);
      if (hasPermissions != true) {
        bool authorized = await requestPermissions();
        if (!authorized) return 0;
      }

      // Fetch steps
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('Error fetching steps: $e');
      return 0;
    }
  }
}
