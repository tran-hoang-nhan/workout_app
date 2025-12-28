import '../models/user.dart';
import '../repositories/profile_repository.dart';

class ProfileService {
  final ProfileRepository _repository;
  ProfileService({ProfileRepository? repository}) : _repository = repository ?? ProfileRepository();

  Future<UserStats> loadUserHealthData(String userId) async {
    return await _repository.loadUserHealthData(userId);
  }

  Future<void> updateWeight(String userId, double newWeight) async {
    await _repository.updateWeight(userId, newWeight);
  }

  Future<void> saveProfile(String userId, double weight, double height, int age) async {
    await _repository.saveProfile(userId, weight, height, age);
  }

  String formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
