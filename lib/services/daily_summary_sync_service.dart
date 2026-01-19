import 'package:health/health.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/daily_summary.dart';
import '../repositories/daily_summary_repository.dart';
import '../repositories/health_repository.dart';
import '../services/heart_rate_service.dart';
import 'package:logger/logger.dart';

class DailySummarySyncService {
  final Health _health = Health();
  final DailySummaryRepository _repository = DailySummaryRepository();
  final HealthRepository _healthRepo = HealthRepository();
  final HeartRateService _heartRateService = HeartRateService();
  final Logger _logger = Logger();

  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
  ];

  Future<void> syncTodayData(String userId) async {
    if (kIsWeb) return;

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      bool requested = await _health.requestAuthorization(_types);
      if (!requested) {
        _logger.e('Authorization not granted for Health data sync');
        return;
      }

      int steps = await _health.getTotalStepsInInterval(midnight, now) ?? 0;
      List<HealthDataPoint> dataPoints = await _health.getHealthDataFromTypes(startTime: midnight, endTime: now, types: _types,);
      double calories = 0;
      int minutes = 0;
      double distance = 0;
      
      List<int> hrValues = [];
      double? restingHR;

      for (var point in dataPoints) {
        final value = double.tryParse(point.value.toString()) ?? 0;
        if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          calories += value;
        } else if (point.type == HealthDataType.DISTANCE_DELTA) {
          distance += value;
        } else if (point.type == HealthDataType.HEART_RATE) {
          hrValues.add(value.toInt());
        } else if (point.type == HealthDataType.RESTING_HEART_RATE) {
          restingHR = value;
        }
      }

      // 2. Tính toán nhịp tim
      int? avgHR = hrValues.isNotEmpty ? (hrValues.reduce((a, b) => a + b) / hrValues.length).round() : null;
      int? minHR = hrValues.isNotEmpty ? hrValues.reduce((a, b) => a < b ? a : b) : null;
      int? maxHR = hrValues.isNotEmpty ? hrValues.reduce((a, b) => a > b ? a : b) : null;

      // 3. Tính toán vùng nhịp tim
      final healthProfile = await _healthRepo.getHealthData(userId);
      final age = healthProfile?.age ?? 25;
      final calculatedMaxHR = 220 - age;
      final zones = await _heartRateService.fetchTimeInZones(calculatedMaxHR);

      // 4. Tạo đối tượng và Upsert
      final summary = DailySummary(
        userId: userId,
        date: midnight,
        stepsCount: steps,
        activeEnergyBurned: calories,
        activeMinutes: minutes,
        distanceMeters: distance,
        avgHeartRate: avgHR,
        minHeartRate: minHR,
        maxHeartRate: maxHR,
        restingHeartRate: restingHR?.toInt(),
        heartRateZones: zones,
      );

      await _repository.upsertDailySummary(summary);
      _logger.i('Successfully synced daily summary for $userId');
    } catch (e) {
      _logger.e('Error syncing daily summary: $e');
    }
  }
}
