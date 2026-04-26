import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../utils/app_error.dart';
import './auth_provider.dart';
import './health_base_provider.dart';

final healthControllerProvider = AsyncNotifierProvider<HealthController, void>(
  HealthController.new,
);

class HealthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveFullProfile(HealthUpdateParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(healthServiceProvider);
      await service.updateFullProfile(params);
      ref.invalidate(healthDataProvider);
    });
  }

  Future<void> saveQuickMetrics({double? weight, double? height}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = await ref.read(currentUserIdProvider.future);
      if (userId == null) throw UnauthorizedException('Chưa đăng nhập');
      final service = ref.read(healthServiceProvider);
      await service.updateQuickMetrics(
        userId: userId,
        weight: weight,
        height: height,
      );
      ref.invalidate(healthDataProvider);
    });
  }
}

final hasHealthDataProvider = FutureProvider<bool>((ref) async {
  final healthData = await ref.watch(healthDataProvider.future);
  if (healthData == null) return false;
  if (healthData.weight == 0.0 || healthData.height == 0.0) return false;
  return true;
});
