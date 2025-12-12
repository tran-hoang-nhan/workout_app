import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/weight_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final weightServiceProvider = Provider((ref) => WeightService());

final weightHistoryProvider =
    FutureProvider.family<List<WeightRecord>, String>((ref, userId) async {
  final weightService = ref.watch(weightServiceProvider);
  return weightService.loadWeightHistory(userId);
});

final heightFromProfileProvider =
    FutureProvider.family<double?, String>((ref, userId) async {
  final weightService = ref.watch(weightServiceProvider);
  return weightService.loadHeightFromProfile(userId);
});

// Load weight data (height + weight history + current weight)
class WeightData {
  final double weight;
  final double height;
  final List<WeightRecord> weightHistory;

  WeightData({
    required this.weight,
    required this.height,
    required this.weightHistory,
  });
}

final loadWeightDataProvider = FutureProvider<WeightData>((ref) async {
  final weightService = ref.watch(weightServiceProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    return WeightData(weight: 68, height: 175, weightHistory: []);
  }

  final heightData = await weightService.loadHeightFromProfile(userId);
  final historyData = await weightService.loadWeightHistory(userId);

  double finalWeight = 68;
  if (historyData.isNotEmpty) {
    finalWeight = historyData.first.weight;
  } else {
    try {
      final supabase = Supabase.instance.client;
      final healthData = await supabase
          .from('health')
          .select('weight')
          .eq('user_id', userId)
          .single();
      finalWeight = (healthData['weight'] as num?)?.toDouble() ?? 68;
    } catch (e) {
      // Fallback to default
    }
  }

  return WeightData(
    weight: finalWeight,
    height: heightData ?? 175,
    weightHistory: historyData,
  );
});

// Save weight action
class SaveWeightParams {
  final String userId;
  final double weight;
  final double height;

  SaveWeightParams({
    required this.userId,
    required this.weight,
    required this.height,
  });
}

final saveWeightProvider =
    FutureProvider.family<void, SaveWeightParams>((ref, params) async {
  final weightService = ref.watch(weightServiceProvider);
  await weightService.saveWeight(
    userId: params.userId,
    weight: params.weight,
    height: params.height,
  );
  // Refresh weight data sau khi save
  ref.invalidate(loadWeightDataProvider);
});

// Delete weight action
final deleteWeightProvider = FutureProvider.family<void, int>((ref, recordId) async {
  final weightService = ref.watch(weightServiceProvider);
  await weightService.deleteWeight(recordId);
  ref.invalidate(loadWeightDataProvider);
});

