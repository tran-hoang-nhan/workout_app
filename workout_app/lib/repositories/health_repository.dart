import 'package:shared/shared.dart';
import '../api/api_client.dart';

class HealthRepository {
  final ApiClient _apiClient;
  HealthRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<HealthData?> getHealthData(String userId) async {
    return _apiClient.getHealthData(userId);
  }

  Future<void> updateFullProfile(HealthUpdateParams params) async {
    await _apiClient.updateHealthProfile(params);
  }

  Future<void> updateQuickMetrics({required String userId, double? weight, double? height,}) async {
    await _apiClient.updateQuickMetrics(
      userId: userId, 
      weight: weight, 
      height: height
    );
  }

  Future<List<BodyMetric>> getWeightHistory(String userId) async {
    return _apiClient.getWeightHistory(userId);
  }

  Future<void> addWeightRecord(String userId, double weight, double? bmi, DateTime date,) async {
    await _apiClient.addWeight(userId, weight, bmi, date);
  }
}
