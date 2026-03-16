import '../repositories/weight_repository.dart';
import 'package:shared/shared.dart';

class WeightService {
  final WeightRepository _repository;
  WeightService({WeightRepository? repository}): _repository = repository ?? WeightRepository();

  Future<List<BodyMetric>> loadHistory(String userId) {
    return _repository.getWeightHistory(userId);
  }

  Future<void> deleteEntry(int id) {
    return _repository.deleteWeightRecord(id);
  }

  Future<void> logNewWeight({required String userId,required double weight,DateTime? date,}) async {
    await _repository.addWeightRecord(
      userId: userId,
      weight: weight,
      bmi: null,
      date: date ?? DateTime.now(),
    );
  }
}
