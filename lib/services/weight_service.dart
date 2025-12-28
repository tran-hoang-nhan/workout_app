import '../repositories/weight_repository.dart';
import '../models/body_metric.dart';
import '../utils/health_utils.dart';

class WeightService {
  final WeightRepository _repository;
  WeightService({WeightRepository? repository}): _repository = repository ?? WeightRepository();

  Future<List<BodyMetric>> loadHistory(String userId) {
    return _repository.getWeightHistory(userId);
  }

  Future<void> deleteEntry(int id) {
    return _repository.deleteWeightRecord(id);
  }

  Future<void> logNewWeight({required String userId, required double weight, DateTime? date,}) async {
    final height = await _repository.getUserHeight(userId);
    double? bmi;
    if (height != null && height > 0) {
      bmi = calculateBMI(weight, height);
    }
    await _repository.addWeightRecord( userId: userId, weight: weight, bmi: bmi, date: date ?? DateTime.now(),);
  }
}