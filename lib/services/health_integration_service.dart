import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class HealthIntegrationService {
  final Health _health = Health();
  final types = [HealthDataType.STEPS,];
  List<HealthDataAccess> get permissions => types.map((e) => HealthDataAccess.READ).toList();

  Future<bool> requestPermissions() async {
    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      if (!status.isGranted) return false;
    }

    bool requested = await _health.requestAuthorization(types, permissions: permissions);
    return requested;
  }

  Future<int> getTodaySteps() async {
    if (kIsWeb) return 0;
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      bool? hasPermissions = await _health.hasPermissions(types, permissions: permissions);
      if (hasPermissions != true) {
        bool authorized = await requestPermissions();
        if (!authorized) return 0;
      }
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('Error fetching steps: $e');
      return 0;
    }
  }
}
