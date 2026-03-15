import 'package:flutter_riverpod/flutter_riverpod.dart';
import './auth_provider.dart';
import './profile_provider.dart';
import './health_base_provider.dart';
import './health_form_provider.dart';
import './health_controller_provider.dart';

export './health_base_provider.dart';
export './health_form_provider.dart';
export './health_controller_provider.dart';
export './health_stats_provider.dart';
export '../models/health_calculations.dart';

final syncHealthProfileProvider = FutureProvider<void>((ref) async {
  final healthData = await ref.watch(healthDataProvider.future);
  if (healthData != null) {
    ref.read(healthFormProvider.notifier).updateFromHealthData(healthData);
  }
});

final saveHealthProfileProvider =
    FutureProvider.family<void, ({double height, String? gender})>((
  ref,
  params,
) async {
  final userId = await ref.read(currentUserIdProvider.future);
  if (userId == null) return;
  final currentUser = await ref.read(fullUserProfileProvider.future);
  final currentGoal = currentUser?.goal ?? 'maintain';
  final form = ref.read(healthFormProvider);
  final updateParams = form.copyWith(
    userId: userId,
    height: params.height,
    gender: params.gender ?? form.gender,
    goal: currentGoal,
  );
  await ref
      .read(healthControllerProvider.notifier)
      .saveFullProfile(updateParams);
});
