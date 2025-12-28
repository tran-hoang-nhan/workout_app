import '../repositories/health_repository.dart';
import '../models/health_data.dart';
import '../models/health_params.dart';
import '../utils/health_utils.dart' as health_utils;

class HealthService {
  final HealthRepository _repository;
  HealthService({HealthRepository? repository}): _repository = repository ?? HealthRepository();

  Future<HealthData?> checkHealthProfile(String userId) async {
    return await _repository.getHealthData(userId);
  }

  Future<void> saveHealthData(HealthUpdateParams params) async {
    await _repository.saveHealthData(params);
  }

  double calculateBMI(double weight, double height) => health_utils.calculateBMI(weight, height);
  String getBMICategory(double bmi) => health_utils.getBMICategory(bmi);
  int calculateBMR(double weight, double height, int age, String gender) =>health_utils.calculateBMR(weight, height, age, gender);
  int calculateTDEE(int bmr, String activityLevel) => health_utils.calculateTDEE(bmr, activityLevel);
  int calculateMaxHeartRate(int age) => health_utils.calculateMaxHeartRate(age);
  ({int min, int max}) calculateFatBurnZone(int maxHR) => health_utils.calculateFatBurnZone(maxHR);
  ({int min, int max}) calculateCardioZone(int maxHR) => health_utils.calculateCardioZone(maxHR);
}