import 'package:shared/shared.dart';
import '../services/api_client.dart';

class WeightRepository {
  final ApiClient _apiClient;
  WeightRepository({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<List<BodyMetric>> getWeightHistory(String userId) async {
    return _apiClient.getWeightHistory(userId);
  }

  Future<void> addWeightRecord({required String userId, required double weight, required double? bmi, required DateTime date,}) async {
    await _apiClient.addWeight(userId, weight, bmi, date);
  }

  Future<void> deleteWeightRecord(int id) async {
    await _apiClient.deleteWeight(id);
  }

  Future<double?> getUserHeight(String userId) async {
    final healthData = await _apiClient.getHealthData(userId);
    return healthData?.height;
  }

  Future<BodyMetric?> getLatestMetrics(String userId) async {
    final history = await getWeightHistory(userId);
    return history.isNotEmpty ? history.first : null;
  }
}
