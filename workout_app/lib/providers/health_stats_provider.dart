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
  return HealthCalculations(
    bmi: bmi,
    bmiCategory: bmiCategory,
    bmr: bmr.toDouble(),
    tdee: tdee.toDouble(),
    maxHeartRate: maxHR,
  );
});
