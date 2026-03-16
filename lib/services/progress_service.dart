import 'package:shared/shared.dart';
import '../repositories/progress_repository.dart';
import '../repositories/progress_user_repository.dart';

class ProgressService {
  final ProgressRepository _historyRepo;
  final ProgressUserRepository _dailyRepo;

  ProgressService({ProgressRepository? historyRepo,ProgressUserRepository? dailyRepo,}): _historyRepo = historyRepo ?? ProgressRepository(),_dailyRepo = dailyRepo ?? ProgressUserRepository();

  Future<List<WorkoutHistory>> getWorkoutHistory(String userId) async {
    return _historyRepo.getWorkoutHistory(userId);
  }

  Future<ProgressUser?> getDailyProgress(String userId, DateTime date) async {
    return _dailyRepo.getProgress(userId, date);
  }

  Future<void> logWorkout(WorkoutHistory history) async {
    await _historyRepo.logWorkout(history);
  }
}
