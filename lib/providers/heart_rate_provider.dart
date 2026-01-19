import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import '../services/heart_rate_service.dart';

final heartRateServiceProvider = Provider<HeartRateService>((ref) {
  return HeartRateService();
});

final heartRateDataProvider = FutureProvider<List<HealthDataPoint>>((ref) async {
  final service = ref.watch(heartRateServiceProvider);
  return service.fetchHeartRateData();
});

final restingHeartRateProvider = FutureProvider<double?>((ref) async {
  final service = ref.watch(heartRateServiceProvider);
  return service.fetchRestingHeartRate();
});

final timeInZonesProvider = FutureProvider.family<Map<String, int>, int>((ref, maxHR) async {
  final service = ref.watch(heartRateServiceProvider);
  return service.fetchTimeInZones(maxHR);
});
