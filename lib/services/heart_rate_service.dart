import 'package:health/health.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HeartRateService {
  final Health _health = Health();
  final Logger _logger = Logger();

  // 1. Lấy dữ liệu để vẽ biểu đồ (Trong 24h qua)
  Future<List<HealthDataPoint>> fetchHeartRateData() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    final types = [
      HealthDataType.HEART_RATE, 
      HealthDataType.RESTING_HEART_RATE,
    ];
    if (kIsWeb) return [];

    bool requested = await _health.requestAuthorization(types);
    if (!requested) {
      _logger.e('Authorization not granted for Heart Rate data');
      return [];
    }

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(startTime: midnight, endTime: now, types: [HealthDataType.HEART_RATE],);
      healthData.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
      return _health.removeDuplicates(healthData);
    } catch (e) {
      _logger.e('Error fetching heart rate data: $e');
      return [];
    }
  }

  // 2. Lấy nhịp tim nghỉ (Resting Heart Rate)
  Future<double?> fetchRestingHeartRate() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (kIsWeb) return null;
    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes( startTime: yesterday, endTime: now, types: [HealthDataType.RESTING_HEART_RATE],);
      if (healthData.isEmpty) return null;
      healthData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      return double.tryParse(healthData.first.value.toString());
    } catch (e) {
      _logger.e('Error fetching resting heart rate: $e');
      return null;
    }
  }

  // 3. Phân tích thời gian trong các vùng nhịp tim
  Future<Map<String, int>> fetchTimeInZones(int maxHR) async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    if (kIsWeb) {
      return {
        'Fat Burn': 0,
        'Cardio': 0,
        'Peak': 0,
      };
    }
    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(startTime: midnight, endTime: now, types: [HealthDataType.HEART_RATE],);
      int fatBurnMinutes = 0;
      int cardioMinutes = 0;
      int peakMinutes = 0;

      for (int i = 0; i < healthData.length; i++) {
        final bpm = double.tryParse(healthData[i].value.toString()) ?? 0;
        final duration = healthData[i].dateTo.difference(healthData[i].dateFrom).inMinutes;
        final actualDuration = duration > 0 ? duration : 1;
        
        if (bpm >= maxHR * 0.85) {
          peakMinutes += actualDuration;
        } else if (bpm >= maxHR * 0.70) {
          cardioMinutes += actualDuration;
        } else if (bpm >= maxHR * 0.60) {
          fatBurnMinutes += actualDuration;
        }
      }

      return {
        'Fat Burn': fatBurnMinutes,
        'Cardio': cardioMinutes,
        'Peak': peakMinutes,
      };
    } catch (e) {
      _logger.e('Error fetching time in zones: $e');
      return {
        'Fat Burn': 0,
        'Cardio': 0,
        'Peak': 0,
      };
    }
  }
}
