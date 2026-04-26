import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../repositories/weight_repository.dart';
import '../services/weight_service.dart';
import './auth_provider.dart';

final weightRepositoryProvider = Provider<WeightRepository>((ref) {
  return WeightRepository();
});

final weightServiceProvider = Provider<WeightService>((ref) {
  final repo = ref.watch(weightRepositoryProvider);
  return WeightService(repository: repo);
});

final weightHistoryProvider = FutureProvider.autoDispose<List<BodyMetric>>((ref,) async {
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

final loadWeightDataProvider = FutureProvider.autoDispose<WeightData>((ref,) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) {
    return WeightData(weight: 0, height: 0, weightHistory: []);
  }

  final service = ref.watch(weightServiceProvider);
  final repo = ref.watch(weightRepositoryProvider);

  try {
    final results = await Future.wait([
      service.loadHistory(userId),
      repo.getLatestMetrics(userId),
    ]);

    final history = results[0] as List<BodyMetric>;
    final latestMetric = results[1] as BodyMetric?;
    double currentWeight = latestMetric?.weight ?? 0.0;
    if (history.isNotEmpty && currentWeight == 0.0) {
      currentWeight = history.first.weight;
    }

    final height = (await repo.getUserHeight(userId)) ?? 0.0;

    return WeightData(
      weight: currentWeight,
      height: height,
      weightHistory: history,
    );
  } catch (e) {
    debugPrint('[loadWeightDataProvider] Error: $e');
    rethrow;
  }
});

class WeightData {
  final double weight;
  final double height;
  final List<BodyMetric> weightHistory;
  WeightData({
    required this.weight,
    required this.height,
    required this.weightHistory,
  });
}

class WeightController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addWeight(double weight, {DateTime? date}) async {
    state = const AsyncValue.loading();
    final userId = await ref.read(currentUserIdProvider.future);
    if (userId == null) return;
    state = await AsyncValue.guard(() async {
      final service = ref.read(weightServiceProvider);
      await service.logNewWeight(userId: userId, weight: weight, date: date);
      ref.invalidate(weightHistoryProvider);
      ref.invalidate(loadWeightDataProvider);
    });
  }

  Future<void> deleteWeight(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(weightServiceProvider).deleteEntry(id);
      ref.invalidate(weightHistoryProvider);
      ref.invalidate(loadWeightDataProvider);
    });
  }
}

final weightControllerProvider = AsyncNotifierProvider<WeightController, void>(
  () {
    return WeightController();
  },
);
