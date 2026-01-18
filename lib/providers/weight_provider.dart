import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/weight_repository.dart';
import '../services/weight_service.dart';
import '../models/body_metric.dart';
import '../utils/app_error.dart';
import './auth_provider.dart'; 

final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  return WeightRepository();
});

final weightServiceProvider = Provider<WeightService>((ref) {
  final repo = ref.watch(weightRepositoryProvider);
  return WeightService(repository: repo);
});


final weightHistoryProvider = FutureProvider.autoDispose<List<BodyMetric>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return [];
  final service = ref.watch(weightServiceProvider);
  return service.loadHistory(userId);
});

final userHeightProvider = FutureProvider.autoDispose<double>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return 0.0;
  final repo = ref.watch(weightRepositoryProvider);
  return (await repo.getUserHeight(userId)) ?? 0.0;
});

final loadWeightDataProvider = FutureProvider.autoDispose<WeightData>((ref) async {
  final history = await ref.watch(weightHistoryProvider.future);
  final height = await ref.watch(userHeightProvider.future);
  double currentWeight = 0;
  if (history.isNotEmpty) {
    currentWeight = history.first.weight;
  }
  return WeightData(
    weight: currentWeight,
    height: height,
    weightHistory: history,
  );
});

final weightControllerProvider = AsyncNotifierProvider<WeightController, void>(() {
  return WeightController();
});

class WeightController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addWeight(double weight, {DateTime? date}) async {
    state = const AsyncValue.loading();
    final userId = await ref.read(currentUserIdProvider.future);
    if (userId == null) return;
    state = await AsyncValue.guard(() async {
      try {
        final service = ref.read(weightServiceProvider);
        await service.logNewWeight(userId: userId, weight: weight, date: date);
        ref.invalidate(weightHistoryProvider);
        ref.invalidate(loadWeightDataProvider);
      } catch (e, st) {
        throw handleException(e, st);
      }
    });
  }

  Future<void> deleteWeight(int id) async {
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(weightServiceProvider).deleteEntry(id);
        ref.invalidate(weightHistoryProvider);
        ref.invalidate(loadWeightDataProvider);
      } catch (e, st) {
        throw handleException(e, st);
      }
    });
  }
}