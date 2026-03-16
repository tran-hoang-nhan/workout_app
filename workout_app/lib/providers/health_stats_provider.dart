import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'health_provider.dart';

final healthCalculationsProvider = Provider<HealthCalculations>((ref) {
  final form = ref.watch(healthFormProvider);
  final service = ref.watch(healthServiceProvider);
  final bmi = service.calculateBMI(form.weight, form.height);
  final bmiCategory = service.getBMICategory(bmi);
  final bmr = service.calculateBMR(
    form.weight,
    form.height,
    form.age,
    form.gender ?? 'male',
  );
  final tdee = service.calculateTDEE(bmr, form.activityLevel);
  final maxHR = service.calculateMaxHeartRate(form.age);
  final zone1 = service.calculateZone1(maxHR);
  final zone2 = service.calculateZone2(maxHR);
  final zone3 = service.calculateZone3(maxHR);
  final zone4 = service.calculateZone4(maxHR);
  final zone5 = service.calculateZone5(maxHR);

  return HealthCalculations(
    bmi: bmi,
    bmiCategory: bmiCategory,
    bmr: bmr.toDouble(),
    tdee: tdee.toDouble(),
    maxHeartRate: maxHR,
    zone1: zone1,
    zone2: zone2,
    zone3: zone3,
    zone4: zone4,
    zone5: zone5,
  );
});
